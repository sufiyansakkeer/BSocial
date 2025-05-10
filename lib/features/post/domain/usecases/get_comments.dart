import '../../../../core/utils/typedefs.dart';
import '../entities/comment.dart';
import '../repositories/post_repository.dart';

/// Use case to get comments for a post
class GetCommentsUseCase {
  /// Constructor
  GetCommentsUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultFuture<List<Comment>> call(String postId) => 
      repository.getComments(postId);
}
