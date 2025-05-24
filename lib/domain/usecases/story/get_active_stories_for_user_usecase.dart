import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/story.dart';
import '../../repositories/story_repository.dart';
import '../../../core/usecases/usecase.dart';

class GetActiveStoriesForUserUseCase implements UseCase<List<Story>, String> {
  final StoryRepository repository;

  GetActiveStoriesForUserUseCase(this.repository);

  @override
  Future<Either<Failure, List<Story>>> call(String userId) async {
    return await repository.getActiveStoriesForUser(userId);
  }
}
