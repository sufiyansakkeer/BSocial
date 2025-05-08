import '../../../core/utils/typedefs.dart';
import '../../repositories/post_repository.dart';

class LikePostUseCase {
  LikePostUseCase(this.repository);
  final PostRepository repository;

  ResultVoid call(String postId, String userId) =>
      repository.likePost(postId, userId);
}
