import '../../../core/utils/typedefs.dart';
import '../../entities/comment.dart';
import '../../repositories/post_repository.dart';

class PostCommentUseCase {
  final PostRepository repository;

  PostCommentUseCase(this.repository);

  ResultFuture<Comment> call({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  }) {
    return repository.postComment(
      postId: postId,
      text: text,
      uid: uid,
      username: username,
      profilePic: profilePic,
    );
  }
}
