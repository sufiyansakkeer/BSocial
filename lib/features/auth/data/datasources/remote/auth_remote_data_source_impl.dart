import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/datasources/local/storage_local_data_source.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/utils/retry_util.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_auth.dart';
import '../../models/user_auth_model.dart';
import 'auth_remote_data_source.dart';

/// Implementation of [AuthRemoteDataSource] with all methods implemented
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Constructor
  AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
    required StorageLocalDataSource storageDataSource,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn,
        _storageDataSource = storageDataSource;

  /// Firebase Authentication instance
  final firebase_auth.FirebaseAuth _auth;

  /// Firestore instance
  final FirebaseFirestore _firestore;

  /// Google Sign-In instance
  final GoogleSignIn _googleSignIn;

  /// Storage data source for file operations
  final StorageLocalDataSource _storageDataSource;

  /// Public getter for Firestore instance
  FirebaseFirestore get firestore => _firestore;

  @override
  Future<UserAuth> signUpUser({
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

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw AuthException(message: 'Failed to create user');
      }

      // Upload profile image if provided
      var photoUrl = '';
      if (file != null) {
        photoUrl = await _storageDataSource.uploadImage(
          AppConstants.profilePicsPath,
          file,
          isPost: false,
        );
      }

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
      log('Sign up error: $e', name: 'signUpUser');
      _handleException(e, 'Sign up');
    }
  }

  @override
  Future<UserAuth> loginUser({
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
      log('Login error: $e', name: 'loginUser');
      throw AuthException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserAuth> signInWithGoogle() async {
    try {
      log('Starting Google sign-in process...', name: 'signInWithGoogle');

      // Check network connectivity first
      final isConnected = await _checkNetworkConnectivity();
      if (!isConnected) {
        log('Network connectivity issue detected', name: 'signInWithGoogle');
        throw AuthException(
            message: 'No internet connection. '
                'Please check your network settings and try again.');
      }

      // Attempt to sign in with Google
      log('Attempting to show Google sign-in UI...', name: 'signInWithGoogle');
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        log('Google sign-in was cancelled by user or failed silently',
            name: 'signInWithGoogle');
        throw AuthException(message: 'Google sign in was cancelled');
      }

      log('Google sign-in successful for user: ${googleUser.email}',
          name: 'signInWithGoogle');

      // Get authentication tokens
      log('Retrieving Google authentication tokens...',
          name: 'signInWithGoogle');
      final googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      log('Signing in to Firebase with Google credential...',
          name: 'signInWithGoogle');
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        log('Firebase sign-in failed after Google authentication',
            name: 'signInWithGoogle');
        throw AuthException(
            message: 'Google sign in failed during Firebase authentication');
      }

      log('Firebase auth successful for UID: ${userCredential.user!.uid}',
          name: 'signInWithGoogle');

      // Check if user exists in Firestore
      log('Checking if user exists in Firestore...', name: 'signInWithGoogle');
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      // If new user, create a document in Firestore
      if (!userDoc.exists) {
        log('Creating new user document in Firestore...',
            name: 'signInWithGoogle');
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

        log('New user created successfully in Firestore',
            name: 'signInWithGoogle');
        return userModel;
      }

      log('Existing user found in Firestore, returning user data',
          name: 'signInWithGoogle');
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
      log('Firebase Auth Exception: ${e.code} - ${e.message}',
          name: 'signInWithGoogle');
      throw AuthException(message: 'Authentication error: ${e.message}');
    } on Exception catch (e) {
      log('Google sign in error (Exception): $e', name: 'signInWithGoogle');

      // Handle network errors specifically
      if (e.toString().contains('network_error') ||
          e.toString().contains('ApiException: 7')) {
        throw AuthException(
            message: 'Network error during Google sign-in. '
                'Please check your internet connection and try again.');
      }

      throw AuthException(message: 'Google sign in failed: ${e.toString()}');
    } catch (e) {
      log('Google sign in error (Unknown): $e', name: 'signInWithGoogle');
      throw AuthException(message: 'Google sign in failed: ${e.toString()}');
    }
  }

  /// Helper method to check network connectivity
  Future<bool> _checkNetworkConnectivity() async {
    try {
      final result = await InternetConnectionChecker().hasConnection;
      return result;
    } on Exception catch (e) {
      log('Error checking network connectivity: $e',
          name: '_checkNetworkConnectivity');
      return false;
    }
  }

  /// Helper method to handle exceptions consistently
  Never _handleException(Object e, String operation) {
    // If it's already an AuthException, log its message and throw it
    if (e is AuthException) {
      log('$operation error: ${e.message}', name: '_handleException');
      throw e;
    }
    // If it's a FirebaseException, extract the code and message
    else if (e is FirebaseException) {
      log('$operation error (Firebase): ${e.code} - ${e.message}',
          name: '_handleException');
      throw AuthException(
          message: 'Failed to $operation: ${e.message ?? e.toString()}');
    }
    // For firebase_auth.FirebaseAuthException, handle specific error codes
    else if (e is firebase_auth.FirebaseAuthException) {
      log('$operation error (Firebase Auth): ${e.code} - ${e.message}',
          name: '_handleException');
      throw AuthException(
          message: 'Failed to $operation: ${e.message ?? e.toString()}');
    }
    // For all other exceptions
    else {
      log('$operation error: $e', name: '_handleException');
      throw AuthException(message: 'Failed to $operation: ${e.toString()}');
    }
  }

  @override
  Future<void> signOutUser() async {
    // Log the sign-out attempt
    log('Attempting to sign out user...', name: 'signOutUser');

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

          log('User status updated to offline in Firestore.',
              name: 'signOutUser');
        } else {
          log('User document not found in Firestore. Skipping status update.',
              name: 'signOutUser');
        }
      } else {
        log('No user currently signed in. Skipping Firestore status update.',
            name: 'signOutUser');
      }

      // Sign out from Google Sign-In
      await _googleSignIn.signOut();
      log('Signed out from Google Sign-In (if applicable).',
          name: 'signOutUser');

      // Sign out from Firebase Authentication
      await _auth.signOut();
      log('Signed out from Firebase Authentication.', name: 'signOutUser');

      // Log successful sign-out
      log('User signed out successfully.', name: 'signOutUser');
    } catch (e) {
      // Log the error with details
      log('Sign out error: $e', name: 'signOutUser');
      throw AuthException(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserAuth> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        throw AuthException(message: 'No user is currently signed in');
      }

      // Use retry utility with exponential backoff for Firebase operations
      return await RetryUtil.retry(
        operation: () async {
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
        },
        onRetry: (e, attempt, delayMs) {
          log('Retrying getCurrentUser (attempt $attempt): $e',
              name: 'getCurrentUser');
        },
      );
    } on AuthException {
      // If it's already an AuthException, just rethrow it
      rethrow;
    } catch (e) {
      // For other exceptions, handle them with the standard handler
      return _handleException(e, 'get current user');
    }
  }

  @override
  Future<bool> isUserAuthenticated() async => _auth.currentUser != null;

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log('Reset password error: $e', name: 'resetPassword');
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
      log('Change password error: $e', name: 'changePassword');
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
      log('Send email verification error: $e', name: 'sendEmailVerification');
      throw AuthException(
          message: 'Failed to send email verification: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyEmail(String code) async {
    try {
      // Firebase doesn't have a direct API for verifying email with code
      // This would typically be handled by the user clicking a link in
      // their email. This is a placeholder implementation
      throw AuthException(
          message: 'Email verification with code not supported by Firebase');
    } catch (e) {
      log('Verify email error: $e', name: 'verifyEmail');
      throw AuthException(message: 'Failed to verify email: ${e.toString()}');
    }
  }

  @override
  Future<UserAuth> updateUserProfile({
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
      log('Update user profile error: $e', name: 'updateUserProfile');
      throw AuthException(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> enableMfa() async {
    try {
      // Firebase doesn't directly support TOTP MFA through the SDK
      // This would typically involve additional setup with a
      // third-party MFA provider. This is a placeholder implementation
      throw AuthException(message: 'MFA enablement not implemented');
    } catch (e) {
      log('Enable MFA error: $e', name: 'enableMfa');
      throw AuthException(message: 'Failed to enable MFA: ${e.toString()}');
    }
  }

  @override
  Future<void> disableMfa({required String password}) async {
    try {
      // Firebase doesn't directly support TOTP MFA through the SDK
      // This would typically involve additional setup with a
      // third-party MFA provider. This is a placeholder implementation
      throw AuthException(message: 'MFA disablement not implemented');
    } catch (e) {
      log('Disable MFA error: $e', name: 'disableMfa');
      throw AuthException(message: 'Failed to disable MFA: ${e.toString()}');
    }
  }

  @override
  Future<UserAuth> verifyMfaCode(String code) async {
    try {
      // Firebase doesn't directly support TOTP MFA through the SDK
      // This would typically involve additional setup with a
      // third-party MFA provider. This is a placeholder implementation
      throw AuthException(message: 'MFA verification not implemented');
    } catch (e) {
      log('Verify MFA code error: $e', name: 'verifyMfaCode');
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
      log('Check permission error: $e', name: 'hasPermission');
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
      log('Get user role error: $e', name: 'getUserRole');
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
      log('Delete account error: $e', name: 'deleteAccount');
      throw AuthException(message: 'Failed to delete account: ${e.toString()}');
    }
  }

  @override
  Future<User> getUserById(String userId) async {
    try {
      // Use retry utility with exponential backoff for Firebase operations
      return await RetryUtil.retry(
        operation: () async {
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
        },
        onRetry: (e, attempt, delayMs) {
          log('Retrying getUserById for user $userId (attempt $attempt): $e',
              name: 'getUserById');
        },
      );
    } on AuthException {
      // If it's already an AuthException, just rethrow it
      rethrow;
    } catch (e) {
      // For other exceptions, handle them with the standard handler
      return _handleException(e, 'get user by ID');
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
      if (userName != null) {
        updateData['userName'] = userName;
      }
      if (bio != null) {
        updateData['bio'] = bio;
      }

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
      return _handleException(e, 'update user');
    }
  }

  @override
  Future<List<User>> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      // Get current user ID to exclude from results
      final currentUser = _auth.currentUser;
      final currentUserId = currentUser?.uid;

      final lowercaseQuery = query.toLowerCase();
      final uniqueUsers = <String, User>{};

      // Try prefix search for better performance first
      // Search by username prefix
      final usernameQuerySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('userName', isGreaterThanOrEqualTo: query)
          .where('userName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      // Search by email prefix
      final emailQuerySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      // Process prefix search results
      for (final doc in usernameQuerySnapshot.docs) {
        // Skip if this is the current user
        if (doc.id == currentUserId) {
          continue;
        }

        final data = doc.data();
        uniqueUsers[doc.id] = User(
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
      }

      for (final doc in emailQuerySnapshot.docs) {
        // Skip if this is the current user
        if (doc.id == currentUserId) {
          continue;
        }

        if (!uniqueUsers.containsKey(doc.id)) {
          final data = doc.data();
          uniqueUsers[doc.id] = User(
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
        }
      }

      // If we don't have enough results, perform a broader search
      if (uniqueUsers.length < 5) {
        // Get a limited number of users to search through
        final allUsersSnapshot = await _firestore
            .collection(AppConstants.usersCollection)
            .limit(50)
            .get();

        for (final doc in allUsersSnapshot.docs) {
          // Skip if this is the current user
          if (doc.id == currentUserId) {
            continue;
          }

          // Skip if we already have this user
          if (uniqueUsers.containsKey(doc.id)) {
            continue;
          }

          final data = doc.data();
          final userName = (data['userName'] as String).toLowerCase();
          final email = (data['email'] as String).toLowerCase();

          // Check if username or email contains the query
          if (userName.contains(lowercaseQuery) ||
              email.contains(lowercaseQuery)) {
            uniqueUsers[doc.id] = User(
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
          }
        }
      }

      // Sort results by relevance
      final results = uniqueUsers.values.toList()
        ..sort((a, b) {
          final aUserName = a.userName.toLowerCase();
          final bUserName = b.userName.toLowerCase();
          final aEmail = a.email.toLowerCase();
          final bEmail = b.email.toLowerCase();
          final lowercaseQuery = query.toLowerCase();

          // Exact matches first
          final aExactMatch =
              aUserName == lowercaseQuery || aEmail == lowercaseQuery;
          final bExactMatch =
              bUserName == lowercaseQuery || bEmail == lowercaseQuery;

          if (aExactMatch && !bExactMatch) {
            return -1;
          }
          if (!aExactMatch && bExactMatch) {
            return 1;
          }

          // Then prefix matches
          final aStartsWithMatch = aUserName.startsWith(lowercaseQuery) ||
              aEmail.startsWith(lowercaseQuery);
          final bStartsWithMatch = bUserName.startsWith(lowercaseQuery) ||
              bEmail.startsWith(lowercaseQuery);

          if (aStartsWithMatch && !bStartsWithMatch) {
            return -1;
          }
          if (!aStartsWithMatch && bStartsWithMatch) {
            return 1;
          }

          // Then sort by username length (shorter names first)
          return a.userName.length - b.userName.length;
        });

      return results;
    } catch (e) {
      log('Search users error: $e', name: 'searchUsers');
      return _handleException(e, 'search users');
    }
  }
}
