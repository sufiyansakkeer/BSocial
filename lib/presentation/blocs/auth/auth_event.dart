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
  });

  /// Email
  final String email;

  /// Password
  final String password;

  @override
  List<Object> get props => [email, password];
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
