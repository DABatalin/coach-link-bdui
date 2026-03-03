import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/connections/presentation/bloc/athletes_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockConnectionsRepository connectionsRepo;

  setUp(() {
    connectionsRepo = MockConnectionsRepository();
  });

  AthletesBloc buildBloc() => AthletesBloc(repository: connectionsRepo);

  group('AthletesBloc', () {
    test('initial state is AthletesInitial', () {
      expect(buildBloc().state, isA<AthletesInitial>());
    });

    blocTest<AthletesBloc, AthletesState>(
      'emits [Loading, Loaded] with athletes list',
      build: () {
        when(() => connectionsRepo.getCoachAthletes(query: any(named: 'query')))
            .thenAnswer((_) async => makePaginated([
                  makeAthleteInfo(id: 'ath1'),
                  makeAthleteInfo(id: 'ath2'),
                ]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AthletesLoadRequested()),
      expect: () => [
        isA<AthletesLoading>(),
        isA<AthletesLoaded>().having((s) => s.athletes.length, 'length', 2),
      ],
    );

    blocTest<AthletesBloc, AthletesState>(
      'emits [Loading, Loaded(empty)] when no athletes',
      build: () {
        when(() => connectionsRepo.getCoachAthletes(query: any(named: 'query')))
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AthletesLoadRequested()),
      expect: () => [
        isA<AthletesLoading>(),
        isA<AthletesLoaded>().having((s) => s.athletes, 'athletes', isEmpty),
      ],
    );

    blocTest<AthletesBloc, AthletesState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => connectionsRepo.getCoachAthletes(query: any(named: 'query')))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AthletesLoadRequested()),
      expect: () => [isA<AthletesLoading>(), isA<AthletesError>()],
    );

    blocTest<AthletesBloc, AthletesState>(
      'AthletesSearchChanged updates query and reloads',
      build: () {
        when(() => connectionsRepo.getCoachAthletes(query: 'ivan'))
            .thenAnswer((_) async =>
                makePaginated([makeAthleteInfo(id: 'ath1')]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AthletesSearchChanged('ivan')),
      expect: () => [
        isA<AthletesLoading>(),
        isA<AthletesLoaded>().having((s) => s.athletes.length, 'length', 1),
      ],
      verify: (_) =>
          verify(() => connectionsRepo.getCoachAthletes(query: 'ivan'))
              .called(1),
    );

    blocTest<AthletesBloc, AthletesState>(
      'AthleteRemoved calls removeAthlete and reloads list',
      build: () {
        when(() => connectionsRepo.removeAthlete(athleteId: 'ath1'))
            .thenAnswer((_) async {});
        when(() => connectionsRepo.getCoachAthletes(query: any(named: 'query')))
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AthleteRemoved('ath1')),
      expect: () => [
        isA<AthletesLoading>(),
        isA<AthletesLoaded>(),
      ],
      verify: (_) =>
          verify(() => connectionsRepo.removeAthlete(athleteId: 'ath1'))
              .called(1),
    );
  });
}
