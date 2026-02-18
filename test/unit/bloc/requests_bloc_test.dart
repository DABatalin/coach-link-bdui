import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/connections/presentation/bloc/requests_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockConnectionsRepository connectionsRepo;

  setUp(() {
    connectionsRepo = MockConnectionsRepository();
  });

  RequestsBloc buildBloc() => RequestsBloc(repository: connectionsRepo);

  group('RequestsBloc', () {
    test('initial state is RequestsInitial', () {
      expect(buildBloc().state, isA<RequestsInitial>());
    });

    blocTest<RequestsBloc, RequestsState>(
      'emits [Loading, Loaded] with pending requests',
      build: () {
        when(() => connectionsRepo.getIncomingRequests()).thenAnswer(
          (_) async => makePaginated([
            makeRequest(id: 'r1'),
            makeRequest(id: 'r2'),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RequestsLoadRequested()),
      expect: () => [
        isA<RequestsLoading>(),
        isA<RequestsLoaded>()
            .having((s) => s.requests.length, 'length', 2),
      ],
    );

    blocTest<RequestsBloc, RequestsState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => connectionsRepo.getIncomingRequests())
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RequestsLoadRequested()),
      expect: () => [isA<RequestsLoading>(), isA<RequestsError>()],
    );

    blocTest<RequestsBloc, RequestsState>(
      'RequestAccepted calls acceptRequest and reloads',
      build: () {
        when(() => connectionsRepo.acceptRequest(requestId: 'r1'))
            .thenAnswer((_) async => makeRequest(id: 'r1', status: 'accepted'));
        when(() => connectionsRepo.getIncomingRequests())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RequestAccepted('r1')),
      expect: () => [
        isA<RequestsLoading>(),
        isA<RequestsLoaded>()
            .having((s) => s.requests, 'requests', isEmpty),
      ],
      verify: (_) =>
          verify(() => connectionsRepo.acceptRequest(requestId: 'r1')).called(1),
    );

    blocTest<RequestsBloc, RequestsState>(
      'RequestRejected calls rejectRequest and reloads',
      build: () {
        when(() => connectionsRepo.rejectRequest(requestId: 'r1'))
            .thenAnswer((_) async => makeRequest(id: 'r1', status: 'rejected'));
        when(() => connectionsRepo.getIncomingRequests())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const RequestRejected('r1')),
      verify: (_) =>
          verify(() => connectionsRepo.rejectRequest(requestId: 'r1')).called(1),
    );
  });
}
