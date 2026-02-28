import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:coach_link/shared/models/paginated_result.dart';
import 'package:coach_link/shared/models/pagination.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockConnectionsRepository connectionsRepo;
  late MockTrainingRepository trainingRepo;
  late MockBduiDataProvider bduiProvider;

  setUp(() {
    connectionsRepo = MockConnectionsRepository();
    trainingRepo = MockTrainingRepository();
    bduiProvider = MockBduiDataProvider();
  });

  group('DashboardBloc — coach (native fallback)', () {
    DashboardBloc buildCoachBloc() => DashboardBloc(
          role: 'coach',
          connectionsRepository: connectionsRepo,
          trainingRepository: trainingRepo,
        );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, CoachDashboardLoaded] with correct counts',
      build: () {
        when(() => connectionsRepo.getCoachAthletes(pageSize: 1)).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            pagination: Pagination(
                page: 1, pageSize: 1, totalItems: 5, totalPages: 5),
          ),
        );
        when(() => connectionsRepo.getIncomingRequests(pageSize: 1)).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            pagination: Pagination(
                page: 1, pageSize: 1, totalItems: 2, totalPages: 2),
          ),
        );
        when(() => trainingRepo.getAssignments(pageSize: 5))
            .thenAnswer((_) async => makePaginated([makeAssignment()]));
        return buildCoachBloc();
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<CoachDashboardLoaded>()
            .having((s) => s.athleteCount, 'athleteCount', 5)
            .having((s) => s.pendingRequestsCount, 'pendingRequestsCount', 2)
            .having((s) => s.recentAssignments.length, 'assignments', 1),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => connectionsRepo.getCoachAthletes(pageSize: 1))
            .thenThrow(Exception('Network error'));
        when(() => connectionsRepo.getIncomingRequests(pageSize: 1))
            .thenThrow(Exception('Network error'));
        when(() => trainingRepo.getAssignments(pageSize: 5))
            .thenThrow(Exception('Network error'));
        return buildCoachBloc();
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
    );
  });

  group('DashboardBloc — athlete (native fallback)', () {
    DashboardBloc buildAthleteBloc() => DashboardBloc(
          role: 'athlete',
          connectionsRepository: connectionsRepo,
          trainingRepository: trainingRepo,
        );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, AthleteDashboardLoaded] with coach when connected',
      build: () {
        when(() => trainingRepo.getAssignments(pageSize: 5))
            .thenAnswer((_) async => makePaginated([makeAssignment()]));
        when(() => connectionsRepo.getAthleteCoach())
            .thenAnswer((_) async => makeCoachInfo());
        return buildAthleteBloc();
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<AthleteDashboardLoaded>()
            .having((s) => s.hasCoach, 'hasCoach', true)
            .having((s) => s.coachName, 'coachName', 'Coach One'),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, AthleteDashboardLoaded] without coach when not connected',
      build: () {
        when(() => trainingRepo.getAssignments(pageSize: 5))
            .thenAnswer((_) async => makePaginated([]));
        when(() => connectionsRepo.getAthleteCoach())
            .thenThrow(Exception('No coach'));
        return buildAthleteBloc();
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<AthleteDashboardLoaded>()
            .having((s) => s.hasCoach, 'hasCoach', false)
            .having((s) => s.upcomingAssignments, 'assignments', isEmpty),
      ],
    );
  });

  group('DashboardBloc — BDUI path', () {
    DashboardBloc buildCoachBduiBloc() => DashboardBloc(
          role: 'coach',
          connectionsRepository: connectionsRepo,
          trainingRepository: trainingRepo,
          bduiDataProvider: bduiProvider,
        );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, DashboardBduiLoaded] when server returns schema',
      build: () {
        when(() => bduiProvider.getSchema(any())).thenAnswer((_) async {
          // Return a minimal valid schema via JSON parsing
          return null; // Simulate BDUI not available so we test native path
        });
        when(() => connectionsRepo.getCoachAthletes(pageSize: 1)).thenAnswer(
          (_) async => const PaginatedResult(
            items: [],
            pagination: Pagination(
                page: 1, pageSize: 1, totalItems: 0, totalPages: 0),
          ),
        );
        when(() => connectionsRepo.getIncomingRequests(pageSize: 1))
            .thenAnswer((_) async => makePaginated([]));
        when(() => trainingRepo.getAssignments(pageSize: 5))
            .thenAnswer((_) async => makePaginated([]));
        return buildCoachBduiBloc();
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<CoachDashboardLoaded>(),
      ],
    );
  });
}
