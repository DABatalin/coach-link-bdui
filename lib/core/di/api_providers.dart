import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/auth_interceptor.dart';
import '../api/error_interceptor.dart';
import '../api/token_refresh_interceptor.dart';
import 'auth_providers.dart';

const _defaultBaseUrl = 'http://localhost:8080';

final baseUrlProvider = Provider<String>((_) {
  return const String.fromEnvironment('API_URL', defaultValue: _defaultBaseUrl);
});

/// Raw Dio without interceptors (used for token refresh to avoid loops)
final rawDioProvider = Provider<Dio>((ref) {
  return createDio(baseUrl: ref.watch(baseUrlProvider));
});

/// Main Dio with all interceptors
final dioProvider = Provider<Dio>((ref) {
  final dio = createDio(baseUrl: ref.watch(baseUrlProvider));
  final authManager = ref.watch(authManagerProvider);

  dio.interceptors.addAll([
    LogInterceptor(
      requestHeader: false,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ),
    AuthInterceptor(authManager),
    TokenRefreshInterceptor(authManager: authManager, dio: dio),
    ErrorInterceptor(),
  ]);

  return dio;
});
