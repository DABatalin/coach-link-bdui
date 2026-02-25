import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/auth/auth_manager.dart';
import '../../domain/auth_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    required AuthRepository repository,
    required AuthManager authManager,
    required AnalyticsService analytics,
  })  : _repository = repository,
        _authManager = authManager,
        _analytics = analytics,
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  final AuthRepository _repository;
  final AuthManager _authManager;
  final AnalyticsService _analytics;

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());
    try {
      final tokens = await _repository.register(
        login: event.login,
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        role: event.role,
      );
      await _authManager.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        user: tokens.user.toJson(),
      );
      await _analytics.logSignUp(role: event.role);
      emit(const RegisterSuccess());
    } on DioException catch (e) {
      final error = e.error;
      if (error is ValidationException) {
        emit(RegisterFailure(
          message: error.message,
          fieldErrors: error.fieldErrors,
        ));
      } else if (error is ConflictException) {
        emit(RegisterFailure(
          message: error.message,
          fieldErrors:
              error.code == 'LOGIN_ALREADY_EXISTS' ? {'login': error.message} : {},
        ));
      } else if (error is AppException) {
        emit(RegisterFailure(message: error.message));
      } else {
        emit(const RegisterFailure(message: 'Ошибка подключения к серверу'));
      }
    } catch (e, stack) {
      await _analytics.recordError(e, stack);
      emit(const RegisterFailure(message: 'Произошла неизвестная ошибка'));
    }
  }
}
