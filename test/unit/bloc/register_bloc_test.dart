import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/core/api/api_exceptions.dart';
import 'package:coach_link/features/auth/presentation/bloc/register_bloc.dart';
import 'package:coach_link/features/auth/presentation/bloc/register_event.dart';
import 'package:coach_link/features/auth/presentation/bloc/register_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockAuthRepository authRepo;
  late MockAuthManager authManager;
  late MockAnalyticsService analytics;

  const validEvent = RegisterSubmitted(
    login: 'newuser',
    email: 'new@example.com',
    password: 'password123',
    fullName: 'New User',
    role: 'athlete',
  );

  setUp(() {
    authRepo = MockAuthRepository();
    authManager = MockAuthManager();
    analytics = MockAnalyticsService();
  });

  RegisterBloc buildBloc() => RegisterBloc(
        repository: authRepo,
        authManager: authManager,
        analytics: analytics,
      );

  group('RegisterBloc', () {
    test('initial state is RegisterInitial', () {
      expect(buildBloc().state, isA<RegisterInitial>());
    });

    blocTest<RegisterBloc, RegisterState>(
      'emits [Loading, Success] on successful registration',
      build: () {
        when(() => authRepo.register(
              login: any(named: 'login'),
              email: any(named: 'email'),
              password: any(named: 'password'),
              fullName: any(named: 'fullName'),
              role: any(named: 'role'),
            )).thenAnswer((_) async => makeAuthTokens(role: 'athlete'));
        when(() => authManager.saveTokens(
              accessToken: any(named: 'accessToken'),
              refreshToken: any(named: 'refreshToken'),
              user: any(named: 'user'),
            )).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => [isA<RegisterLoading>(), isA<RegisterSuccess>()],
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [Loading, Failure] on login conflict (409 LOGIN_ALREADY_EXISTS)',
      build: () {
        when(() => authRepo.register(
              login: any(named: 'login'),
              email: any(named: 'email'),
              password: any(named: 'password'),
              fullName: any(named: 'fullName'),
              role: any(named: 'role'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ConflictException(
            message: 'Логин уже занят',
            code: 'LOGIN_ALREADY_EXISTS',
          ),
        ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => [
        isA<RegisterLoading>(),
        isA<RegisterFailure>()
            .having((s) => s.fieldErrors.containsKey('login'), 'has login error', true),
      ],
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [Loading, Failure] with fieldErrors on validation error',
      build: () {
        when(() => authRepo.register(
              login: any(named: 'login'),
              email: any(named: 'email'),
              password: any(named: 'password'),
              fullName: any(named: 'fullName'),
              role: any(named: 'role'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ValidationException(
            message: 'Неверный формат email',
            fieldErrors: {'email': 'Неверный формат email'},
          ),
        ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => [
        isA<RegisterLoading>(),
        isA<RegisterFailure>()
            .having((s) => s.fieldErrors['email'], 'email error', isNotNull),
      ],
    );

    blocTest<RegisterBloc, RegisterState>(
      'emits [Loading, Failure] on unknown error',
      build: () {
        when(() => authRepo.register(
              login: any(named: 'login'),
              email: any(named: 'email'),
              password: any(named: 'password'),
              fullName: any(named: 'fullName'),
              role: any(named: 'role'),
            )).thenThrow(Exception('Unknown'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => [isA<RegisterLoading>(), isA<RegisterFailure>()],
    );
  });
}
