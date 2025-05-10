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
  final UserAuth user;

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

/// Password changed state
class PasswordChanged extends AuthState {
  /// Constructor
  const PasswordChanged({required this.message});

  /// Success message
  final String message;

  @override
  List<Object> get props => [message];
}

/// Email verification sent state
class EmailVerificationSent extends AuthState {
  /// Constructor
  const EmailVerificationSent({required this.message});

  /// Success message
  final String message;

  @override
  List<Object> get props => [message];
}

/// Email verified state
class EmailVerified extends AuthState {
  /// Constructor
  const EmailVerified({required this.message});

  /// Success message
  final String message;

  @override
  List<Object> get props => [message];
}

/// Profile updated state
class ProfileUpdated extends AuthState {
  /// Constructor
  const ProfileUpdated({
    required this.user,
    required this.message,
  });

  /// Updated user
  final UserAuth user;

  /// Success message
  final String message;

  @override
  List<Object> get props => [user, message];
}

/// MFA enabled state
class MfaEnabled extends AuthState {
  /// Constructor
  const MfaEnabled({required this.message});

  /// Success message
  final String message;

  @override
  List<Object> get props => [message];
}

/// MFA disabled state
class MfaDisabled extends AuthState {
  /// Constructor
  const MfaDisabled({required this.message});

  /// Success message
  final String message;

  @override
  List<Object> get props => [message];
}

/// MFA verification required state
class MfaVerificationRequired extends AuthState {
  /// Constructor
  const MfaVerificationRequired();
}

/// Permission check result state
class PermissionCheckResult extends AuthState {
  /// Constructor
  const PermissionCheckResult({
    required this.permission,
    required this.hasPermission,
  });

  /// Permission that was checked
  final String permission;

  /// Whether the user has the permission
  final bool hasPermission;

  @override
  List<Object> get props => [permission, hasPermission];
}

/// User role state
class UserRoleState extends AuthState {
  /// Constructor
  const UserRoleState({required this.role});

  /// User role
  final UserRole role;

  @override
  List<Object> get props => [role];
}

/// Account deleted state
class AccountDeleted extends AuthState {
  /// Constructor
  const AccountDeleted({required this.message});

  /// Success message
  final String message;

  @override
  List<Object> get props => [message];
}
