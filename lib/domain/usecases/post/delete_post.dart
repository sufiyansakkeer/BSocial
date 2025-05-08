import '../../../core/utils/typedefs.dart';
import '../../repositories/post_repository.dart';

class DeletePostUseCase {
  final PostRepository repository;

  DeletePostUseCase(this.repository);

  ResultVoid call(String postId) {
    return repository.deletePost(postId);
  }
}
