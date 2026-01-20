import 'package:dio/dio.dart';

import '../domain/auth_repository.dart';
import '../domain/models/auth_tokens.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<AuthTokens> register({
    required String login,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/register',
      data: {
        'login': login,
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      },
    );
    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthTokens> login({
    required String login,
    required String password,
  }) async {
    final response = await _dio.post(
      '/api/v1/auth/login',
      data: {
        'login': login,
        'password': password,
      },
    );
    return AuthTokens.fromJson(response.data as Map<String, dynamic>);
  }
}
