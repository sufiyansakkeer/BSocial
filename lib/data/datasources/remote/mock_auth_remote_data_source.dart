import 'dart:typed_data';
import 'package:bsocial/data/datasources/remote/auth_remote_data_source.dart';
import 'package:bsocial/data/models/user_model.dart';
import 'package:bsocial/core/errors/exceptions.dart';

/// Mock implementation of [AuthRemoteDataSource] for offline mode
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<UserModel> getCurrentUser() async {
    // Return a mock user or throw an exception
    throw AuthException(message: 'Not available in offline mode');
  }

  @override
  Future<bool> isUserAuthenticated() async {
    // Always return false in offline mode
    return false;
  }

  @override
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    // Return a mock user or throw an exception
    throw AuthException(message: 'Not available in offline mode');
  }

  @override
  Future<void> resetPassword(String email) async {
    // No-op in offline mode
    throw AuthException(message: 'Not available in offline mode');
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // Return a mock user or throw an exception
    throw AuthException(message: 'Not available in offline mode');
  }

  @override
  Future<void> signOutUser() async {
    // No-op in offline mode
  }

  @override
  Future<UserModel> signUpUser({
    required String userName,
    required String email,
    required String password,
    required Uint8List? file,
  }) async {
    // Return a mock user or throw an exception
    throw AuthException(message: 'Not available in offline mode');
  }
}
