import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/connections/presentation/bloc/my_coach_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockConnectionsRepository connectionsRepo;

  setUp(() {
    connectionsRepo = MockConnectionsRepository();
  });

  MyCoachBloc buildBloc() => MyCoachBloc(repository: connectionsRepo);

  DioException make404() => DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
      );

  group('MyCoachBloc', () {
    test('initial state is MyCoachInitial', () {
      expect(buildBloc().state, isA<MyCoachInitial>());
    });

    blocTest<MyCoachBloc, MyCoachState>(
      'emits [Loading, MyCoachConnected] when athlete has a coach',
      build: () {
        when(() => connectionsRepo.getAthleteCoach())
            .thenAnswer((_) async => makeCoachInfo());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MyCoachLoadRequested()),
      expect: () => [
        isA<MyCoachLoading>(),
        isA<MyCoachConnected>()
            .having((s) => s.coach.fullName, 'coach.fullName', 'Coach One'),
      ],
    );

    blocTest<MyCoachBloc, MyCoachState>(
      'emits [Loading, MyCoachPending] when there is a pending outgoing request',
      build: () {
        when(() => connectionsRepo.getAthleteCoach()).thenThrow(make404());
        when(() => connectionsRepo.getOutgoingRequest())
            .thenAnswer((_) async => makeRequest(status: 'pending'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MyCoachLoadRequested()),
      expect: () => [
        isA<MyCoachLoading>(),
        isA<MyCoachPending>(),
      ],
    );

    blocTest<MyCoachBloc, MyCoachState>(
      'emits [Loading, MyCoachNone] when no coach and no pending request',
      build: () {
        when(() => connectionsRepo.getAthleteCoach()).thenThrow(make404());
        when(() => connectionsRepo.getOutgoingRequest())
            .thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MyCoachLoadRequested()),
      expect: () => [isA<MyCoachLoading>(), isA<MyCoachNone>()],
    );

    blocTest<MyCoachBloc, MyCoachState>(
      'emits [Loading, MyCoachNone] when getOutgoingRequest throws',
      build: () {
        when(() => connectionsRepo.getAthleteCoach()).thenThrow(make404());
        when(() => connectionsRepo.getOutgoingRequest())
            .thenThrow(Exception('Error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MyCoachLoadRequested()),
      expect: () => [isA<MyCoachLoading>(), isA<MyCoachNone>()],
    );

    blocTest<MyCoachBloc, MyCoachState>(
      'emits [Loading, MyCoachError] on non-404 DioException',
      build: () {
        when(() => connectionsRepo.getAthleteCoach()).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: ''),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const MyCoachLoadRequested()),
      expect: () => [isA<MyCoachLoading>(), isA<MyCoachError>()],
    );
  });
}
