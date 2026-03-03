import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/connections/presentation/bloc/athlete_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockConnectionsRepository connectionsRepo;
  late MockTrainingRepository trainingRepo;

  setUp(() {
    connectionsRepo = MockConnectionsRepository();
    trainingRepo = MockTrainingRepository();
  });

  AthleteDetailBloc buildBloc() => AthleteDetailBloc(
        connectionsRepository: connectionsRepo,
        trainingRepository: trainingRepo,
      );

  group('AthleteDetailBloc', () {
    test('initial state is AthleteDetailInitial', () {
      expect(buildBloc().state, isA<AthleteDetailInitial>());
    });

    blocTest<AthleteDetailBloc, AthleteDetailState>(
      'emits [Loading, Loaded] with athlete info and filtered assignments',
      build: () {
        when(() => connectionsRepo.getCoachAthletes()).thenAnswer(
          (_) async => makePaginated([makeAthleteInfo(id: 'ath1')]),
        );
        when(() => trainingRepo.getAssignments()).thenAnswer(
          (_) async => makePaginated([
            makeAssignment(id: 'a1', athleteId: 'ath1'),
            makeAssignment(id: 'a2', athleteId: 'ath2'),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AthleteDetailLoadRequested('ath1')),
      expect: () => [
        isA<AthleteDetailLoading>(),
        isA<AthleteDetailLoaded>()
            .having((s) => s.athleteInfo.id, 'athleteId', 'ath1')
            .having((s) => s.assignments.length, 'assignmentsLength', 1),
      ],
    );

    blocTest<AthleteDetailBloc, AthleteDetailState>(
      'emits [Loading, Error] when athlete not found in list',
      build: () {
        when(() => connectionsRepo.getCoachAthletes())
            .thenAnswer((_) async => makePaginated([]));
        when(() => trainingRepo.getAssignments())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AthleteDetailLoadRequested('unknown')),
      expect: () => [
        isA<AthleteDetailLoading>(),
        isA<AthleteDetailError>(),
      ],
    );

    blocTest<AthleteDetailBloc, AthleteDetailState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => connectionsRepo.getCoachAthletes())
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AthleteDetailLoadRequested('ath1')),
      expect: () => [
        isA<AthleteDetailLoading>(),
        isA<AthleteDetailError>(),
      ],
    );

    blocTest<AthleteDetailBloc, AthleteDetailState>(
      'AthleteDetailRefreshRequested reloads last athlete',
      build: () {
        when(() => connectionsRepo.getCoachAthletes()).thenAnswer(
          (_) async => makePaginated([makeAthleteInfo(id: 'ath1')]),
        );
        when(() => trainingRepo.getAssignments())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const AthleteDetailLoadRequested('ath1'));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const AthleteDetailRefreshRequested());
      },
      expect: () => [
        isA<AthleteDetailLoading>(),
        isA<AthleteDetailLoaded>(),
        isA<AthleteDetailLoading>(),
        isA<AthleteDetailLoaded>(),
      ],
    );

    blocTest<AthleteDetailBloc, AthleteDetailState>(
      'AthleteDetailRefreshRequested does nothing without prior load',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const AthleteDetailRefreshRequested()),
      expect: () => [],
    );
  });
}
