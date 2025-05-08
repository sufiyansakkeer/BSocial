import '../../../core/utils/typedefs.dart';
import '../../entities/comment.dart';
import '../../repositories/post_repository.dart';

class GetCommentsUseCase {
  final PostRepository repository;

  GetCommentsUseCase(this.repository);

  ResultFuture<List<Comment>> call(String postId) {
    return repository.getComments(postId);
  }
}
