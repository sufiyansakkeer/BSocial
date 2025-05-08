import '../../../core/utils/typedefs.dart';
import '../../repositories/post_repository.dart';

class LikePostUseCase {
  final PostRepository repository;

  LikePostUseCase(this.repository);

  ResultVoid call(String postId, String userId) {
    return repository.likePost(postId, userId);
  }
}
