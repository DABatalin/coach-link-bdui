import 'package:bdui_kit/bdui_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Обрабатывает BduiAction в контексте приложения CoachLink.
///
/// RefreshAction не обрабатывается здесь — BLoC должен перехватить его
/// раньше и re-dispatch свой load event.
class BduiActionHandler {
  BduiActionHandler({
    required GoRouter router,
    required Dio dio,
  })  : _router = router,
        _dio = dio;

  final GoRouter _router;
  final Dio _dio;

  void handle(BduiAction action) {
    switch (action) {
      case NavigateAction(:final route):
        _router.go(route);
      case ApiCallAction(:final method, :final url, :final body):
        _handleApiCall(method, url, body);
      case RefreshAction():
        // BLoC должен обработать RefreshAction до вызова этого метода.
        debugPrint('[BDUI] RefreshAction reached handler — should be handled by BLoC');
      case UnknownAction(:final type):
        debugPrint('[BDUI] Unknown action type: $type');
    }
  }

  Future<void> _handleApiCall(
    String method,
    String url,
    Map<String, dynamic>? body,
  ) async {
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          await _dio.get(url);
        case 'POST':
          await _dio.post(url, data: body);
        case 'PUT':
          await _dio.put(url, data: body);
        case 'DELETE':
          await _dio.delete(url);
      }
    } on DioException catch (e) {
      debugPrint('[BDUI] API call failed: $e');
    }
  }
}
