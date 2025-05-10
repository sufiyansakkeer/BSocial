import '../../../../core/utils/typedefs.dart';
import '../repositories/post_repository.dart';

/// Use case to unlike a post
class UnlikePostUseCase {
  /// Constructor
  UnlikePostUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultVoid call(String postId, String userId) => 
      repository.unlikePost(postId, userId);
}
