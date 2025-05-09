import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

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
        (failure) => emit(AuthError(message: failure.message)),
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
}
