import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot =
          await _firestore.collection(AppConstants.usersCollection).get();

      return querySnapshot.docs.map(UserModel.fromSnapshot).toList();
    } catch (e) {
      log('Error getting all users: $e');
      throw ServerException(message: 'Failed to get users: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getFollowers(String userId) async {
    try {
      // Get the user document to access the followers list
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw ServerException(message: 'User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final followerIds = List<String>.from(userData['followers'] ?? []);

      if (followerIds.isEmpty) {
        return [];
      }

      // Get user documents for all followers
      final followers = await Future.wait(
        followerIds.map((followerId) async {
          final followerDoc = await _firestore
              .collection(AppConstants.usersCollection)
              .doc(followerId)
              .get();

          if (followerDoc.exists) {
            return UserModel.fromSnapshot(followerDoc);
          }
          return null;
        }),
      );

      // Filter out any null values (in case a follower document doesn't exist)
      return followers.whereType<UserModel>().toList();
    } catch (e) {
      log('Error getting followers: $e');
      throw ServerException(
          message: 'Failed to get followers: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getFollowing(String userId) async {
    try {
      // Get the user document to access the following list
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw ServerException(message: 'User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final followingIds = List<String>.from(userData['following'] ?? []);

      if (followingIds.isEmpty) {
        return [];
      }

      // Get user documents for all following
      final following = await Future.wait(
        followingIds.map((followingId) async {
          final followingDoc = await _firestore
              .collection(AppConstants.usersCollection)
              .doc(followingId)
              .get();

          if (followingDoc.exists) {
            return UserModel.fromSnapshot(followingDoc);
          }
          return null;
        }),
      );

      // Filter out any null values (in case a following document doesn't exist)
      return following.whereType<UserModel>().toList();
    } catch (e) {
      log('Error getting following: $e');
      throw ServerException(
          message: 'Failed to get following: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw ServerException(message: 'User not found');
      }

      return UserModel.fromSnapshot(userDoc);
    } catch (e) {
      log('Error getting user by ID: $e');
      throw ServerException(message: 'Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs.map(UserModel.fromSnapshot).toList();
    } catch (e) {
      log('Error searching users: $e');
      throw ServerException(message: 'Failed to search users: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
  }) async {
    try {
      final userRef =
          _firestore.collection(AppConstants.usersCollection).doc(userId);

      final updates = <String, dynamic>{};
      if (userName != null) {
        updates['username'] = userName;
      }
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }
      if (status != null) {
        updates['status'] = status;
      }

      if (updates.isNotEmpty) {
        await userRef.update(updates);
      }

      final updatedUserDoc = await userRef.get();
      return UserModel.fromSnapshot(updatedUserDoc);
    } catch (e) {
      log('Error updating user profile: $e');
      throw ServerException(
          message: 'Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> followUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw ServerException(message: 'User not authenticated');
      }

      if (currentUserId == userId) {
        throw ServerException(message: 'Cannot follow yourself');
      }

      // Get current user document
      final currentUserDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .get();

      // Get target user document
      final targetUserDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!currentUserDoc.exists || !targetUserDoc.exists) {
        throw ServerException(message: 'User not found');
      }

      // Update current user's following list
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({
        'following': FieldValue.arrayUnion([userId])
      });

      // Update target user's followers list
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'followers': FieldValue.arrayUnion([currentUserId])
      });
    } catch (e) {
      log('Error following user: $e');
      throw ServerException(message: 'Failed to follow user: ${e.toString()}');
    }
  }

  @override
  Future<void> unfollowUser(String userId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw ServerException(message: 'User not authenticated');
      }

      if (currentUserId == userId) {
        throw ServerException(message: 'Cannot unfollow yourself');
      }

      // Get current user document
      final currentUserDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .get();

      // Get target user document
      final targetUserDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!currentUserDoc.exists || !targetUserDoc.exists) {
        throw ServerException(message: 'User not found');
      }

      // Update current user's following list
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .update({
        'following': FieldValue.arrayRemove([userId])
      });

      // Update target user's followers list
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'followers': FieldValue.arrayRemove([currentUserId])
      });
    } catch (e) {
      log('Error unfollowing user: $e');
      throw ServerException(
          message: 'Failed to unfollow user: ${e.toString()}');
    }
  }
}
