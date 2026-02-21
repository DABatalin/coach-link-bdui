import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/analytics_repository.dart';
import '../../domain/models/athlete_summary.dart';
import '../../domain/models/progress_point.dart';

// Events
sealed class AthleteStatsEvent {
  const AthleteStatsEvent();
}

class AthleteStatsLoadRequested extends AthleteStatsEvent {
  const AthleteStatsLoadRequested(this.athleteId, {this.period = 'week'});
  final String athleteId;
  final String period;
}

class AthleteStatsPeriodChanged extends AthleteStatsEvent {
  const AthleteStatsPeriodChanged(this.athleteId, this.period);
  final String athleteId;
  final String period;
}

// States
sealed class AthleteStatsState {
  const AthleteStatsState();
}

class AthleteStatsInitial extends AthleteStatsState {
  const AthleteStatsInitial();
}

class AthleteStatsLoading extends AthleteStatsState {
  const AthleteStatsLoading();
}

class AthleteStatsLoaded extends AthleteStatsState {
  const AthleteStatsLoaded({
    required this.summary,
    required this.progress,
    required this.period,
  });
  final AthleteSummary summary;
  final List<ProgressPoint> progress;
  final String period;
}

class AthleteStatsError extends AthleteStatsState {
  const AthleteStatsError(this.message);
  final String message;
}

// Bloc
class AthleteStatsBloc extends Bloc<AthleteStatsEvent, AthleteStatsState> {
  AthleteStatsBloc({required AnalyticsRepository repository})
      : _repository = repository,
        super(const AthleteStatsInitial()) {
    on<AthleteStatsLoadRequested>(_onLoad);
    on<AthleteStatsPeriodChanged>(_onPeriodChanged);
  }

  final AnalyticsRepository _repository;

  Future<void> _onLoad(
    AthleteStatsLoadRequested event,
    Emitter<AthleteStatsState> emit,
  ) async {
    emit(const AthleteStatsLoading());
    try {
      final results = await Future.wait([
        _repository.getAthleteSummary(athleteId: event.athleteId),
        _repository.getAthleteProgress(
          athleteId: event.athleteId,
          period: event.period,
        ),
      ]);
      emit(AthleteStatsLoaded(
        summary: results[0] as AthleteSummary,
        progress: results[1] as List<ProgressPoint>,
        period: event.period,
      ));
    } catch (_) {
      emit(const AthleteStatsError('Не удалось загрузить статистику'));
    }
  }

  Future<void> _onPeriodChanged(
    AthleteStatsPeriodChanged event,
    Emitter<AthleteStatsState> emit,
  ) async {
    final current = state;
    if (current is AthleteStatsLoaded) {
      emit(AthleteStatsLoaded(
        summary: current.summary,
        progress: current.progress,
        period: event.period,
      ));
    }
    try {
      final progress = await _repository.getAthleteProgress(
        athleteId: event.athleteId,
        period: event.period,
      );
      final summary = state is AthleteStatsLoaded
          ? (state as AthleteStatsLoaded).summary
          : await _repository.getAthleteSummary(athleteId: event.athleteId);
      emit(AthleteStatsLoaded(
        summary: summary,
        progress: progress,
        period: event.period,
      ));
    } catch (_) {
      emit(const AthleteStatsError('Не удалось обновить данные'));
    }
  }
}
