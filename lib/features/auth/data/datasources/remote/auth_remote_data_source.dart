import 'dart:typed_data';

import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_auth.dart';

/// Interface for authentication remote data source
abstract class AuthRemoteDataSource {
  /// Sign up a new user
  Future<UserAuth> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  });

  /// Login a user with email and password
  Future<UserAuth> loginUser({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<UserAuth> signInWithGoogle();

  /// Sign out the current user
  Future<void> signOutUser();

  /// Get the current user details
  Future<UserAuth> getCurrentUser();

  /// Reset password for a user
  Future<void> resetPassword(String email);

  /// Check if a user is authenticated
  Future<bool> isUserAuthenticated();

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Verify email with code
  Future<void> verifyEmail(String code);

  /// Update user profile
  Future<UserAuth> updateUserProfile({
    String? userName,
    Uint8List? profileImage,
    String? status,
  });

  /// Enable multi-factor authentication
  Future<void> enableMfa();

  /// Disable multi-factor authentication
  Future<void> disableMfa({
    required String password,
  });

  /// Verify multi-factor authentication code
  Future<UserAuth> verifyMfaCode(String code);

  /// Check if user has specific permission
  Future<bool> hasPermission(String permission);

  /// Get user role
  Future<UserRole> getUserRole();

  /// Delete user account
  Future<void> deleteAccount({
    required String password,
  });

  /// Get user by ID
  Future<User> getUserById(String userId);

  /// Update user
  Future<User> updateUser({
    required String userId,
    String? userName,
    String? bio,
    Uint8List? profilePic,
  });

  /// Search users
  Future<List<User>> searchUsers(String query);
}

/// Abstract class for [AuthRemoteDataSource] implementation
abstract class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Constructor
  AuthRemoteDataSourceImpl();
}
