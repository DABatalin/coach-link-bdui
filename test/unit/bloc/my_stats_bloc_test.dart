import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/analytics/presentation/bloc/my_stats_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockAnalyticsRepository analyticsRepo;

  setUp(() {
    analyticsRepo = MockAnalyticsRepository();
  });

  MyStatsBloc buildBloc() => MyStatsBloc(repository: analyticsRepo);

  void stubLoad({String period = 'week'}) {
    when(() => analyticsRepo.getMySummary())
        .thenAnswer((_) async => makeAthleteSummary());
    when(() => analyticsRepo.getMyProgress(period: period))
        .thenAnswer((_) async => [makeProgressPoint()]);
  }

  group('MyStatsBloc', () {
    test('initial state is MyStatsInitial', () {
      expect(buildBloc().state, isA<MyStatsInitial>());
    });

    blocTest<MyStatsBloc, MyStatsState>(
      'emits [Loading, Loaded] on MyStatsLoadRequested',
      build: () {
        stubLoad();
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MyStatsLoadRequested()),
      expect: () => [
        isA<MyStatsLoading>(),
        isA<MyStatsLoaded>()
            .having((s) => s.period, 'period', 'week')
            .having((s) => s.progress.length, 'progressLength', 1),
      ],
    );

    blocTest<MyStatsBloc, MyStatsState>(
      'emits [Loading, Loaded] with custom period',
      build: () {
        stubLoad(period: 'month');
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MyStatsLoadRequested(period: 'month')),
      expect: () => [
        isA<MyStatsLoading>(),
        isA<MyStatsLoaded>().having((s) => s.period, 'period', 'month'),
      ],
    );

    blocTest<MyStatsBloc, MyStatsState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => analyticsRepo.getMySummary())
            .thenThrow(Exception('Network error'));
        when(() => analyticsRepo.getMyProgress(period: any(named: 'period')))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MyStatsLoadRequested()),
      expect: () => [isA<MyStatsLoading>(), isA<MyStatsError>()],
    );

    blocTest<MyStatsBloc, MyStatsState>(
      'MyStatsPeriodChanged updates progress and period',
      build: () {
        when(() => analyticsRepo.getMyProgress(period: 'month'))
            .thenAnswer((_) async => [
                  makeProgressPoint(label: 'Jan'),
                  makeProgressPoint(label: 'Feb'),
                ]);
        return buildBloc();
      },
      seed: () => MyStatsLoaded(
        summary: makeAthleteSummary(),
        progress: [makeProgressPoint()],
        period: 'week',
      ),
      act: (bloc) => bloc.add(const MyStatsPeriodChanged('month')),
      expect: () => [
        isA<MyStatsLoaded>()
            .having((s) => s.period, 'period', 'month')
            .having((s) => s.progress.length, 'progressLength', 2),
      ],
    );

    blocTest<MyStatsBloc, MyStatsState>(
      'MyStatsPeriodChanged emits Error when progress fetch fails',
      build: () {
        when(() => analyticsRepo.getMyProgress(period: any(named: 'period')))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      seed: () => MyStatsLoaded(
        summary: makeAthleteSummary(),
        progress: [],
        period: 'week',
      ),
      act: (bloc) => bloc.add(const MyStatsPeriodChanged('month')),
      expect: () => [isA<MyStatsError>()],
    );
  });
}
