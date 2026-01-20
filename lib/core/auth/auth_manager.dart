import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_state.dart';

class AuthManager {
  AuthManager({
    required FlutterSecureStorage secureStorage,
    required Dio dio,
  })  : _storage = secureStorage,
        _dio = dio;

  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user_data';

  String? _accessToken;
  String? _refreshToken;

  final _controller = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateStream => _controller.stream;

  AuthState _currentState = const AuthInitial();
  AuthState get currentState => _currentState;

  String? get accessToken => _accessToken;

  Future<void> init() async {
    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshToken = await _storage.read(key: _refreshTokenKey);
    final userData = await _storage.read(key: _userKey);

    if (_accessToken == null || _refreshToken == null || userData == null) {
      _emit(const Unauthenticated());
      return;
    }

    // Decode JWT to check expiration
    if (_isTokenExpired(_accessToken!)) {
      try {
        await refreshTokens();
      } catch (_) {
        await _clearTokens();
        _emit(const Unauthenticated());
      }
    } else {
      _emitAuthenticated(userData);
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userKey, value: jsonEncode(user));
    _emitAuthenticated(jsonEncode(user));
  }

  Future<void> refreshTokens() async {
    if (_refreshToken == null) throw Exception('No refresh token');

    final response = await _dio.post(
      '/api/v1/auth/refresh',
      data: {'refresh_token': _refreshToken},
    );

    final data = response.data as Map<String, dynamic>;
    await saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      user: data['user'] as Map<String, dynamic>,
    );
  }

  Future<void> logout() async {
    if (_refreshToken != null) {
      try {
        await _dio.post(
          '/api/v1/auth/logout',
          data: {'refresh_token': _refreshToken},
          options: Options(
            headers: {'Authorization': 'Bearer $_accessToken'},
          ),
        );
      } catch (_) {
        // Ignore logout API errors — clear local state regardless
      }
    }
    await _clearTokens();
    _emit(const Unauthenticated());
  }

  Future<void> _clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  void _emitAuthenticated(String userJson) {
    final user = jsonDecode(userJson) as Map<String, dynamic>;
    _emit(Authenticated(
      userId: user['id'] as String,
      login: user['login'] as String,
      fullName: user['full_name'] as String,
      role: user['role'] as String,
    ));
  }

  void _emit(AuthState state) {
    _currentState = state;
    _controller.add(state);
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = data['exp'] as int?;
      if (exp == null) return true;

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Consider expired 30 seconds before actual expiration
      return DateTime.now().isAfter(expDate.subtract(const Duration(seconds: 30)));
    } catch (_) {
      return true;
    }
  }

  void dispose() {
    _controller.close();
  }
}
