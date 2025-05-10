import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User

import '../../../../core/utils/typedefs.dart';

/// Interface for user repository
abstract class UserRepository {
  /// Get user by ID
  ResultFuture<User> getUserById(String userId);

  /// Get all users
  ResultFuture<List<User>> getAllUsers();

  /// Search users by query
  ResultFuture<List<User>> searchUsers(String query);

  /// Follow a user
  ResultVoid followUser(String userId);

  /// Unfollow a user
  ResultVoid unfollowUser(String userId);

  /// Get followers of a user
  ResultFuture<List<User>> getFollowers(String userId);

  /// Get users followed by a user
  ResultFuture<List<User>> getFollowing(String userId);

  /// Update user profile
  ResultFuture<User> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
    String? bio,
  });
}
