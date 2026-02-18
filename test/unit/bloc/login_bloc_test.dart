import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/core/api/api_exceptions.dart';
import 'package:coach_link/features/auth/presentation/bloc/login_bloc.dart';
import 'package:coach_link/features/auth/presentation/bloc/login_event.dart';
import 'package:coach_link/features/auth/presentation/bloc/login_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockAuthRepository authRepo;
  late MockAuthManager authManager;

  setUp(() {
    authRepo = MockAuthRepository();
    authManager = MockAuthManager();
  });

  LoginBloc buildBloc() => LoginBloc(
        repository: authRepo,
        authManager: authManager,
      );

  group('LoginBloc', () {
    test('initial state is LoginInitial', () {
      expect(buildBloc().state, isA<LoginInitial>());
    });

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Success] on valid credentials',
      build: () {
        when(() => authRepo.login(
              login: any(named: 'login'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => makeAuthTokens(role: 'coach'));
        when(() => authManager.saveTokens(
              accessToken: any(named: 'accessToken'),
              refreshToken: any(named: 'refreshToken'),
              user: any(named: 'user'),
            )).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginSubmitted(login: 'coach1', password: '123456')),
      expect: () => [isA<LoginLoading>(), isA<LoginSuccess>()],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Failure] on invalid credentials (401)',
      build: () {
        when(() => authRepo.login(
              login: any(named: 'login'),
              password: any(named: 'password'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          error: const UnauthorizedException('Неверный логин или пароль'),
        ));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginSubmitted(login: 'bad', password: 'wrong')),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginFailure>().having(
          (s) => s.message,
          'message',
          'Неверный логин или пароль',
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Failure] on unknown error',
      build: () {
        when(() => authRepo.login(
              login: any(named: 'login'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginSubmitted(login: 'user', password: 'pass')),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginFailure>().having(
          (s) => s.message,
          'message',
          'Произошла неизвестная ошибка',
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Failure] on server error (AppException via DioException)',
      build: () {
        when(() => authRepo.login(
              login: any(named: 'login'),
              password: any(named: 'password'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ServerException(),
        ));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoginSubmitted(login: 'user', password: 'pass')),
      expect: () => [
        isA<LoginLoading>(),
        isA<LoginFailure>().having(
          (s) => s.message,
          'message',
          contains('сервера'),
        ),
      ],
    );
  });
}
