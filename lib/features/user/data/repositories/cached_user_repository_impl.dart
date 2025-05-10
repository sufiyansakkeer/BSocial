import 'dart:developer';

import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/user_local_data_source.dart';
import '../datasources/remote/user_remote_data_source.dart';

/// Implementation of [UserRepository] with caching
class CachedUserRepositoryImpl implements UserRepository {
  /// Constructor
  CachedUserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  /// Remote data source
  final UserRemoteDataSource remoteDataSource;

  /// Local data source
  final UserLocalDataSource localDataSource;

  /// Network info
  final NetworkInfo networkInfo;

  /// Helper method to handle remote calls with local fallback
  Future<T> _handleRemoteCallWithLocalFallback<T>({
    required Future<T> Function() remoteCall,
    required Future<T> Function() localCall,
    required String remoteErrorMessage,
    required String localErrorMessage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteCall();
      } on ServerException catch (e) {
        log('Remote call failed: ${e.message}. Trying local fallback.');
        try {
          return await localCall();
        } on CacheException catch (e) {
          log('Local fallback failed: ${e.message}');
          throw CacheException(message: localErrorMessage);
        }
      }
    } else {
      log('No internet connection. Using local data.');
      try {
        return await localCall();
      } on CacheException catch (e) {
        log('Local fallback failed: ${e.message}');
        throw CacheException(message: localErrorMessage);
      }
    }
  }

  /// Helper method to handle remote calls
  Future<T> _handleRemoteCall<T>({
    required Future<T> Function() call,
    required String errorMessage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        return await call();
      } on ServerException catch (e) {
        throw ServerFailure(message: e.message);
      } on Exception catch (e) {
        throw ServerFailure(message: '$errorMessage: $e');
      }
    } else {
      throw const NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  ResultFuture<List<User>> getAllUsers() async {
    try {
      final users = await _handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get users from remote
          final remoteUsers = await remoteDataSource.getAllUsers();

          // Cache users locally
          for (final user in remoteUsers) {
            try {
              await localDataSource.cacheUser(user);
            } on Exception catch (e) {
              log('Error caching user: $e');
              // Continue even if caching fails
            }
          }

          return remoteUsers;
        },
        localCall: () async {
          final localUsers = await localDataSource.getAllUsers();
          if (localUsers.isEmpty) {
            throw CacheException(message: 'No cached users available');
          }
          log('Returning users from cache');
          return localUsers;
        },
        remoteErrorMessage: 'Failed to fetch users from server',
        localErrorMessage: 'No cached users available',
      );

      return Right(users.map((userModel) => userModel.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid followUser(String userId) async {
    try {
      await _handleRemoteCall(
        call: () => remoteDataSource.followUser(userId),
        errorMessage: 'Failed to follow user',
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<User>> getFollowers(String userId) async {
    try {
      final followers = await _handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get followers from remote
          final remoteFollowers = await remoteDataSource.getFollowers(userId);

          // Cache followers locally
          for (final user in remoteFollowers) {
            try {
              await localDataSource.cacheUser(user);
            } on Exception catch (e) {
              log('Error caching user: $e');
              // Continue even if caching fails
            }
          }

          return remoteFollowers;
        },
        localCall: () async {
          // Get user from cache to get follower IDs
          final user = await localDataSource.getUserById(userId);

          // Get followers from cache
          final followers = await localDataSource.getUsersByIds(user.followers);
          if (followers.isEmpty) {
            throw CacheException(
                message: 'No cached followers available for user $userId');
          }
          log('Returning followers from cache');
          return followers;
        },
        remoteErrorMessage: 'Failed to fetch followers from server',
        localErrorMessage: 'No cached followers available',
      );

      return Right(followers.map((userModel) => userModel.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<User>> getFollowing(String userId) async {
    try {
      final following = await _handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get following from remote
          final remoteFollowing = await remoteDataSource.getFollowing(userId);

          // Cache following locally
          for (final user in remoteFollowing) {
            try {
              await localDataSource.cacheUser(user);
            } on Exception catch (e) {
              log('Error caching user: $e');
              // Continue even if caching fails
            }
          }

          return remoteFollowing;
        },
        localCall: () async {
          // Get user from cache to get following IDs
          final user = await localDataSource.getUserById(userId);

          // Get following from cache
          final following = await localDataSource.getUsersByIds(user.following);
          if (following.isEmpty) {
            throw CacheException(
                message: 'No cached following available for user $userId');
          }
          log('Returning following from cache');
          return following;
        },
        remoteErrorMessage: 'Failed to fetch following from server',
        localErrorMessage: 'No cached following available',
      );

      return Right(following.map((userModel) => userModel.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<User> getUserById(String userId) async {
    try {
      final user = await _handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get user from remote
          final remoteUser = await remoteDataSource.getUserById(userId);

          // Cache user locally
          try {
            await localDataSource.cacheUser(remoteUser);
          } on Exception catch (e) {
            log('Error caching user: $e');
            // Continue even if caching fails
          }

          return remoteUser;
        },
        localCall: () async {
          final localUser = await localDataSource.getUserById(userId);
          log('Returning user from cache');
          return localUser;
        },
        remoteErrorMessage: 'Failed to fetch user from server',
        localErrorMessage: 'User not found in cache',
      );

      return Right(user.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<User>> searchUsers(String query) async {
    try {
      final users = await _handleRemoteCall(
        call: () => remoteDataSource.searchUsers(query),
        errorMessage: 'Failed to search users',
      );
      return Right(users.map((userModel) => userModel.toEntity()).toList());
    } on Failure catch (failure) {
      return Left(failure);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid unfollowUser(String userId) async {
    try {
      await _handleRemoteCall(
        call: () => remoteDataSource.unfollowUser(userId),
        errorMessage: 'Failed to unfollow user',
      );
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<User> updateUserProfile({
    required String userId,
    String? userName,
    String? photoUrl,
    String? status,
    String? bio,
  }) async {
    try {
      final user = await _handleRemoteCall(
        call: () => remoteDataSource.updateUserProfile(
          userId: userId,
          userName: userName,
          photoUrl: photoUrl,
          status: status,
          bio: bio,
        ),
        errorMessage: 'Failed to update user profile',
      );

      // Cache updated user locally
      try {
        await localDataSource.cacheUser(user);
      } on Exception catch (e) {
        log('Error caching updated user: $e');
        // Continue even if caching fails
      }

      return Right(user.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
