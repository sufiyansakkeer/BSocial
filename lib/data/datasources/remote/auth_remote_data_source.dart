import 'dart:developer';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import '../local/storage_local_data_source.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  });

  Future<UserModel> loginUser({
    required String email,
    required String password,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOutUser();

  Future<UserModel> getCurrentUser();

  Future<void> resetPassword(String email);

  Future<bool> isUserAuthenticated();
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
  Future<UserModel> getCurrentUser() async {
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

      return UserModel.fromSnapshot(userDoc);
    } catch (e) {
      log('Error getting current user: $e');
      throw AuthException(
          message: 'Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserAuthenticated() async => _auth.currentUser != null;

  @override
  Future<UserModel> loginUser({
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

      return UserModel.fromSnapshot(userDoc);
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
  Future<UserModel> signInWithGoogle() async {
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

        final userModel = UserModel(
          email: user.email ?? '',
          uid: user.uid,
          photoUrl: user.photoURL ?? '',
          userName: user.displayName ?? '',
          followers: [],
          following: [],
          status: 'online',
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toJson());

        return userModel;
      }

      return UserModel.fromSnapshot(userDoc);
    } catch (e) {
      log('Google sign in error: $e');
      throw AuthException(message: 'Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOutUser() async {
    try {
      // Update user status to offline
      if (_auth.currentUser != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(_auth.currentUser!.uid)
            .update({'status': 'offline'});
      }

      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      log('Sign out error: $e');
      throw AuthException(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpUser({
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
        file,
        false,
      );

      // Create user model
      final userModel = UserModel(
        email: email,
        uid: userCredential.user!.uid,
        photoUrl: photoUrl,
        userName: userName,
        followers: [],
        following: [],
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
}
