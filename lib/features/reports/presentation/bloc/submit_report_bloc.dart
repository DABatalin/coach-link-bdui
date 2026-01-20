import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/reports_repository.dart';

// Events
sealed class SubmitReportEvent {
  const SubmitReportEvent();
}

class ReportSubmitted extends SubmitReportEvent {
  const ReportSubmitted({
    required this.assignmentId,
    required this.content,
    required this.durationMinutes,
    required this.perceivedEffort,
    this.maxHeartRate,
    this.avgHeartRate,
    this.distanceKm,
  });

  final String assignmentId;
  final String content;
  final int durationMinutes;
  final int perceivedEffort;
  final int? maxHeartRate;
  final int? avgHeartRate;
  final double? distanceKm;
}

// States
sealed class SubmitReportState {
  const SubmitReportState();
}

class SubmitReportInitial extends SubmitReportState {
  const SubmitReportInitial();
}

class SubmitReportLoading extends SubmitReportState {
  const SubmitReportLoading();
}

class SubmitReportSuccess extends SubmitReportState {
  const SubmitReportSuccess();
}

class SubmitReportFailure extends SubmitReportState {
  const SubmitReportFailure(this.message);
  final String message;
}

// Bloc
class SubmitReportBloc extends Bloc<SubmitReportEvent, SubmitReportState> {
  SubmitReportBloc({required ReportsRepository repository})
      : _repository = repository,
        super(const SubmitReportInitial()) {
    on<ReportSubmitted>(_onSubmitted);
  }

  final ReportsRepository _repository;

  Future<void> _onSubmitted(
    ReportSubmitted event,
    Emitter<SubmitReportState> emit,
  ) async {
    emit(const SubmitReportLoading());
    try {
      await _repository.submitReport(
        assignmentId: event.assignmentId,
        content: event.content,
        durationMinutes: event.durationMinutes,
        perceivedEffort: event.perceivedEffort,
        maxHeartRate: event.maxHeartRate,
        avgHeartRate: event.avgHeartRate,
        distanceKm: event.distanceKm,
      );
      emit(const SubmitReportSuccess());
    } on DioException catch (e) {
      final error = e.error;
      emit(SubmitReportFailure(
        error is AppException ? error.message : 'Не удалось отправить отчёт',
      ));
    } catch (_) {
      emit(const SubmitReportFailure('Произошла ошибка'));
    }
  }
}
