import '../../../core/utils/typedefs.dart';
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

class GetPostsByUserIdUseCase {
  final PostRepository repository;

  GetPostsByUserIdUseCase(this.repository);

  ResultFuture<List<Post>> call(String userId) {
    return repository.getPostsByUserId(userId);
  }
}
