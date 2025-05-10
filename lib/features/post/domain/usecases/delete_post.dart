import '../../../../core/utils/typedefs.dart';
import '../repositories/post_repository.dart';

/// Use case to delete a post
class DeletePostUseCase {
  /// Constructor
  DeletePostUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultVoid call(String postId) => repository.deletePost(postId);
}
