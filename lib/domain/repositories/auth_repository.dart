import 'dart:typed_data';
import '../../core/utils/typedefs.dart';
import '../entities/user.dart';

// Authentication repository interface
abstract class AuthRepository {
  // Sign up a new user
  ResultFuture<User> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  });

  // Login a user with email and password
  ResultFuture<User> loginUser({
    required String email,
    required String password,
  });

  // Sign in with Google
  ResultFuture<User> signInWithGoogle();

  // Sign out the current user
  ResultVoid signOutUser();

  // Get the current user details
  ResultFuture<User> getCurrentUser();

  // Reset password for a user
  ResultVoid resetPassword(String email);

  // Check if a user is authenticated
  Future<bool> isUserAuthenticated();
}
