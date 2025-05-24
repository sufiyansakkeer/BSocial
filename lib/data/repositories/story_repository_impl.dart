import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/remote/story_remote_datasource.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart'; // Assuming NetworkInfo for connectivity check

class StoryRepositoryImpl implements StoryRepository {
  final StoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Optional: if you want to check network status

  StoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> addStory({
    required File imageFile,
    required String userId,
    required String username,
    required String userProfileImageUrl,
  }) async {
    if (await networkInfo.isConnected) { // Check network if available
      try {
        await remoteDataSource.addStory(
          imageFile: imageFile,
          userId: userId,
          username: username,
          userProfileImageUrl: userProfileImageUrl,
        );
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(ServerFailure(message: e.toString())); // Or a generic failure
      }
    } else {
      return Left(NetworkFailure()); // Or a more specific NoConnectionFailure
    }
  }

  @override
  Future<Either<Failure, List<Story>>> getActiveStoriesForUser(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final storyModels = await remoteDataSource.getActiveStoriesForUser(userId);
        return Right(storyModels.map((model) => model as Story).toList()); // Cast if StoryModel extends Story
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
  
  @override
  Future<Either<Failure, List<Story>>> getFollowedUsersActiveStories(List<String> followedUserIds) async {
    if (followedUserIds.isEmpty) {
      return const Right([]); // No need to hit network if list is empty
    }
    if (await networkInfo.isConnected) {
      try {
        final storyModels = await remoteDataSource.getFollowedUsersActiveStories(followedUserIds);
        // StoryModel extends Story, so direct casting or mapping might not be needed if types are compatible.
        // Explicitly mapping to ensure type safety if models have more fields than entities.
        final List<Story> stories = storyModels.map((model) => model as Story).toList();
        return Right(stories);
      } on ServerException {
        return Left(ServerFailure());
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
