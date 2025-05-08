import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/get_current_user.dart';
import '../../../domain/usecases/auth/login_user.dart';
import '../../../domain/usecases/auth/sign_in_with_google.dart';
import '../../../domain/usecases/auth/sign_out_user.dart';
import '../../../domain/usecases/auth/sign_up_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final SignUpUserUseCase _signUpUserUseCase;
  final LoginUserUseCase _loginUserUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUserUseCase _signOutUserUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthProvider({
    required SignUpUserUseCase signUpUserUseCase,
    required LoginUserUseCase loginUserUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignOutUserUseCase signOutUserUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _signUpUserUseCase = signUpUserUseCase,
        _loginUserUseCase = loginUserUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signOutUserUseCase = signOutUserUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  // State variables
  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String _errorMessage = '';
  bool _isPasswordVisible = false;

  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;

  // Text controllers for login and signup
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Initialize the provider
  Future<void> init() async {
    await getCurrentUser();
  }

  // Sign up a new user
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    required Uint8List? file,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await _signUpUserUseCase(
      userName: username,
      email: email,
      password: password,
      file: file,
    );

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }

  // Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await _loginUserUseCase(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final result = await _signInWithGoogleUseCase();

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }

  // Sign out
  Future<bool> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await _signOutUserUseCase();

    return result.fold(
      (failure) {
        _status = AuthStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
        notifyListeners();
        return true;
      },
    );
  }

  // Get current user
  Future<void> getCurrentUser() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        log('Failed to get current user: ${failure.message}');
        _status = AuthStatus.unauthenticated;
        _currentUser = null;
      },
      (user) {
        _status = AuthStatus.authenticated;
        _currentUser = user;
      },
    );

    notifyListeners();
  }

  // Clear form fields
  void clearFormFields() {
    emailController.clear();
    passwordController.clear();
    usernameController.clear();
  }

  // Show error message
  void showErrorSnackBar(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      SnackbarUtils.showSnackBar(_errorMessage, context);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}
