import '../../../core/utils/typedefs.dart';
import '../../repositories/post_repository.dart';

class UnlikePostUseCase {
  UnlikePostUseCase(this.repository);
  final PostRepository repository;

  ResultVoid call(String postId, String userId) =>
      repository.unlikePost(postId, userId);
}
