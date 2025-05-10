import '../../../../core/utils/typedefs.dart';
import '../entities/comment.dart';
import '../repositories/post_repository.dart';

/// Use case to post a comment
class PostCommentUseCase {
  /// Constructor
  PostCommentUseCase(this.repository);
  
  /// Post repository
  final PostRepository repository;

  /// Execute the use case
  ResultFuture<Comment> call({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  }) =>
      repository.postComment(
        postId: postId,
        text: text,
        uid: uid,
        username: username,
        profilePic: profilePic,
      );
}
