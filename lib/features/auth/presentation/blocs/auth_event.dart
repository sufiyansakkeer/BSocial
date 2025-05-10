part of 'auth_bloc.dart';

/// Base class for all auth events
abstract class AuthEvent extends Equatable {
  /// Constructor
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status
class CheckAuthStatusEvent extends AuthEvent {}

/// Event to sign in
class SignInEvent extends AuthEvent {
  /// Constructor
  const SignInEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  /// Email
  final String email;

  /// Password
  final String password;

  /// Remember me flag
  final bool rememberMe;

  @override
  List<Object> get props => [email, password, rememberMe];
}

/// Event to sign up
class SignUpEvent extends AuthEvent {
  /// Constructor
  const SignUpEvent({
    required this.username,
    required this.email,
    required this.password,
    this.profileImage,
  });

  /// Username
  final String username;

  /// Email
  final String email;

  /// Password
  final String password;

  /// Profile image
  final Uint8List? profileImage;

  @override
  List<Object?> get props => [username, email, password, profileImage];
}

/// Event to sign out
class SignOutEvent extends AuthEvent {
  /// Constructor
  const SignOutEvent({this.isUserInitiated = true});

  /// Flag to indicate if the event is initiated by the user
  final bool isUserInitiated;

  @override
  List<Object> get props => [isUserInitiated];
}

/// Event to sign in with Google
class GoogleSignInEvent extends AuthEvent {}

/// Event to reset password
class ResetPasswordEvent extends AuthEvent {
  /// Constructor
  const ResetPasswordEvent({required this.email});

  /// Email
  final String email;

  @override
  List<Object> get props => [email];
}

/// Event to change password
class ChangePasswordEvent extends AuthEvent {
  /// Constructor
  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  /// Current password
  final String currentPassword;

  /// New password
  final String newPassword;

  @override
  List<Object> get props => [currentPassword, newPassword];
}

/// Event to send email verification
class SendEmailVerificationEvent extends AuthEvent {}

/// Event to verify email with code
class VerifyEmailEvent extends AuthEvent {
  /// Constructor
  const VerifyEmailEvent({required this.code});

  /// Verification code
  final String code;

  @override
  List<Object> get props => [code];
}

/// Event to update user profile
class UpdateProfileEvent extends AuthEvent {
  /// Constructor
  const UpdateProfileEvent({
    this.userName,
    this.profileImage,
    this.status,
  });

  /// New username
  final String? userName;

  /// New profile image
  final Uint8List? profileImage;

  /// New status
  final String? status;

  @override
  List<Object?> get props => [userName, profileImage, status];
}

/// Event to enable MFA
class EnableMfaEvent extends AuthEvent {}

/// Event to disable MFA
class DisableMfaEvent extends AuthEvent {
  /// Constructor
  const DisableMfaEvent({required this.password});

  /// Password for verification
  final String password;

  @override
  List<Object> get props => [password];
}

/// Event to verify MFA code
class VerifyMfaCodeEvent extends AuthEvent {
  /// Constructor
  const VerifyMfaCodeEvent({required this.code});

  /// MFA code
  final String code;

  @override
  List<Object> get props => [code];
}

/// Event to check user permission
class CheckPermissionEvent extends AuthEvent {
  /// Constructor
  const CheckPermissionEvent({required this.permission});

  /// Permission to check
  final String permission;

  @override
  List<Object> get props => [permission];
}

/// Event to get user role
class GetUserRoleEvent extends AuthEvent {}

/// Event to delete account
class DeleteAccountEvent extends AuthEvent {
  /// Constructor
  const DeleteAccountEvent({required this.password});

  /// Password for verification
  final String password;

  @override
  List<Object> get props => [password];
}
