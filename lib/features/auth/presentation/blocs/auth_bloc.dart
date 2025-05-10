import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_auth.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for authentication
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Constructor
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ChangePasswordEvent>(_onChangePassword);
    on<SendEmailVerificationEvent>(_onSendEmailVerification);
    on<VerifyEmailEvent>(_onVerifyEmail);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<EnableMfaEvent>(_onEnableMfa);
    on<DisableMfaEvent>(_onDisableMfa);
    on<VerifyMfaCodeEvent>(_onVerifyMfaCode);
    on<CheckPermissionEvent>(_onCheckPermission);
    on<GetUserRoleEvent>(_onGetUserRole);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }
  final AuthRepository _authRepository;

  /// Handle check auth status event
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final isAuthenticated = await _authRepository.isUserAuthenticated();

    if (isAuthenticated) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) {
          // Check if the error is related to no current user
          if (failure.message.contains('No user is currently signed in') ||
              failure.message.contains('User data not found')) {
            // If there's no current user or user data, emit Unauthenticated
            // This will trigger navigation to login page
            emit(Unauthenticated());
          } else {
            // For other errors, emit AuthError
            emit(AuthError(message: failure.message));
          }
        },
        (user) => emit(Authenticated(user: user)),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  /// Handle sign in event
  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.loginUser(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  /// Handle sign up event
  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signUpUser(
      userName: event.username,
      email: event.email,
      password: event.password,
      file: event.profileImage,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  /// Handle sign out event
  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signOutUser();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  /// Handle Google sign in event
  Future<void> _onGoogleSignIn(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  /// Handle reset password event
  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.resetPassword(event.email);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const PasswordResetSent(
        message: 'Password reset link sent to your email',
      )),
    );
  }

  /// Handle change password event
  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const PasswordChanged(
        message: 'Password changed successfully',
      )),
    );
  }

  /// Handle send email verification event
  Future<void> _onSendEmailVerification(
    SendEmailVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.sendEmailVerification();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const EmailVerificationSent(
        message: 'Email verification link sent to your email',
      )),
    );
  }

  /// Handle verify email event
  Future<void> _onVerifyEmail(
    VerifyEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.verifyEmail(event.code);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const EmailVerified(
        message: 'Email verified successfully',
      )),
    );
  }

  /// Handle update profile event
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.updateUserProfile(
      userName: event.userName,
      profileImage: event.profileImage,
      status: event.status,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(ProfileUpdated(
        user: user,
        message: 'Profile updated successfully',
      )),
    );
  }

  /// Handle enable MFA event
  Future<void> _onEnableMfa(
    EnableMfaEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.enableMfa();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const MfaEnabled(
        message: 'Multi-factor authentication enabled successfully',
      )),
    );
  }

  /// Handle disable MFA event
  Future<void> _onDisableMfa(
    DisableMfaEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.disableMfa(
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const MfaDisabled(
        message: 'Multi-factor authentication disabled successfully',
      )),
    );
  }

  /// Handle verify MFA code event
  Future<void> _onVerifyMfaCode(
    VerifyMfaCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.verifyMfaCode(event.code);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  /// Handle check permission event
  Future<void> _onCheckPermission(
    CheckPermissionEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.hasPermission(event.permission);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (hasPermission) => emit(PermissionCheckResult(
        permission: event.permission,
        hasPermission: hasPermission,
      )),
    );
  }

  /// Handle get user role event
  Future<void> _onGetUserRole(
    GetUserRoleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.getUserRole();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (role) => emit(UserRoleState(role: role)),
    );
  }

  /// Handle delete account event
  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.deleteAccount(
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AccountDeleted(
        message: 'Account deleted successfully',
      )),
    );
  }
}
