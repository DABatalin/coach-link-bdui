import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/connections/presentation/bloc/find_coach_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockConnectionsRepository connectionsRepo;
  late MockAnalyticsService analytics;

  setUp(() {
    connectionsRepo = MockConnectionsRepository();
    analytics = MockAnalyticsService();
  });

  FindCoachBloc buildBloc() => FindCoachBloc(
        repository: connectionsRepo,
        analytics: analytics,
      );

  group('FindCoachBloc', () {
    test('initial state has empty query and results', () {
      final state = buildBloc().state;
      expect(state.query, isEmpty);
      expect(state.results, isEmpty);
      expect(state.isSearching, false);
    });

    blocTest<FindCoachBloc, FindCoachState>(
      'clears results for query shorter than 2 chars',
      build: buildBloc,
      act: (bloc) => bloc.add(const FindCoachQueryChanged('a')),
      expect: () => [
        isA<FindCoachState>()
            .having((s) => s.query, 'query', 'a')
            .having((s) => s.results, 'results', isEmpty)
            .having((s) => s.isSearching, 'isSearching', false),
      ],
    );

    blocTest<FindCoachBloc, FindCoachState>(
      'emits loading then results for query >= 2 chars',
      build: () {
        when(() => connectionsRepo.searchUsers(
              query: any(named: 'query'),
              role: any(named: 'role'),
            )).thenAnswer(
          (_) async => makePaginated([makeUser(role: 'coach')]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FindCoachQueryChanged('coach')),
      expect: () => [
        isA<FindCoachState>().having((s) => s.isSearching, 'isSearching', true),
        isA<FindCoachState>()
            .having((s) => s.isSearching, 'isSearching', false)
            .having((s) => s.results.length, 'results.length', 1),
      ],
    );

    blocTest<FindCoachBloc, FindCoachState>(
      'emits isSending=false and sentCoachId on successful request',
      build: () {
        when(() => connectionsRepo.sendConnectionRequest(coachId: 'c1'))
            .thenAnswer((_) async => makeRequest());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FindCoachRequestSent('c1')),
      expect: () => [
        isA<FindCoachState>().having((s) => s.isSending, 'isSending', true),
        isA<FindCoachState>()
            .having((s) => s.isSending, 'isSending', false)
            .having((s) => s.sentCoachId, 'sentCoachId', 'c1')
            .having((s) => s.successMessage, 'successMessage', isNotNull),
      ],
    );

    blocTest<FindCoachBloc, FindCoachState>(
      'emits errorMessage on failed request',
      build: () {
        when(() => connectionsRepo.sendConnectionRequest(coachId: any(named: 'coachId')))
            .thenThrow(Exception('Server error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const FindCoachRequestSent('c1')),
      expect: () => [
        isA<FindCoachState>().having((s) => s.isSending, 'isSending', true),
        isA<FindCoachState>()
            .having((s) => s.isSending, 'isSending', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });
}
