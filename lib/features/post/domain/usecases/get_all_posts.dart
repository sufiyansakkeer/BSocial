import '../../../../core/utils/typedefs.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case to get all posts
class GetAllPostsUseCase {
  /// Constructor
  GetAllPostsUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultFuture<List<Post>> call() => repository.getAllPosts();
}
