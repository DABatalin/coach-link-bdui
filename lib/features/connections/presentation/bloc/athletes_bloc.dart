import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/connections_repository.dart';
import '../../domain/models/athlete_info.dart';

// Events
sealed class AthletesEvent {
  const AthletesEvent();
}

class AthletesLoadRequested extends AthletesEvent {
  const AthletesLoadRequested();
}

class AthletesSearchChanged extends AthletesEvent {
  const AthletesSearchChanged(this.query);
  final String query;
}

class AthleteRemoved extends AthletesEvent {
  const AthleteRemoved(this.athleteId);
  final String athleteId;
}

// States
sealed class AthletesState {
  const AthletesState();
}

class AthletesInitial extends AthletesState {
  const AthletesInitial();
}

class AthletesLoading extends AthletesState {
  const AthletesLoading();
}

class AthletesLoaded extends AthletesState {
  const AthletesLoaded(this.athletes);
  final List<AthleteInfo> athletes;
}

class AthletesError extends AthletesState {
  const AthletesError(this.message);
  final String message;
}

// Bloc
class AthletesBloc extends Bloc<AthletesEvent, AthletesState> {
  AthletesBloc({required ConnectionsRepository repository})
      : _repository = repository,
        super(const AthletesInitial()) {
    on<AthletesLoadRequested>(_onLoad);
    on<AthletesSearchChanged>(_onSearch);
    on<AthleteRemoved>(_onRemoved);
  }

  final ConnectionsRepository _repository;
  String _currentQuery = '';

  Future<void> _onLoad(
    AthletesLoadRequested event,
    Emitter<AthletesState> emit,
  ) async {
    emit(const AthletesLoading());
    try {
      final result = await _repository.getCoachAthletes(query: _currentQuery);
      emit(AthletesLoaded(result.items));
    } on DioException catch (e) {
      final error = e.error;
      emit(AthletesError(
        error is AppException
            ? error.message
            : 'Не удалось загрузить спортсменов',
      ));
    } catch (_) {
      emit(const AthletesError('Произошла ошибка'));
    }
  }

  Future<void> _onSearch(
    AthletesSearchChanged event,
    Emitter<AthletesState> emit,
  ) async {
    _currentQuery = event.query;
    add(const AthletesLoadRequested());
  }

  Future<void> _onRemoved(
    AthleteRemoved event,
    Emitter<AthletesState> emit,
  ) async {
    try {
      await _repository.removeAthlete(athleteId: event.athleteId);
      add(const AthletesLoadRequested());
    } catch (_) {
      // keep current state
    }
  }
}
