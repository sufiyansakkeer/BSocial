import '../../../core/utils/typedefs.dart';
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

class GetAllPostsUseCase {
  GetAllPostsUseCase(this.repository);
  final PostRepository repository;

  ResultFuture<List<Post>> call() => repository.getAllPosts();
}
