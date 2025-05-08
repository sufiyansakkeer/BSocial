// Base exception class
class AppException implements Exception {
  AppException({required this.message});
  final String message;
}

// Server exceptions
class ServerException extends AppException {
  ServerException({required super.message});
}

// Authentication exceptions
class AuthException extends AppException {
  AuthException({required super.message});
}

// Cache exceptions
class CacheException extends AppException {
  CacheException({required super.message});
}

// Network exceptions
class NetworkException extends AppException {
  NetworkException({required super.message});
}

// Input validation exceptions
class ValidationException extends AppException {
  ValidationException({required super.message});
}
