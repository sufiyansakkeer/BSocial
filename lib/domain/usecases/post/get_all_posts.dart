import '../../../core/utils/typedefs.dart';
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

class GetAllPostsUseCase {
  final PostRepository repository;

  GetAllPostsUseCase(this.repository);

  ResultFuture<List<Post>> call() {
    return repository.getAllPosts();
  }
}
