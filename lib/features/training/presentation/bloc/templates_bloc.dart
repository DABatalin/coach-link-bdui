import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/models/training_template.dart';
import '../../domain/training_repository.dart';

// Events
sealed class TemplatesEvent {
  const TemplatesEvent();
}

class TemplatesLoadRequested extends TemplatesEvent {
  const TemplatesLoadRequested();
}

class TemplateCreated extends TemplatesEvent {
  const TemplateCreated({required this.title, required this.description});
  final String title;
  final String description;
}

class TemplateDeleted extends TemplatesEvent {
  const TemplateDeleted(this.templateId);
  final String templateId;
}

// States
sealed class TemplatesState {
  const TemplatesState();
}

class TemplatesInitial extends TemplatesState {
  const TemplatesInitial();
}

class TemplatesLoading extends TemplatesState {
  const TemplatesLoading();
}

class TemplatesLoaded extends TemplatesState {
  const TemplatesLoaded(this.templates);
  final List<TrainingTemplate> templates;
}

class TemplatesError extends TemplatesState {
  const TemplatesError(this.message);
  final String message;
}

// Bloc
class TemplatesBloc extends Bloc<TemplatesEvent, TemplatesState> {
  TemplatesBloc({required TrainingRepository repository})
      : _repository = repository,
        super(const TemplatesInitial()) {
    on<TemplatesLoadRequested>(_onLoad);
    on<TemplateCreated>(_onCreated);
    on<TemplateDeleted>(_onDeleted);
  }

  final TrainingRepository _repository;

  Future<void> _onLoad(
    TemplatesLoadRequested event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());
    try {
      final result = await _repository.getTemplates();
      emit(TemplatesLoaded(result.items));
    } on DioException catch (e) {
      final error = e.error;
      emit(TemplatesError(
        error is AppException ? error.message : 'Не удалось загрузить шаблоны',
      ));
    } catch (_) {
      emit(const TemplatesError('Произошла ошибка'));
    }
  }

  Future<void> _onCreated(
    TemplateCreated event,
    Emitter<TemplatesState> emit,
  ) async {
    try {
      await _repository.createTemplate(
          title: event.title, description: event.description);
      add(const TemplatesLoadRequested());
    } catch (_) {}
  }

  Future<void> _onDeleted(
    TemplateDeleted event,
    Emitter<TemplatesState> emit,
  ) async {
    try {
      await _repository.deleteTemplate(templateId: event.templateId);
      add(const TemplatesLoadRequested());
    } catch (_) {}
  }
}
