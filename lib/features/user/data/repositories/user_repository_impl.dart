import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_data_source.dart';

/// Implementation of [UserRepository]
class UserRepositoryImpl implements UserRepository {
  /// Constructor
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Remote data source
  final UserRemoteDataSource remoteDataSource;

  /// Network info
  final NetworkInfo networkInfo;

  @override
  ResultFuture<List<User>> getAllUsers() async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.getAllUsers();
        return Right(users.map((userModel) => userModel.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultVoid followUser(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.followUser(userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultFuture<List<User>> getFollowers(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final followers = await remoteDataSource.getFollowers(userId);
        return Right(
            followers.map((userModel) => userModel.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultFuture<List<User>> getFollowing(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final following = await remoteDataSource.getFollowing(userId);
        return Right(
            following.map((userModel) => userModel.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultFuture<User> getUserById(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUserById(userId);
        return Right(user.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultFuture<List<User>> searchUsers(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.searchUsers(query);
        return Right(users.map((userModel) => userModel.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultVoid unfollowUser(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unfollowUser(userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
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
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.updateUserProfile(
          userId: userId,
          userName: userName,
          photoUrl: photoUrl,
          status: status,
          bio: bio,
        );
        return Right(user.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on Exception catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
