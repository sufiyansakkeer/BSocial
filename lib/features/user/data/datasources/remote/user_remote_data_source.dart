import '../../models/user_model.dart';

/// Interface for user remote data source
abstract class UserRemoteDataSource {
  /// Get user by ID
  Future<UserModel> getUserById(String userId);

  /// Get all users
  Future<List<UserModel>> getAllUsers();

  /// Search users by query
  Future<List<UserModel>> searchUsers(String query);

  /// Follow a user
  Future<void> followUser(String userId);

  /// Unfollow a user
  Future<void> unfollowUser(String userId);

  /// Get followers of a user
  Future<List<UserModel>> getFollowers(String userId);

  /// Get users followed by a user
  Future<List<UserModel>> getFollowing(String userId);

  /// Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
    String? bio,
  });
}
