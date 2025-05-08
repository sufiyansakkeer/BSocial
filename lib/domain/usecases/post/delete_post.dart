import '../../../core/utils/typedefs.dart';
import '../../repositories/post_repository.dart';

class DeletePostUseCase {
  DeletePostUseCase(this.repository);
  final PostRepository repository;

  ResultVoid call(String postId) => repository.deletePost(postId);
}
