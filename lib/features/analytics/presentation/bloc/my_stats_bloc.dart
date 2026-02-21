import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/analytics_repository.dart';
import '../../domain/models/athlete_summary.dart';
import '../../domain/models/progress_point.dart';

// Events
sealed class MyStatsEvent {
  const MyStatsEvent();
}

class MyStatsLoadRequested extends MyStatsEvent {
  const MyStatsLoadRequested({this.period = 'week'});
  final String period;
}

class MyStatsPeriodChanged extends MyStatsEvent {
  const MyStatsPeriodChanged(this.period);
  final String period;
}

// States
sealed class MyStatsState {
  const MyStatsState();
}

class MyStatsInitial extends MyStatsState {
  const MyStatsInitial();
}

class MyStatsLoading extends MyStatsState {
  const MyStatsLoading();
}

class MyStatsLoaded extends MyStatsState {
  const MyStatsLoaded({
    required this.summary,
    required this.progress,
    required this.period,
  });
  final AthleteSummary summary;
  final List<ProgressPoint> progress;
  final String period;
}

class MyStatsError extends MyStatsState {
  const MyStatsError(this.message);
  final String message;
}

// Bloc
class MyStatsBloc extends Bloc<MyStatsEvent, MyStatsState> {
  MyStatsBloc({required AnalyticsRepository repository})
      : _repository = repository,
        super(const MyStatsInitial()) {
    on<MyStatsLoadRequested>(_onLoad);
    on<MyStatsPeriodChanged>(_onPeriodChanged);
  }

  final AnalyticsRepository _repository;

  Future<void> _onLoad(
    MyStatsLoadRequested event,
    Emitter<MyStatsState> emit,
  ) async {
    emit(const MyStatsLoading());
    try {
      final results = await Future.wait([
        _repository.getMySummary(),
        _repository.getMyProgress(period: event.period),
      ]);
      emit(MyStatsLoaded(
        summary: results[0] as AthleteSummary,
        progress: results[1] as List<ProgressPoint>,
        period: event.period,
      ));
    } catch (_) {
      emit(const MyStatsError('Не удалось загрузить статистику'));
    }
  }

  Future<void> _onPeriodChanged(
    MyStatsPeriodChanged event,
    Emitter<MyStatsState> emit,
  ) async {
    try {
      final progress = await _repository.getMyProgress(period: event.period);
      final summary = state is MyStatsLoaded
          ? (state as MyStatsLoaded).summary
          : await _repository.getMySummary();
      emit(MyStatsLoaded(
        summary: summary,
        progress: progress,
        period: event.period,
      ));
    } catch (_) {
      emit(const MyStatsError('Не удалось обновить данные'));
    }
  }
}
