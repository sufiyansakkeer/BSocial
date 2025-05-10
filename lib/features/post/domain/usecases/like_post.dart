import '../../../../core/utils/typedefs.dart';
import '../repositories/post_repository.dart';

/// Use case to like a post
class LikePostUseCase {
  /// Constructor
  LikePostUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultVoid call(String postId, String userId) => 
      repository.likePost(postId, userId);
}
