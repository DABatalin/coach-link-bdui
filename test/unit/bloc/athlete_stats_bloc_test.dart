import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/analytics/presentation/bloc/athlete_stats_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockAnalyticsRepository analyticsRepo;

  setUp(() {
    analyticsRepo = MockAnalyticsRepository();
  });

  AthleteStatsBloc buildBloc() =>
      AthleteStatsBloc(repository: analyticsRepo);

  void stubLoad({String period = 'week'}) {
    when(() => analyticsRepo.getAthleteSummary(athleteId: 'ath1'))
        .thenAnswer((_) async => makeAthleteSummary());
    when(() => analyticsRepo.getAthleteProgress(
          athleteId: 'ath1',
          period: period,
        )).thenAnswer((_) async => [makeProgressPoint()]);
  }

  group('AthleteStatsBloc', () {
    test('initial state is AthleteStatsInitial', () {
      expect(buildBloc().state, isA<AthleteStatsInitial>());
    });

    blocTest<AthleteStatsBloc, AthleteStatsState>(
      'emits [Loading, Loaded] on AthleteStatsLoadRequested',
      build: () {
        stubLoad();
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AthleteStatsLoadRequested('ath1')),
      expect: () => [
        isA<AthleteStatsLoading>(),
        isA<AthleteStatsLoaded>()
            .having((s) => s.period, 'period', 'week')
            .having((s) => s.progress.length, 'progressLength', 1),
      ],
    );

    blocTest<AthleteStatsBloc, AthleteStatsState>(
      'emits [Loading, Loaded] with custom period',
      build: () {
        stubLoad(period: 'month');
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AthleteStatsLoadRequested('ath1', period: 'month'),
      ),
      expect: () => [
        isA<AthleteStatsLoading>(),
        isA<AthleteStatsLoaded>().having((s) => s.period, 'period', 'month'),
      ],
    );

    blocTest<AthleteStatsBloc, AthleteStatsState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => analyticsRepo.getAthleteSummary(athleteId: any(named: 'athleteId')))
            .thenThrow(Exception('Network error'));
        when(() => analyticsRepo.getAthleteProgress(
              athleteId: any(named: 'athleteId'),
              period: any(named: 'period'),
            )).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AthleteStatsLoadRequested('ath1')),
      expect: () => [
        isA<AthleteStatsLoading>(),
        isA<AthleteStatsError>(),
      ],
    );

    blocTest<AthleteStatsBloc, AthleteStatsState>(
      'AthleteStatsPeriodChanged updates period in Loaded state',
      build: () {
        stubLoad();
        when(() => analyticsRepo.getAthleteProgress(
              athleteId: 'ath1',
              period: 'month',
            )).thenAnswer((_) async => [
              makeProgressPoint(label: 'Jan'),
              makeProgressPoint(label: 'Feb'),
            ]);
        return buildBloc();
      },
      seed: () => AthleteStatsLoaded(
        summary: makeAthleteSummary(),
        progress: [makeProgressPoint()],
        period: 'week',
      ),
      act: (bloc) =>
          bloc.add(const AthleteStatsPeriodChanged('ath1', 'month')),
      expect: () => [
        isA<AthleteStatsLoaded>().having((s) => s.period, 'period', 'month'),
        isA<AthleteStatsLoaded>()
            .having((s) => s.period, 'period', 'month')
            .having((s) => s.progress.length, 'progressLength', 2),
      ],
    );

    blocTest<AthleteStatsBloc, AthleteStatsState>(
      'AthleteStatsPeriodChanged emits Error when progress fetch fails',
      build: () {
        when(() => analyticsRepo.getAthleteProgress(
              athleteId: any(named: 'athleteId'),
              period: any(named: 'period'),
            )).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      seed: () => AthleteStatsLoaded(
        summary: makeAthleteSummary(),
        progress: [],
        period: 'week',
      ),
      act: (bloc) =>
          bloc.add(const AthleteStatsPeriodChanged('ath1', 'month')),
      expect: () => [
        isA<AthleteStatsLoaded>().having((s) => s.period, 'period', 'month'),
        isA<AthleteStatsError>(),
      ],
    );
  });
}
