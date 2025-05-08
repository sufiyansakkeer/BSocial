import '../../core/utils/typedefs.dart';
import '../entities/user.dart';

// User repository interface
abstract class UserRepository {
  // Get a user by ID
  ResultFuture<User> getUserById(String userId);

  // Get all users
  ResultFuture<List<User>> getAllUsers();

  // Search for users by username
  ResultFuture<List<User>> searchUsers(String query);

  // Follow a user
  ResultVoid followUser(String userId);

  // Unfollow a user
  ResultVoid unfollowUser(String userId);

  // Get followers of a user
  ResultFuture<List<User>> getFollowers(String userId);

  // Get users followed by a user
  ResultFuture<List<User>> getFollowing(String userId);

  // Update user profile
  ResultFuture<User> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
  });
}
