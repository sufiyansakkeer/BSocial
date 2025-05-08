import '../../../core/utils/typedefs.dart';
import '../../entities/comment.dart';
import '../../repositories/post_repository.dart';

class GetCommentsUseCase {
  GetCommentsUseCase(this.repository);
  final PostRepository repository;

  ResultFuture<List<Comment>> call(String postId) =>
      repository.getComments(postId);
}
