import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/usecases/post/create_post.dart';
import '../../../domain/usecases/post/delete_comment.dart';
import '../../../domain/usecases/post/delete_post.dart';
import '../../../domain/usecases/post/get_all_posts.dart';
import '../../../domain/usecases/post/get_comments.dart';
import '../../../domain/usecases/post/get_posts_by_user_id.dart';
import '../../../domain/usecases/post/like_post.dart';
import '../../../domain/usecases/post/post_comment.dart';
import '../../../domain/usecases/post/unlike_post.dart';

enum PostStatus { initial, loading, loaded, error }

class PostProvider extends ChangeNotifier {
  final CreatePostUseCase _createPostUseCase;
  final GetAllPostsUseCase _getAllPostsUseCase;
  final GetPostsByUserIdUseCase _getPostsByUserIdUseCase;
  final DeletePostUseCase _deletePostUseCase;
  final LikePostUseCase _likePostUseCase;
  final UnlikePostUseCase _unlikePostUseCase;
  final PostCommentUseCase _postCommentUseCase;
  final GetCommentsUseCase _getCommentsUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  PostProvider({
    required CreatePostUseCase createPostUseCase,
    required GetAllPostsUseCase getAllPostsUseCase,
    required GetPostsByUserIdUseCase getPostsByUserIdUseCase,
    required DeletePostUseCase deletePostUseCase,
    required LikePostUseCase likePostUseCase,
    required UnlikePostUseCase unlikePostUseCase,
    required PostCommentUseCase postCommentUseCase,
    required GetCommentsUseCase getCommentsUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
  })  : _createPostUseCase = createPostUseCase,
        _getAllPostsUseCase = getAllPostsUseCase,
        _getPostsByUserIdUseCase = getPostsByUserIdUseCase,
        _deletePostUseCase = deletePostUseCase,
        _likePostUseCase = likePostUseCase,
        _unlikePostUseCase = unlikePostUseCase,
        _postCommentUseCase = postCommentUseCase,
        _getCommentsUseCase = getCommentsUseCase,
        _deleteCommentUseCase = deleteCommentUseCase;

  // State variables
  PostStatus _status = PostStatus.initial;
  List<Post> _posts = [];
  List<Post> _userPosts = [];
  Post? _selectedPost;
  List<Comment> _comments = [];
  String _errorMessage = '';
  bool _isCreatingPost = false;

  // Getters
  PostStatus get status => _status;
  List<Post> get posts => _posts;
  List<Post> get userPosts => _userPosts;
  Post? get selectedPost => _selectedPost;
  List<Comment> get comments => _comments;
  String get errorMessage => _errorMessage;
  bool get isCreatingPost => _isCreatingPost;

