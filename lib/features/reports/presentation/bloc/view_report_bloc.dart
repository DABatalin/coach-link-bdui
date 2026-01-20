import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/models/training_report.dart';
import '../../domain/reports_repository.dart';

// Events
sealed class ViewReportEvent {
  const ViewReportEvent();
}

class ViewReportLoadRequested extends ViewReportEvent {
  const ViewReportLoadRequested(this.assignmentId);
  final String assignmentId;
}

// States
sealed class ViewReportState {
  const ViewReportState();
}

class ViewReportInitial extends ViewReportState {
  const ViewReportInitial();
}

class ViewReportLoading extends ViewReportState {
  const ViewReportLoading();
}

class ViewReportLoaded extends ViewReportState {
  const ViewReportLoaded(this.report);
  final TrainingReport report;
}

class ViewReportError extends ViewReportState {
  const ViewReportError(this.message);
  final String message;
}

// Bloc
class ViewReportBloc extends Bloc<ViewReportEvent, ViewReportState> {
  ViewReportBloc({required ReportsRepository repository})
      : _repository = repository,
        super(const ViewReportInitial()) {
    on<ViewReportLoadRequested>(_onLoad);
  }

  final ReportsRepository _repository;

  Future<void> _onLoad(
    ViewReportLoadRequested event,
    Emitter<ViewReportState> emit,
  ) async {
    emit(const ViewReportLoading());
    try {
      final report =
          await _repository.getReport(assignmentId: event.assignmentId);
      emit(ViewReportLoaded(report));
    } on DioException catch (e) {
      final error = e.error;
      emit(ViewReportError(
        error is AppException ? error.message : 'Не удалось загрузить отчёт',
      ));
    } catch (_) {
      emit(const ViewReportError('Произошла ошибка'));
    }
  }
}
