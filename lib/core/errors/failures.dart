// Base failure class
abstract class Failure {
  final String message;

  const Failure({required this.message});
}

// Server failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

// Cache failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Input validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