  // Create a new post
  Future<bool> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) async {
    _isCreatingPost = true;
    notifyListeners();

    final result = await _createPostUseCase(
      description: description,
      file: file,
      uid: uid,
      username: username,
      profImage: profImage,
    );

    _isCreatingPost = false;

    return result.fold(
      (failure) {
        _status = PostStatus.error;
        _errorMessage = failure.message;
        log('Error creating post: ${failure.message}');
        notifyListeners();
        return false;
      },
      (post) {
        // Add the new post to the posts list
        _posts = [post, ..._posts];
        if (post.uid == uid) {
          _userPosts = [post, ..._userPosts];
        }
        _status = PostStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Get all posts with error handling
  Future<void> getAllPosts() async {
    try {
      // Only set loading state if we're not already loading
      if (_status != PostStatus.loading) {
        _status = PostStatus.loading;
        notifyListeners();
      }

      final result = await _getAllPostsUseCase();

      // Use try-catch to handle any unexpected errors in the fold operation
      try {
        result.fold(
          (failure) {
            _status = PostStatus.error;
            _errorMessage = failure.message;
            log('Error getting all posts: ${failure.message}');
          },
          (posts) {
            _posts = posts;
            _status = PostStatus.loaded;
          },
        );
      } catch (e) {
        _status = PostStatus.error;
        _errorMessage = 'Unexpected error: $e';
        log('Unexpected error in getAllPosts fold: $e');
      }

      // Only notify if the widget is still mounted
      notifyListeners();
    } catch (e) {
      // Catch any exceptions that might occur
      _status = PostStatus.error;
      _errorMessage = 'Failed to load posts: $e';
      log('Exception in getAllPosts: $e');
      notifyListeners();
    }
  }

  // Get posts by user ID
  Future<void> getPostsByUserId(String userId) async {
    _status = PostStatus.loading;
    notifyListeners();

    final result = await _getPostsByUserIdUseCase(userId);

    result.fold(
      (failure) {
        _status = PostStatus.error;
        _errorMessage = failure.message;
        log('Error getting user posts: ${failure.message}');
      },
      (posts) {
        _userPosts = posts;
        _status = PostStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Delete a post
  Future<bool> deletePost(String postId) async {
    _status = PostStatus.loading;
    notifyListeners();

    final result = await _deletePostUseCase(postId);

    return result.fold(
      (failure) {
        _status = PostStatus.error;
        _errorMessage = failure.message;
        log('Error deleting post: ${failure.message}');
        notifyListeners();
        return false;
      },
      (_) {
        // Remove the deleted post from the posts list
        _posts = _posts.where((post) => post.postId != postId).toList();
        _userPosts = _userPosts.where((post) => post.postId != postId).toList();
        _status = PostStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Like a post
  Future<bool> likePost(String postId, String userId) async {
    final result = await _likePostUseCase(postId, userId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        log('Error liking post: ${failure.message}');
        notifyListeners();
        return false;
      },
      (_) {
        // Update the post in the posts list
        _updatePostLikes(postId, userId, true);
        notifyListeners();
        return true;
      },
    );
  }

  // Unlike a post
  Future<bool> unlikePost(String postId, String userId) async {
    final result = await _unlikePostUseCase(postId, userId);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        log('Error unliking post: ${failure.message}');
        notifyListeners();
        return false;
      },
      (_) {
        // Update the post in the posts list
        _updatePostLikes(postId, userId, false);
        notifyListeners();
        return true;
      },
    );
  }

  // Helper method to update post likes
  void _updatePostLikes(String postId, String userId, bool isLiking) {
    // Update in all posts list
    final postIndex = _posts.indexWhere((post) => post.postId == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final likes = List<String>.from(post.likes);

      if (isLiking) {
        if (!likes.contains(userId)) {
          likes.add(userId);
        }
      } else {
        likes.remove(userId);
      }

      // Create a new post with updated likes
      Post updatedPost;
      if (post is PostModel) {
        updatedPost = PostModel(
          postId: post.postId,
          uid: post.uid,
          username: post.username,
          description: post.description,
          postUrl: post.postUrl,
          profImage: post.profImage,
          datePublished: post.datePublished,
          likes: likes,
        );
      } else {
        // Create a generic Post if it's not a PostModel
        updatedPost = Post(
          postId: post.postId,
          uid: post.uid,
          username: post.username,
          description: post.description,
          postUrl: post.postUrl,
          profImage: post.profImage,
          datePublished: post.datePublished,
          likes: likes,
        );
      }

      _posts[postIndex] = updatedPost;

      // If this post is also in user posts, update it there too
      final userPostIndex =
          _userPosts.indexWhere((post) => post.postId == postId);
      if (userPostIndex != -1) {
        _userPosts[userPostIndex] = updatedPost;
      }

      // If this is the selected post, update it too
      if (_selectedPost?.postId == postId) {
        _selectedPost = updatedPost;
      }
    }
  }

  // Post a comment
  Future<bool> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  }) async {
    _status = PostStatus.loading;
    notifyListeners();

    final result = await _postCommentUseCase(
      postId: postId,
      text: text,
      uid: uid,
      username: username,
      profilePic: profilePic,
    );

    return result.fold(
      (failure) {
        _status = PostStatus.error;
        _errorMessage = failure.message;
        log('Error posting comment: ${failure.message}');
        notifyListeners();
        return false;
      },
      (comment) {
        // Add the new comment to the comments list
        _comments = [comment, ..._comments];
        _status = PostStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Get comments for a post
  Future<void> getComments(String postId) async {
    _status = PostStatus.loading;
    notifyListeners();

    final result = await _getCommentsUseCase(postId);

    result.fold(
      (failure) {
        _status = PostStatus.error;
        _errorMessage = failure.message;
        log('Error getting comments: ${failure.message}');
      },
      (comments) {
        _comments = comments;
        _status = PostStatus.loaded;
      },
    );

    notifyListeners();
  }

  // Delete a comment
  Future<bool> deleteComment(String commentId, String postId) async {
    _status = PostStatus.loading;
    notifyListeners();

    final result = await _deleteCommentUseCase(commentId, postId);

    return result.fold(
      (failure) {
        _status = PostStatus.error;
        _errorMessage = failure.message;
        log('Error deleting comment: ${failure.message}');
        notifyListeners();
        return false;
      },
      (_) {
        // Remove the deleted comment from the comments list
        _comments = _comments
            .where((comment) => comment.commentId != commentId)
            .toList();
        _status = PostStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // Set selected post
  void setSelectedPost(Post post) {
    _selectedPost = post;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
