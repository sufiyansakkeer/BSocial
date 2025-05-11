import 'package:bsocial/domain/entities/user.dart' as domain;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Adapter that allows using AuthRepository as a UserRepository
class AuthUserRepositoryAdapter implements UserRepository {
  /// Constructor
  AuthUserRepositoryAdapter({
    required this.authRepository,
  });

  /// Auth repository
  final AuthRepository authRepository;

  @override
  ResultVoid followUser(String userId) async {
    try {
      // Get the current user
      final currentUserResult = await authRepository.getCurrentUser();

      return await currentUserResult.fold(
        Left.new,
        (currentUser) async {
          // Get the target user
          final targetUserResult = await authRepository.getUserById(userId);

          return await targetUserResult.fold(
            Left.new,
            (targetUser) async {
              try {
                // Check if already following
                if (currentUser.following.contains(userId)) {
                  // Already following, return success
                  return const Right(null);
                }

                // Get Firebase instances from the auth repository
                // implementation This is a bit of a hack, but it's the simplest
                // way to access Firebase
                final firestore = FirebaseFirestore.instance;
                final currentUserId = currentUser.uid;

                // Start a batch operation for atomicity
                final batch = firestore.batch();

                // Update current user's following list
                final currentUserRef = firestore
                    .collection(AppConstants.usersCollection)
                    .doc(currentUserId);

                batch.update(currentUserRef, {
                  'following': FieldValue.arrayUnion([userId])
                });

                // Update target user's followers list
                final targetUserRef = firestore
                    .collection(AppConstants.usersCollection)
                    .doc(userId);

                batch.update(targetUserRef, {
                  'followers': FieldValue.arrayUnion([currentUserId])
                });

                // Commit the batch
                await batch.commit();

                return const Right(null);
              } on Exception catch (e) {
                return Left(ServerFailure(
                    message: 'Failed to follow user: ${e.toString()}'));
              }
            },
          );
        },
      );
    } on Exception catch (e) {
      return Left(
          ServerFailure(message: 'Failed to follow user: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<domain.User>> getAllUsers() async => Future.value(
      const Left(ServerFailure(message: 'Get all users not implemented')));

  @override
  ResultFuture<List<domain.User>> getFollowers(String userId) async {
    try {
      // Get the user document to access the followers list
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return const Left(ServerFailure(message: 'User not found'));
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final followerIds = List<String>.from(userData['followers'] ?? []);

      if (followerIds.isEmpty) {
        return const Right([]);
      }

      // Get user documents for all followers
      final followers = await Future.wait(
        followerIds.map((followerId) async {
          try {
            final result = await authRepository.getUserById(followerId);
            return result.fold(
              (failure) => null,
              (user) => domain.User(
                uid: user.uid,
                username: user.userName,
                profilePic: user.photoUrl,
                email: user.email,
                photoUrl: user.photoUrl,
                userName: user.userName,
                followers: user.followers,
                following: user.following,
                status: user.status,
              ),
            );
          } on Exception {
            return null;
          }
        }),
      );

      // Filter out any null values (in case a follower document doesn't exist)
      final validFollowers = followers.whereType<domain.User>().toList();
      return Right(validFollowers);
    } on Exception catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get followers: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<domain.User>> getFollowing(String userId) async {
    try {
      // Get the user document to access the following list
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return const Left(ServerFailure(message: 'User not found'));
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final followingIds = List<String>.from(userData['following'] ?? []);

      if (followingIds.isEmpty) {
        return const Right([]);
      }

      // Get user documents for all following
      final following = await Future.wait(
        followingIds.map((followingId) async {
          try {
            final result = await authRepository.getUserById(followingId);
            return result.fold(
              (failure) => null,
              (user) => domain.User(
                uid: user.uid,
                username: user.userName,
                profilePic: user.photoUrl,
                email: user.email,
                photoUrl: user.photoUrl,
                userName: user.userName,
                followers: user.followers,
                following: user.following,
                status: user.status,
              ),
            );
          } on Exception {
            return null;
          }
        }),
      );

      // Filter out any null values (in case a following document doesn't exist)
      final validFollowing = following.whereType<domain.User>().toList();
      return Right(validFollowing);
    } on Exception catch (e) {
      return Left(
          ServerFailure(message: 'Failed to get following: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<domain.User> getUserById(String userId) async {
    final result = await authRepository.getUserById(userId);
    return result.fold(
      Left.new,
      (user) => Right(domain.User(
        uid: user.uid,
        username: user.userName,
        profilePic: user.photoUrl,
        email: user.email,
        photoUrl: user.photoUrl,
        userName: user.userName,
        followers: user.followers,
        following: user.following,
        status: user.status,
      )),
    );
  }

  @override
  ResultFuture<List<domain.User>> searchUsers(String query) async {
    final result = await authRepository.searchUsers(query);
    return result.fold(
      Left.new,
      (users) => Right(users
          .map((user) => domain.User(
                uid: user.uid,
                username: user.userName,
                profilePic: user.photoUrl,
                email: user.email,
                photoUrl: user.photoUrl,
                userName: user.userName,
                followers: user.followers,
                following: user.following,
                status: user.status,
              ))
          .toList()),
    );
  }

  @override
  ResultVoid unfollowUser(String userId) async {
    try {
      // Get the current user
      final currentUserResult = await authRepository.getCurrentUser();

      return await currentUserResult.fold(
        Left.new,
        (currentUser) async {
          // Get the target user
          final targetUserResult = await authRepository.getUserById(userId);

          return await targetUserResult.fold(
            Left.new,
            (targetUser) async {
              try {
                // Check if not already following
                if (!currentUser.following.contains(userId)) {
                  // Not following, return success
                  return const Right(null);
                }

                // Get Firebase instances
                final firestore = FirebaseFirestore.instance;
                final currentUserId = currentUser.uid;

                // Start a batch operation for atomicity
                final batch = firestore.batch();

                // Update current user's following list
                final currentUserRef = firestore
                    .collection(AppConstants.usersCollection)
                    .doc(currentUserId);

                batch.update(currentUserRef, {
                  'following': FieldValue.arrayRemove([userId])
                });

                // Update target user's followers list
                final targetUserRef = firestore
                    .collection(AppConstants.usersCollection)
                    .doc(userId);

                batch.update(targetUserRef, {
                  'followers': FieldValue.arrayRemove([currentUserId])
                });

                // Commit the batch
                await batch.commit();

                return const Right(null);
              } on Exception catch (e) {
                return Left(ServerFailure(
                    message: 'Failed to unfollow user: ${e.toString()}'));
              }
            },
          );
        },
      );
    } on Exception catch (e) {
      return Left(
          ServerFailure(message: 'Failed to unfollow user: ${e.toString()}'));
    }
  }

  @override
  ResultFuture<domain.User> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
    String? bio,
  }) async {
    final result = await authRepository.updateUser(
      userId: userId,
      userName: userName,
      bio: bio,
    );

    return result.fold(
      Left.new,
      (user) => Right(domain.User(
        uid: user.uid,
        username: user.userName,
        profilePic: user.photoUrl,
        email: user.email,
        photoUrl: user.photoUrl,
        userName: user.userName,
        followers: user.followers,
        following: user.following,
        status: user.status,
      )),
    );
  }
}
