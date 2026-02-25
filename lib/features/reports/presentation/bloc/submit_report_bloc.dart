import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../domain/reports_repository.dart';

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

class SubmitReportBloc extends Bloc<SubmitReportEvent, SubmitReportState> {
  SubmitReportBloc({
    required ReportsRepository repository,
    required AnalyticsService analytics,
  })  : _repository = repository,
        _analytics = analytics,
        super(const SubmitReportInitial()) {
    on<ReportSubmitted>(_onSubmitted);
  }

  final ReportsRepository _repository;
  final AnalyticsService _analytics;

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
      await _analytics.logEvent('report_submitted', parameters: {
        'perceived_effort': event.perceivedEffort,
        'duration_minutes': event.durationMinutes,
      });
      emit(const SubmitReportSuccess());
    } on DioException catch (e) {
      final error = e.error;
      emit(SubmitReportFailure(
        error is AppException ? error.message : 'Не удалось отправить отчёт',
      ));
    } catch (e, stack) {
      await _analytics.recordError(e, stack);
      emit(const SubmitReportFailure('Произошла ошибка'));
    }
  }
}
