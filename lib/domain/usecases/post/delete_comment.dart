import '../../../core/utils/typedefs.dart';
import '../../repositories/post_repository.dart';

class DeleteCommentUseCase {
  DeleteCommentUseCase(this.repository);
  final PostRepository repository;

  ResultVoid call(String commentId, String postId) =>
      repository.deleteComment(commentId, postId);
}
