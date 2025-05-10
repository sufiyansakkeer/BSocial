import '../../../../features/user/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserById(String userId);
  Future<List<UserModel>> getAllUsers();
  Future<List<UserModel>> searchUsers(String query);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<UserModel>> getFollowers(String userId);
  Future<List<UserModel>> getFollowing(String userId);
  Future<UserModel> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
  });
}
