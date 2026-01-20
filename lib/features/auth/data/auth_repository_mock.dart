import '../domain/auth_repository.dart';
import '../domain/models/auth_tokens.dart';
import '../domain/models/user.dart';

class AuthRepositoryMock implements AuthRepository {
  static const _fakeCoach = {
    'id': '11111111-1111-1111-1111-111111111111',
    'login': 'coach-maria',
    'email': 'maria@example.com',
    'full_name': 'Сидорова Мария Александровна',
    'role': 'coach',
    'created_at': '2026-01-15T10:00:00Z',
  };

  static const _fakeAthlete = {
    'id': '22222222-2222-2222-2222-222222222222',
    'login': 'ivan-petrov',
    'email': 'ivan@example.com',
    'full_name': 'Петров Иван Сергеевич',
    'role': 'athlete',
    'created_at': '2026-02-20T10:00:00Z',
  };

  // Fake JWT — header.payload.signature (payload contains role)
  static String _fakeJwt(String role) {
    // Not a real JWT, but has 3 dots so AuthManager won't crash
    return 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.'
        'eyJzdWIiOiIxMjM0NTY3ODkwIiwicm9sZSI6IiRyb2xlIiwiZXhwIjo5OTk5OTk5OTk5fQ.'
        'fake_signature';
  }

  @override
  Future<AuthTokens> login({
    required String login,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Any login starting with "coach" → coach role, otherwise athlete
    final isCoach = login.toLowerCase().startsWith('coach');
    final userData = isCoach ? _fakeCoach : _fakeAthlete;

    return AuthTokens(
      accessToken: _fakeJwt(userData['role']!),
      refreshToken: 'fake_refresh_token',
      expiresIn: 900,
      user: User.fromJson(Map<String, dynamic>.from(userData)),
    );
  }

  @override
  Future<AuthTokens> register({
    required String login,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final userData = {
      'id': '33333333-3333-3333-3333-333333333333',
      'login': login,
      'email': email,
      'full_name': fullName,
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
    };

    return AuthTokens(
      accessToken: _fakeJwt(role),
      refreshToken: 'fake_refresh_token',
      expiresIn: 900,
      user: User.fromJson(userData),
    );
  }
}
