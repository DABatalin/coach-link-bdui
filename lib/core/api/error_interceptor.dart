import 'package:dio/dio.dart';

import 'api_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: exception,
    ));
  }

  AppException _mapException(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return const NetworkException();
    }

    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    if (statusCode == null) return const NetworkException();

    final errorBody = data is Map<String, dynamic> ? data['error'] : null;
    final code = errorBody?['code'] as String? ?? '';
    final message = errorBody?['message'] as String? ?? '';

    return switch (statusCode) {
      400 => _parseValidationError(errorBody, message),
      401 => const UnauthorizedException(),
      403 => ForbiddenException(message.isNotEmpty ? message : 'Нет доступа'),
      404 =>
        NotFoundException(message.isNotEmpty ? message : 'Ресурс не найден'),
      409 => ConflictException(code: code, message: message),
      _ => ServerException(
          message.isNotEmpty ? message : 'Ошибка сервера. Попробуйте позже'),
    };
  }

  ValidationException _parseValidationError(
    Map<String, dynamic>? errorBody,
    String message,
  ) {
    final details = errorBody?['details'] as List<dynamic>?;
    final fieldErrors = <String, String>{};
    if (details != null) {
      for (final detail in details) {
        if (detail is Map<String, dynamic>) {
          final field = detail['field'] as String?;
          final msg = detail['message'] as String?;
          if (field != null && msg != null) {
            fieldErrors[field] = msg;
          }
        }
      }
    }
    return ValidationException(
      message: message.isNotEmpty ? message : 'Ошибка валидации',
      fieldErrors: fieldErrors,
    );
  }
}
