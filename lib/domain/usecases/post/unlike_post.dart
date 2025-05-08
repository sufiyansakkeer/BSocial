import '../../../core/utils/typedefs.dart';
import '../../repositories/post_repository.dart';

class UnlikePostUseCase {
  final PostRepository repository;

  UnlikePostUseCase(this.repository);

  ResultVoid call(String postId, String userId) {
    return repository.unlikePost(postId, userId);
  }
}
