import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/datasources/local/storage_local_data_source.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_auth.dart';
import '../../models/user_auth_model.dart';

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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
    required StorageLocalDataSource storageDataSource,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn,
        _storageDataSource = storageDataSource;
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final StorageLocalDataSource _storageDataSource;

  @override
  Future<UserAuthModel> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw AuthException(message: 'No user is currently signed in');
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException(message: 'User data not found');
      }

      return UserAuthModel(
        email: userDoc['email'] ?? '',
        uid: userDoc['uid'] ?? '',
        photoUrl: userDoc['photoUrl'] ?? '',
        userName: userDoc['userName'] ?? '',
        followers: List<String>.from(userDoc['followers'] ?? []),
        following: List<String>.from(userDoc['following'] ?? []),
        status: userDoc['status'] ?? 'offline',
      );
    } on FirebaseException catch (e) {
      log('Firebase error getting current user: $e');
      throw AuthException(
          message: 'Failed to get current user: ${e.toString()}');
    } catch (e) {
      log('Error getting current user: $e');
      throw AuthException(
          message: 'Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserAuthenticated() async => _auth.currentUser != null;

  @override
  Future<UserAuthModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty) {
        throw AuthException(message: 'Email cannot be empty');
      }

      if (password.isEmpty) {
        throw AuthException(message: 'Password cannot be empty');
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException(message: 'Login failed');
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      return UserAuthModel(
        email: userDoc['email'] ?? '',
        uid: userDoc['uid'] ?? '',
        photoUrl: userDoc['photoUrl'] ?? '',
        userName: userDoc['userName'] ?? '',
        followers: List<String>.from(userDoc['followers'] ?? []),
        following: List<String>.from(userDoc['following'] ?? []),
        status: userDoc['status'] ?? 'offline',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException(message: 'User not found');
      } else if (e.code == 'wrong-password') {
        throw AuthException(message: 'Wrong password');
      } else if (e.code == 'invalid-email') {
        throw AuthException(message: 'Invalid email format');
      } else {
        throw AuthException(message: e.message ?? 'Authentication failed');
      }
    } catch (e) {
      log('Login error: $e');
      throw AuthException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log('Reset password error: $e');
      throw AuthException(message: 'Failed to reset password: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Get current user
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user is currently signed in');
      }

      // Get user email
      final email = user.email;
      if (email == null) {
        throw AuthException(message: 'User has no email');
      }

      // Re-authenticate user with current password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } catch (e) {
      log('Change password error: $e');
      throw AuthException(
          message: 'Failed to change password: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user is currently signed in');
      }

      await user.sendEmailVerification();
    } catch (e) {
      log('Send email verification error: $e');
      throw AuthException(
          message: 'Failed to send email verification: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyEmail(String code) async {
    try {
      // Firebase doesn't have a direct API for verifying email with code
      // This would typically be handled by the user clicking a link in their email
      // This is a placeholder implementation
      throw AuthException(
          message: 'Email verification with code not supported by Firebase');
    } catch (e) {
      log('Verify email error: $e');
      throw AuthException(message: 'Failed to verify email: ${e.toString()}');
    }
  }

  @override
  Future<UserAuthModel> updateUserProfile({
    String? userName,
    Uint8List? profileImage,
    String? status,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user is currently signed in');
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException(message: 'User data not found');
      }

      final updates = <String, dynamic>{};

      // Update username if provided
      if (userName != null && userName.isNotEmpty) {
        updates['userName'] = userName;
      }

      // Update status if provided
      if (status != null) {
        updates['status'] = status;
      }

      // Upload new profile image if provided
      if (profileImage != null) {
        final photoUrl = await _storageDataSource.uploadImage(
          AppConstants.profilePicsPath,
          profileImage, // This is the Uint8List? profileImage parameter
          isPost: false,
        );
        updates['photoUrl'] = photoUrl;
      }

      // Update Firestore document
      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update(updates);
      }

      // Get updated user data
      final updatedUserDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      return UserAuthModel.fromSnapshot(updatedUserDoc);
    } catch (e) {
      log('Update user profile error: $e');
      throw AuthException(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> enableMfa() async {
    try {
      // Firebase doesn't directly support TOTP MFA through the SDK
      // This would typically involve additional setup with a third-party MFA provider
      // This is a placeholder implementation
      throw AuthException(message: 'MFA enablement not implemented');
    } catch (e) {
      log('Enable MFA error: $e');
      throw AuthException(message: 'Failed to enable MFA: ${e.toString()}');
    }
  }

  @override
  Future<void> disableMfa({required String password}) async {
    try {
      // Firebase doesn't directly support TOTP MFA through the SDK
      // This would typically involve additional setup with a third-party MFA provider
      // This is a placeholder implementation
      throw AuthException(message: 'MFA disablement not implemented');
    } catch (e) {
      log('Disable MFA error: $e');
      throw AuthException(message: 'Failed to disable MFA: ${e.toString()}');
    }
  }

  @override
  Future<UserAuthModel> verifyMfaCode(String code) async {
    try {
      // Firebase doesn't directly support TOTP MFA through the SDK
      // This would typically involve additional setup with a third-party MFA provider
      // This is a placeholder implementation
      throw AuthException(message: 'MFA verification not implemented');
    } catch (e) {
      log('Verify MFA code error: $e');
      throw AuthException(
          message: 'Failed to verify MFA code: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasPermission(String permission) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user is currently signed in');
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException(message: 'User data not found');
      }

      // Check if user is admin (admins have all permissions)
      final role = userDoc['role'] as String? ?? 'user';
      if (role == 'admin') {
        return true;
      }

      // Check specific permission
      final permissions = List<String>.from(userDoc['permissions'] ?? []);
      return permissions.contains(permission);
    } catch (e) {
      log('Check permission error: $e');
      throw AuthException(
          message: 'Failed to check permission: ${e.toString()}');
    }
  }

  @override
  Future<UserRole> getUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user is currently signed in');
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException(message: 'User data not found');
      }

      final roleStr = userDoc['role'] as String? ?? 'user';
      switch (roleStr) {
        case 'admin':
          return UserRole.admin;
        case 'moderator':
          return UserRole.moderator;
        default:
          return UserRole.user;
      }
    } catch (e) {
      log('Get user role error: $e');
      throw AuthException(message: 'Failed to get user role: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user is currently signed in');
      }

      final email = user.email;
      if (email == null) {
        throw AuthException(message: 'User has no email');
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete user account
      await user.delete();
    } catch (e) {
      log('Delete account error: $e');
      throw AuthException(message: 'Failed to delete account: ${e.toString()}');
    }
  }

  @override
  Future<UserAuthModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException(message: 'Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw AuthException(message: 'Google sign in failed');
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      // If new user, create a document in Firestore
      if (!userDoc.exists) {
        final user = userCredential.user!;

        final userModel = UserAuthModel(
          email: user.email ?? '',
          uid: user.uid,
          photoUrl: user.photoURL ?? '',
          userName: user.displayName ?? '',
          followers: const [],
          following: const [],
          status: 'online',
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toJson());

        return userModel;
      }

      return UserAuthModel(
        email: userDoc['email'] ?? '',
        uid: userDoc['uid'] ?? '',
        photoUrl: userDoc['photoUrl'] ?? '',
        userName: userDoc['userName'] ?? '',
        followers: List<String>.from(userDoc['followers'] ?? []),
        following: List<String>.from(userDoc['following'] ?? []),
        status: userDoc['status'] ?? 'offline',
      );
    } catch (e) {
      log('Google sign in error: $e');
      throw AuthException(message: 'Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOutUser() async {
    // Log the sign-out attempt
    log('Attempting to sign out user...');

    try {
      // Update user status to offline
      if (_auth.currentUser != null) {
        // Check if user document exists before updating
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(_auth.currentUser!.uid)
            .get();

        if (userDoc.exists) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(_auth.currentUser!.uid)
              .update({'status': 'offline'});

          log('User status updated to offline in Firestore.');
        } else {
          log('User document not found in Firestore. Skipping status update.');
        }
      } else {
        log('No user currently signed in. Skipping Firestore status update.');
      }

      // Sign out from Google Sign-In
      await _googleSignIn.signOut();
      log('Signed out from Google Sign-In (if applicable).');

      // Sign out from Firebase Authentication
      await _auth.signOut();
      log('Signed out from Firebase Authentication.');

      // Log successful sign-out
      log('User signed out successfully.');
    } catch (e) {
      // Log the error with details
      log('Sign out error: $e');
      throw AuthException(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserAuthModel> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  }) async {
    try {
      if (userName.isEmpty) {
        throw AuthException(message: 'Username cannot be empty');
      }

      if (email.isEmpty) {
        throw AuthException(message: 'Email cannot be empty');
      }

      if (password.isEmpty) {
        throw AuthException(message: 'Password cannot be empty');
      }

      if (file == null) {
        throw AuthException(message: 'Profile image is required');
      }

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException(message: 'Failed to create user');
      }

      // Upload profile image
      final photoUrl = await _storageDataSource.uploadImage(
        AppConstants.profilePicsPath,
        file, // This is the Uint8List? file parameter from signUpUser
        isPost: false,
      );

      // Create user model
      final userModel = UserAuthModel(
        email: email,
        uid: userCredential.user!.uid,
        photoUrl: photoUrl,
        userName: userName,
        followers: const [],
        following: const [],
        status: 'online',
      );

      // Save user data to Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .set(userModel.toJson());

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException(message: 'Password is too weak');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException(message: 'Email is already in use');
      } else if (e.code == 'invalid-email') {
        throw AuthException(message: 'Invalid email format');
      } else {
        throw AuthException(message: e.message ?? 'Sign up failed');
      }
    } catch (e) {
      log('Sign up error: $e');
      throw AuthException(message: 'Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<User> getUserById(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        throw AuthException(message: 'User not found');
      }

      final userData = docSnapshot.data() as Map<String, dynamic>;

      return User(
        uid: userId,
        email: userData['email'] as String,
        userName: userData['userName'] as String,
        photoUrl: userData['photoUrl'] as String,
        bio: userData['bio'] as String? ?? '',
        followers: List<String>.from(userData['followers'] as List? ?? []),
        following: List<String>.from(userData['following'] as List? ?? []),
        status: userData['status'] as String? ?? 'Available',
        isMfaEnabled: userData['isMfaEnabled'] as bool? ?? false,
        isEmailVerified: userData['isEmailVerified'] as bool? ?? false,
      );
    } catch (e) {
      log('Error getting user by ID: $e');
      throw AuthException(message: 'Failed to get user: $e');
    }
  }

  @override
  Future<User> updateUser({
    required String userId,
    String? userName,
    String? bio,
    Uint8List? profilePic,
  }) async {
    try {
      final userRef =
          _firestore.collection(AppConstants.usersCollection).doc(userId);

      final updateData = <String, dynamic>{};
      if (userName != null) updateData['userName'] = userName;
      if (bio != null) updateData['bio'] = bio;

      // Upload profile picture if provided
      if (profilePic != null) {
        final photoUrl = await _storageDataSource.uploadImage(
          AppConstants.profilePicsPath,
          profilePic,
          isPost: false,
        );
        updateData['photoUrl'] = photoUrl;
      }

      await userRef.update(updateData);

      // Get the updated user
      return getUserById(userId);
    } catch (e) {
      log('Error updating user: $e');
      throw AuthException(message: 'Failed to update user: $e');
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('userName', isGreaterThanOrEqualTo: query)
          .where('userName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          uid: doc.id,
          email: data['email'] as String,
          userName: data['userName'] as String,
          photoUrl: data['photoUrl'] as String,
          bio: data['bio'] as String? ?? '',
          followers: List<String>.from(data['followers'] as List? ?? []),
          following: List<String>.from(data['following'] as List? ?? []),
          status: data['status'] as String? ?? 'Available',
          isMfaEnabled: data['isMfaEnabled'] as bool? ?? false,
          isEmailVerified: data['isEmailVerified'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      log('Error searching users: $e');
      throw AuthException(message: 'Failed to search users: $e');
    }
  }
}
