import 'dart:typed_data';
import '../../../core/utils/typedefs.dart';
import '../../entities/post.dart';
import '../../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  ResultFuture<Post> call({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) {
    return repository.createPost(
      description: description,
      file: file,
      uid: uid,
      username: username,
      profImage: profImage,
    );
  }
}
