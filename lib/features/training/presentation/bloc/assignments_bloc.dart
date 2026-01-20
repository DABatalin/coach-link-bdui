import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/models/assignment.dart';
import '../../domain/training_repository.dart';

// Events
sealed class AssignmentsEvent {
  const AssignmentsEvent();
}

class AssignmentsLoadRequested extends AssignmentsEvent {
  const AssignmentsLoadRequested();
}

class AssignmentDeleteRequested extends AssignmentsEvent {
  const AssignmentDeleteRequested(this.assignmentId);
  final String assignmentId;
}

class AssignmentArchiveRequested extends AssignmentsEvent {
  const AssignmentArchiveRequested(this.assignmentId);
  final String assignmentId;
}

// States
sealed class AssignmentsState {
  const AssignmentsState();
}

class AssignmentsInitial extends AssignmentsState {
  const AssignmentsInitial();
}

class AssignmentsLoading extends AssignmentsState {
  const AssignmentsLoading();
}

class AssignmentsLoaded extends AssignmentsState {
  const AssignmentsLoaded(this.assignments);
  final List<AssignmentListItem> assignments;
}

class AssignmentsError extends AssignmentsState {
  const AssignmentsError(this.message);
  final String message;
}

// Bloc for both Coach and Athlete assignments
class AssignmentsBloc extends Bloc<AssignmentsEvent, AssignmentsState> {
  AssignmentsBloc({required TrainingRepository repository})
      : _repository = repository,
        super(const AssignmentsInitial()) {
    on<AssignmentsLoadRequested>(_onLoad);
    on<AssignmentDeleteRequested>(_onDelete);
    on<AssignmentArchiveRequested>(_onArchive);
  }

  final TrainingRepository _repository;

  Future<void> _onLoad(
    AssignmentsLoadRequested event,
    Emitter<AssignmentsState> emit,
  ) async {
    emit(const AssignmentsLoading());
    try {
      final result = await _repository.getAssignments();
      emit(AssignmentsLoaded(result.items));
    } on DioException catch (e) {
      final error = e.error;
      emit(AssignmentsError(
        error is AppException ? error.message : 'Не удалось загрузить задания',
      ));
    } catch (_) {
      emit(const AssignmentsError('Произошла ошибка'));
    }
  }

  Future<void> _onDelete(
    AssignmentDeleteRequested event,
    Emitter<AssignmentsState> emit,
  ) async {
    try {
      await _repository.deleteAssignment(assignmentId: event.assignmentId);
      add(const AssignmentsLoadRequested());
    } catch (_) {}
  }

  Future<void> _onArchive(
    AssignmentArchiveRequested event,
    Emitter<AssignmentsState> emit,
  ) async {
    try {
      await _repository.archiveAssignment(assignmentId: event.assignmentId);
      add(const AssignmentsLoadRequested());
    } catch (_) {}
  }
}
