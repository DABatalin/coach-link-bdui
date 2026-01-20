sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Нет подключения к сети']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Ошибка сервера. Попробуйте позже']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
      [super.message = 'Сессия истекла. Войдите заново']);
}

class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Нет доступа']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Ресурс не найден']);
}

class ValidationException extends AppException {
  const ValidationException({
    required String message,
    this.fieldErrors = const {},
  }) : super(message);

  final Map<String, String> fieldErrors;
}

class ConflictException extends AppException {
  const ConflictException({
    required String message,
    required this.code,
  }) : super(message);

  final String code;
}
