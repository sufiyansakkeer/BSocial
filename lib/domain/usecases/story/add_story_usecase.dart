import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/story_repository.dart';
import '../../../core/usecases/usecase.dart'; // Assuming a base UseCase class

class AddStoryUseCase implements UseCase<void, AddStoryParams> {
  final StoryRepository repository;

  AddStoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddStoryParams params) async {
    return await repository.addStory(
      imageFile: params.imageFile,
      userId: params.userId,
      username: params.username,
      userProfileImageUrl: params.userProfileImageUrl,
    );
  }
}

class AddStoryParams {
  final File imageFile;
  final String userId;
  final String username;
  final String userProfileImageUrl;

  AddStoryParams({
    required this.imageFile,
    required this.userId,
    required this.username,
    required this.userProfileImageUrl,
  });
  // Consider adding Equatable if params are compared
}
