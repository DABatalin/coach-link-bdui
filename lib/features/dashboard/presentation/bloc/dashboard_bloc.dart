import 'package:bdui_kit/bdui_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bdui/bdui_data_provider.dart';
import '../../../connections/domain/connections_repository.dart';
import '../../../training/domain/models/assignment.dart';
import '../../../training/domain/training_repository.dart';

// Events
sealed class DashboardEvent {
  const DashboardEvent();
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

// States
sealed class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class CoachDashboardLoaded extends DashboardState {
  const CoachDashboardLoaded({
    required this.athleteCount,
    required this.pendingRequestsCount,
    required this.recentAssignments,
  });

  final int athleteCount;
  final int pendingRequestsCount;
  final List<AssignmentListItem> recentAssignments;
}

class AthleteDashboardLoaded extends DashboardState {
  const AthleteDashboardLoaded({
    required this.upcomingAssignments,
    required this.hasCoach,
    this.coachName,
  });

  final List<AssignmentListItem> upcomingAssignments;
  final bool hasCoach;
  final String? coachName;
}

class DashboardBduiLoaded extends DashboardState {
  const DashboardBduiLoaded(this.schema);
  final BduiSchema schema;
}

class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;
}

// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required this.role,
    required ConnectionsRepository connectionsRepository,
    required TrainingRepository trainingRepository,
    BduiDataProvider? bduiDataProvider,
  })  : _connectionsRepo = connectionsRepository,
        _trainingRepo = trainingRepository,
        _bduiDataProvider = bduiDataProvider,
        super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  final String role;
  final ConnectionsRepository _connectionsRepo;
  final TrainingRepository _trainingRepo;
  final BduiDataProvider? _bduiDataProvider;

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      // Попробовать BDUI
      if (_bduiDataProvider != null) {
        final screenId =
            role == 'coach' ? 'coach-dashboard' : 'athlete-dashboard';
        final schema = await _bduiDataProvider.getSchema(screenId);
        if (schema != null) {
          emit(DashboardBduiLoaded(schema));
          return;
        }
      }

      // Fallback — нативный дашборд
      if (role == 'coach') {
        await _loadCoachDashboard(emit);
      } else {
        await _loadAthleteDashboard(emit);
      }
    } catch (_) {
      emit(const DashboardError('Не удалось загрузить данные'));
    }
  }

  Future<void> _loadCoachDashboard(Emitter<DashboardState> emit) async {
    final results = await Future.wait([
      _connectionsRepo.getCoachAthletes(pageSize: 1),
      _connectionsRepo.getIncomingRequests(pageSize: 1),
      _trainingRepo.getAssignments(pageSize: 5),
    ]);

    final athleteResult = results[0] as dynamic;
    final requestsResult = results[1] as dynamic;
    final assignmentsResult = results[2] as dynamic;

    emit(CoachDashboardLoaded(
      athleteCount: athleteResult.pagination.totalItems as int,
      pendingRequestsCount: requestsResult.pagination.totalItems as int,
      recentAssignments:
          List<AssignmentListItem>.from(assignmentsResult.items as List),
    ));
  }

  Future<void> _loadAthleteDashboard(Emitter<DashboardState> emit) async {
    final assignmentsResult = await _trainingRepo.getAssignments(pageSize: 5);

    String? coachName;
    bool hasCoach = false;
    try {
      final coach = await _connectionsRepo.getAthleteCoach();
      hasCoach = true;
      coachName = coach.fullName;
    } catch (_) {
      // No coach
    }

    emit(AthleteDashboardLoaded(
      upcomingAssignments: assignmentsResult.items,
      hasCoach: hasCoach,
      coachName: coachName,
    ));
  }
}
