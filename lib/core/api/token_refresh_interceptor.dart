import 'package:dio/dio.dart';

import '../auth/auth_manager.dart';

class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor({
    required AuthManager authManager,
    required Dio dio,
  })  : _authManager = authManager,
        _dio = dio;

  final AuthManager _authManager;
  final Dio _dio;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't try to refresh on auth endpoints
    final path = err.requestOptions.path;
    if (path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh')) {
      return handler.next(err);
    }

    try {
      await _authManager.refreshTokens();

      // Retry original request with new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer ${_authManager.accessToken}';
      final response = await _dio.fetch(opts);
      handler.resolve(response);
    } catch (_) {
      await _authManager.logout();
      handler.next(err);
    }
  }
}
