import 'models/auth_tokens.dart';

abstract class AuthRepository {
  Future<AuthTokens> register({
    required String login,
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  Future<AuthTokens> login({
    required String login,
    required String password,
  });
}
