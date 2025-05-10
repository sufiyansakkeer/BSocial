import '../../../../core/utils/typedefs.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case to get posts by user ID
class GetPostsByUserIdUseCase {
  /// Constructor
  GetPostsByUserIdUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultFuture<List<Post>> call(String userId) => 
      repository.getPostsByUserId(userId);
}
