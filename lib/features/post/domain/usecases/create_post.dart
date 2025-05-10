import 'dart:typed_data';
import '../../../../core/utils/typedefs.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case to create a new post
class CreatePostUseCase {
  /// Constructor
  CreatePostUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultFuture<Post> call({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) =>
      repository.createPost(
        description: description,
        file: file,
        uid: uid,
        username: username,
        profImage: profImage,
      );
}
