import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/auth/auth_manager.dart';
import '../../domain/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required AuthRepository repository,
    required AuthManager authManager,
    required AnalyticsService analytics,
  })  : _repository = repository,
        _authManager = authManager,
        _analytics = analytics,
        super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthRepository _repository;
  final AuthManager _authManager;
  final AnalyticsService _analytics;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      final tokens = await _repository.login(
        login: event.login,
        password: event.password,
      );
      await _authManager.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        user: tokens.user.toJson(),
      );
      await _analytics.logLogin();
      emit(const LoginSuccess());
    } on DioException catch (e) {
      final error = e.error;
      if (error is AppException) {
        emit(LoginFailure(error.message));
      } else {
        emit(const LoginFailure('Ошибка подключения к серверу'));
      }
    } catch (e, stack) {
      await _analytics.recordError(e, stack);
      emit(const LoginFailure('Произошла неизвестная ошибка'));
    }
  }
}
