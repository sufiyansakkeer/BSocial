import '../../../../core/utils/typedefs.dart';
import '../repositories/post_repository.dart';

/// Use case to delete a comment
class DeleteCommentUseCase {
  /// Constructor
  DeleteCommentUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultVoid call(String commentId, String postId) => 
      repository.deleteComment(commentId, postId);
}
