import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/story.dart';
import '../../repositories/story_repository.dart';
import '../../../core/usecases/usecase.dart';

class GetFollowedUsersActiveStoriesUseCase implements UseCase<List<Story>, List<String>> {
  final StoryRepository repository;

  GetFollowedUsersActiveStoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Story>>> call(List<String> followedUserIds) async {
    return await repository.getFollowedUsersActiveStories(followedUserIds);
  }
}
