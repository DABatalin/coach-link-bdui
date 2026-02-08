import 'package:bdui_kit/bdui_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../../../core/bdui/bdui_data_provider.dart';
import '../../domain/models/assignment.dart';
import '../../domain/training_repository.dart';

// Events
sealed class AssignmentDetailEvent {
  const AssignmentDetailEvent();
}

class AssignmentDetailLoadRequested extends AssignmentDetailEvent {
  const AssignmentDetailLoadRequested(this.assignmentId);
  final String assignmentId;
}

// States
sealed class AssignmentDetailState {
  const AssignmentDetailState();
}

class AssignmentDetailInitial extends AssignmentDetailState {
  const AssignmentDetailInitial();
}

class AssignmentDetailLoading extends AssignmentDetailState {
  const AssignmentDetailLoading();
}

class AssignmentDetailLoaded extends AssignmentDetailState {
  const AssignmentDetailLoaded(this.assignment);
  final AssignmentDetail assignment;
}

class AssignmentDetailWithBdui extends AssignmentDetailState {
  const AssignmentDetailWithBdui({
    required this.assignment,
    required this.descriptionSchema,
  });
  final AssignmentDetail assignment;
  final BduiSchema descriptionSchema;
}

class AssignmentDetailError extends AssignmentDetailState {
  const AssignmentDetailError(this.message);
  final String message;
}

// Bloc
class AssignmentDetailBloc
    extends Bloc<AssignmentDetailEvent, AssignmentDetailState> {
  AssignmentDetailBloc({
    required TrainingRepository repository,
    BduiDataProvider? bduiDataProvider,
  })  : _repository = repository,
        _bduiDataProvider = bduiDataProvider,
        super(const AssignmentDetailInitial()) {
    on<AssignmentDetailLoadRequested>(_onLoad);
  }

  final TrainingRepository _repository;
  final BduiDataProvider? _bduiDataProvider;

  Future<void> _onLoad(
    AssignmentDetailLoadRequested event,
    Emitter<AssignmentDetailState> emit,
  ) async {
    emit(const AssignmentDetailLoading());
    try {
      final assignment =
          await _repository.getAssignment(assignmentId: event.assignmentId);

      // Попробовать загрузить BDUI-описание тренировки
      if (_bduiDataProvider != null) {
        try {
          final schema = await _bduiDataProvider
              .getSchema('training-detail/${event.assignmentId}');
          if (schema != null) {
            emit(AssignmentDetailWithBdui(
              assignment: assignment,
              descriptionSchema: schema,
            ));
            return;
          }
        } catch (_) {
          // BDUI недоступен — fallback на plain-text
        }
      }

      emit(AssignmentDetailLoaded(assignment));
    } on DioException catch (e) {
      final error = e.error;
      emit(AssignmentDetailError(
        error is AppException ? error.message : 'Не удалось загрузить задание',
      ));
    } catch (_) {
      emit(const AssignmentDetailError('Произошла ошибка'));
    }
  }
}
