import 'dart:io'; // For File type in addStory

import 'package:dartz/dartz.dart'; // Assuming dartz is used for Either type
import '../../core/errors/failures.dart'; // Assuming Failure type exists
import '../entities/story.dart';

abstract class StoryRepository {
  Future<Either<Failure, void>> addStory({
    required File imageFile, // For uploading
    required String userId,
    required String username,
    required String userProfileImageUrl,
  });

  Future<Either<Failure, List<Story>>> getActiveStoriesForUser(String userId);

  // To fetch stories for the main reel from followed users
  // This will require fetching current user's followed list first, then querying stories.
  // The List<String> followedUserIds will be passed to this method.
  Future<Either<Failure, List<Story>>> getFollowedUsersActiveStories(
      List<String> followedUserIds);
}
