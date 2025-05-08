part of 'auth_bloc.dart';

/// Base class for all auth states
abstract class AuthState extends Equatable {
  /// Constructor
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial auth state
class AuthInitial extends AuthState {}

/// Loading auth state
class AuthLoading extends AuthState {}

/// Authenticated state
class Authenticated extends AuthState {
  /// Constructor
  const Authenticated({required this.user});

  /// User
  final User user;

  @override
  List<Object> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {}

/// Error auth state
class AuthError extends AuthState {
  /// Constructor
  const AuthError({required this.message});

  /// Error message
  final String message;

  @override
  List<Object> get props => [message];
}

/// Password reset sent state
class PasswordResetSent extends AuthState {
  /// Constructor
  const PasswordResetSent({required this.message});

  /// Success message
  final String message;

  @override
  List<Object> get props => [message];
}
