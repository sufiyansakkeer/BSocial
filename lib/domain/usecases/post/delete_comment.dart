import '../../../core/utils/typedefs.dart';
import '../../repositories/post_repository.dart';

class DeleteCommentUseCase {
  final PostRepository repository;

  DeleteCommentUseCase(this.repository);

  ResultVoid call(String commentId, String postId) {
    return repository.deleteComment(commentId, postId);
  }
}
