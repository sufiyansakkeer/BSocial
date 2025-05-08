import 'dart:typed_data';

import '../../core/utils/typedefs.dart';
import '../entities/comment.dart';
import '../entities/post.dart';

// Post repository interface
abstract class PostRepository {
  // Create a new post
  ResultFuture<Post> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  });

  // Get all posts
  ResultFuture<List<Post>> getAllPosts();

  // Get posts by user ID
  ResultFuture<List<Post>> getPostsByUserId(String userId);

  // Delete a post
  ResultVoid deletePost(String postId);

  // Like a post
  ResultVoid likePost(String postId, String userId);

  // Unlike a post
  ResultVoid unlikePost(String postId, String userId);

  // Add a comment to a post
  ResultFuture<Comment> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  });

  // Get comments for a post
  ResultFuture<List<Comment>> getComments(String postId);

  // Delete a comment
  ResultVoid deleteComment(String commentId, String postId);
}
