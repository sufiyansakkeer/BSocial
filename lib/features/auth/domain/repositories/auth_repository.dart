import 'dart:typed_data';
import '../../../../core/utils/typedefs.dart';
import '../entities/user.dart';
import '../entities/user_auth.dart';

/// Authentication repository interface
///
/// Defines the contract for authentication operations
abstract class AuthRepository {
  /// Sign up a new user
  ResultFuture<UserAuth> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  });

  /// Login a user with email and password
  ResultFuture<UserAuth> loginUser({
    required String email,
    required String password,
  });

  /// Sign in with Google
  ResultFuture<UserAuth> signInWithGoogle();

  /// Sign out the current user
  ResultVoid signOutUser();

  /// Get the current user details
  ResultFuture<UserAuth> getCurrentUser();

  /// Reset password for a user
  ResultVoid resetPassword(String email);

  /// Check if a user is authenticated
  Future<bool> isUserAuthenticated();

  /// Change user password
  ResultVoid changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Send email verification
  ResultVoid sendEmailVerification();

  /// Verify email with code
  ResultVoid verifyEmail(String code);

  /// Update user profile
  ResultFuture<UserAuth> updateUserProfile({
    String? userName,
    Uint8List? profileImage,
    String? status,
  });

  /// Enable multi-factor authentication
  ResultVoid enableMfa();

  /// Disable multi-factor authentication
  ResultVoid disableMfa({
    required String password,
  });

  /// Verify multi-factor authentication code
  ResultFuture<UserAuth> verifyMfaCode(String code);

  /// Check if user has specific permission
  ResultFuture<bool> hasPermission(String permission);

  /// Get user role
  ResultFuture<UserRole> getUserRole();

  /// Delete user account
  ResultVoid deleteAccount({
    required String password,
  });

  /// Get user by ID
  ResultFuture<User> getUserById(String userId);

  /// Update user
  ResultFuture<User> updateUser({
    required String userId,
    String? userName,
    String? bio,
    Uint8List? profilePic,
  });

  /// Search users
  ResultFuture<List<User>> searchUsers(String query);
}
