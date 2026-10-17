abstract class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message: message, statusCode: 0);
}

class ValidationException extends AppException {
  const ValidationException(String message, {int? statusCode})
      : super(message: message, statusCode: statusCode ?? 422);
}

class NotFoundException extends AppException {
  const NotFoundException(String message)
      : super(message: message, statusCode: 404);
}

class ConflictException extends AppException {
  const ConflictException(String message)
      : super(message: message, statusCode: 409);
}

class ServerException extends AppException {
  const ServerException(String message, {int? statusCode})
      : super(message: message, statusCode: statusCode ?? 500);
}
