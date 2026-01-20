import 'package:dio/dio.dart';

import '../auth/auth_manager.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authManager);
  final AuthManager _authManager;

  static const _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_publicPaths.any((p) => options.path.contains(p))) {
      return handler.next(options);
    }
    final token = _authManager.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
