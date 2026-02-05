import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/api/api_exceptions.dart';
import '../../domain/connections_repository.dart';
import '../../domain/models/athlete_info.dart';
import '../../../training/domain/models/assignment.dart';
import '../../../training/domain/training_repository.dart';

// Events
sealed class AthleteDetailEvent {
  const AthleteDetailEvent();
}

class AthleteDetailLoadRequested extends AthleteDetailEvent {
  const AthleteDetailLoadRequested(this.athleteId);
  final String athleteId;
}

class AthleteDetailRefreshRequested extends AthleteDetailEvent {
  const AthleteDetailRefreshRequested();
}

// States
sealed class AthleteDetailState {
  const AthleteDetailState();
}

class AthleteDetailInitial extends AthleteDetailState {
  const AthleteDetailInitial();
}

class AthleteDetailLoading extends AthleteDetailState {
  const AthleteDetailLoading();
}

class AthleteDetailLoaded extends AthleteDetailState {
  const AthleteDetailLoaded({
    required this.athleteInfo,
    required this.assignments,
  });
  final AthleteInfo athleteInfo;
  final List<AssignmentListItem> assignments;
}

class AthleteDetailError extends AthleteDetailState {
  const AthleteDetailError(this.message);
  final String message;
}

// Bloc
class AthleteDetailBloc extends Bloc<AthleteDetailEvent, AthleteDetailState> {
  AthleteDetailBloc({
    required ConnectionsRepository connectionsRepository,
    required TrainingRepository trainingRepository,
  })  : _connectionsRepository = connectionsRepository,
        _trainingRepository = trainingRepository,
        super(const AthleteDetailInitial()) {
    on<AthleteDetailLoadRequested>(_onLoad);
    on<AthleteDetailRefreshRequested>(_onRefresh);
  }

  final ConnectionsRepository _connectionsRepository;
  final TrainingRepository _trainingRepository;
  String? _currentAthleteId;

  Future<void> _onLoad(
    AthleteDetailLoadRequested event,
    Emitter<AthleteDetailState> emit,
  ) async {
    _currentAthleteId = event.athleteId;
    emit(const AthleteDetailLoading());
    try {
      // Load athlete info
      final athletesResult = await _connectionsRepository.getCoachAthletes();
      final athleteInfo = athletesResult.items.firstWhere(
        (a) => a.id == event.athleteId,
        orElse: () => throw Exception('Спортсмен не найден'),
      );

      // Load all assignments and filter by athlete ID
      final assignmentsResult = await _trainingRepository.getAssignments();
      final filteredAssignments = assignmentsResult.items
          .where((a) => a.athleteId == event.athleteId)
          .toList();

      emit(AthleteDetailLoaded(
        athleteInfo: athleteInfo,
        assignments: filteredAssignments,
      ));
    } on DioException catch (e) {
      final error = e.error;
      emit(AthleteDetailError(
        error is AppException
            ? error.message
            : 'Не удалось загрузить информацию о спортсмене',
      ));
    } catch (e) {
      emit(AthleteDetailError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    AthleteDetailRefreshRequested event,
    Emitter<AthleteDetailState> emit,
  ) async {
    if (_currentAthleteId == null) return;
    add(AthleteDetailLoadRequested(_currentAthleteId!));
  }
}
