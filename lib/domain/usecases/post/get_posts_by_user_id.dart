import '../../../core/utils/typedefs.dart';
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

class GetPostsByUserIdUseCase {
  GetPostsByUserIdUseCase(this.repository);
  final PostRepository repository;

  ResultFuture<List<Post>> call(String userId) =>
      repository.getPostsByUserId(userId);
}
