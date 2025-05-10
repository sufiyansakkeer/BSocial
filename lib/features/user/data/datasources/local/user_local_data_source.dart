import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../data/models/hive/user_hive_model.dart';
import '../../models/user_model.dart';

/// Interface for user local data source
abstract class UserLocalDataSource {
  /// Cache a user
  Future<void> cacheUser(UserModel user);

  /// Get user by ID
  Future<UserModel> getUserById(String userId);

  /// Get all users
  Future<List<UserModel>> getAllUsers();

  /// Get users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds);

  /// Delete user from cache
  Future<void> deleteUser(String userId);

  /// Clear all users from cache
  Future<void> clearUsers();
}

/// Implementation of [UserLocalDataSource]
class UserLocalDataSourceImpl implements UserLocalDataSource {
  /// Constructor
  UserLocalDataSourceImpl();

  /// Hive box name
  static const String _boxName = 'users';

  /// Get users box
  Future<Box<UserHiveModel>> get _usersBox =>
      Hive.openBox<UserHiveModel>(_boxName);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final box = await _usersBox;
      final hiveModel = UserHiveModel(
        uid: user.uid, // user is UserModel, which extends User (canonical)
        email: user.email,
        userName: user
            .username, // Map UserModel's primary username to hiveModel.userName
        photoUrl: user.profilePic, // Map UserModel's primary profilePic to
        // hiveModel.photoUrl
        // Assuming canonical User's optional userName and photoUrl are not
        //primary here or that UserModel itself doesn't differentiate them
        //beyond what User entity has. If UserModel had distinct fields for
        //User's optional userName/photoUrl, map them here.
        followers: user.followers,
        following: user.following,
        status: user.status,
        // UserModel specific fields
        bio: user.bio,
        isMfaEnabled: user.isMfaEnabled,
        isEmailVerified: user.isEmailVerified,
        lastUpdated: DateTime.now(),
      );
      await box.put(user.uid, hiveModel); // user.uid is from super.uid
    } catch (e) {
      log('Error caching user: $e');
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearUsers() async {
    try {
      final box = await _usersBox;
      await box.clear();
    } catch (e) {
      log('Error clearing users: $e');
      throw CacheException(message: 'Failed to clear users: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final box = await _usersBox;
      await box.delete(userId);
    } catch (e) {
      log('Error deleting user: $e');
      throw CacheException(message: 'Failed to delete user: $e');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final box = await _usersBox;
      return box.values
          .map((hiveModel) => UserModel(
                uid: hiveModel.uid,
                username: hiveModel
                    .userName, // Map to canonical User's required username
                profilePic: hiveModel
                    .photoUrl, // Map to canonical User's required profilePic
                email: hiveModel.email,
                photoUrl: hiveModel
                    .photoUrl, // For canonical User's optional photoUrl
                userName: hiveModel
                    .userName, // For canonical User's optional userName
                followers: hiveModel.followers,
                following: hiveModel.following,
                status: hiveModel.status,
                // UserModel specific fields
                bio: hiveModel.bio,
                isMfaEnabled: hiveModel.isMfaEnabled,
                isEmailVerified: hiveModel.isEmailVerified,
              ))
          .toList();
    } catch (e) {
      log('Error getting all users: $e');
      throw CacheException(message: 'Failed to get all users: $e');
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final box = await _usersBox;
      final hiveModel = box.get(userId);
      if (hiveModel == null) {
        throw CacheException(message: 'User not found in cache');
      }
      return UserModel(
        uid: hiveModel.uid,
        username:
            hiveModel.userName, // Map to canonical User's required username
        profilePic:
            hiveModel.photoUrl, // Map to canonical User's required profilePic
        email: hiveModel.email,
        photoUrl: hiveModel.photoUrl, // For canonical User's optional photoUrl
        userName: hiveModel.userName, // For canonical User's optional userName
        followers: hiveModel.followers,
        following: hiveModel.following,
        status: hiveModel.status,
        // UserModel specific fields
        bio: hiveModel.bio,
        isMfaEnabled: hiveModel.isMfaEnabled,
        isEmailVerified: hiveModel.isEmailVerified,
      );
    } catch (e) {
      log('Error getting user by ID: $e');
      throw CacheException(message: 'Failed to get user by ID: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      final box = await _usersBox;
      final users = <UserModel>[];
      for (final userId in userIds) {
        final hiveModel = box.get(userId);
        if (hiveModel != null) {
          users.add(UserModel(
            uid: hiveModel.uid,
            username:
                hiveModel.userName, // Map to canonical User's required username
            profilePic: hiveModel
                .photoUrl, // Map to canonical User's required profilePic
            email: hiveModel.email,
            photoUrl:
                hiveModel.photoUrl, // For canonical User's optional photoUrl
            userName:
                hiveModel.userName, // For canonical User's optional userName
            followers: hiveModel.followers,
            following: hiveModel.following,
            status: hiveModel.status,
            // UserModel specific fields
            bio: hiveModel.bio,
            isMfaEnabled: hiveModel.isMfaEnabled,
            isEmailVerified: hiveModel.isEmailVerified,
          ));
        }
      }
      return users;
    } catch (e) {
      log('Error getting users by IDs: $e');
      throw CacheException(message: 'Failed to get users by IDs: $e');
    }
  }
}
