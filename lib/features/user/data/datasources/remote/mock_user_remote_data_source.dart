import '../../../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import 'user_remote_data_source.dart';

/// Mock implementation of [UserRemoteDataSource] for offline mode
class MockUserRemoteDataSource implements UserRemoteDataSource {
  @override
  Future<List<UserModel>> getAllUsers() async =>
      []; // Return an empty list in offline mode

  @override
  Future<void> followUser(String userId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async =>
      []; // Return an empty list in offline mode

  @override
  Future<List<UserModel>> getFollowing(String userId) async =>
      []; // Return an empty list in offline mode

  @override
  Future<UserModel> getUserById(String userId) async {
    // Return a mock user or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async =>
      []; // Return an empty list in offline mode

  @override
  Future<void> unfollowUser(String userId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
    String? bio,
  }) async {
    // Return a mock user or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }
}
