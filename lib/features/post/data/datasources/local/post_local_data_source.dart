import 'dart:developer';
import 'package:hive/hive.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../data/models/hive/comment_hive_model.dart';
import '../../../../../data/models/hive/post_hive_model.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';

/// Interface for post local data source
abstract class PostLocalDataSource {
  /// Cache a post
  Future<void> cachePost(PostModel post);

  /// Get all cached posts
  Future<List<PostModel>> getAllPosts();

  /// Get cached posts by user ID
  Future<List<PostModel>> getPostsByUserId(String userId);

  /// Delete a cached post
  Future<void> deletePost(String postId);

  /// Cache a comment
  Future<void> cacheComment(CommentModel comment);

  /// Get all cached comments for a post
  Future<List<CommentModel>> getComments(String postId);

  /// Delete a cached comment
  Future<void> deleteComment(String commentId, String postId);

  /// Clear all cached posts
  Future<void> clearPosts();

  /// Clear all cached comments
  Future<void> clearComments();
}

/// Implementation of [PostLocalDataSource]
class PostLocalDataSourceImpl implements PostLocalDataSource {
  /// Constructor
  PostLocalDataSourceImpl();

  /// Box name for posts
  static const String _postsBoxName = 'posts';

  /// Box name for comments
  static const String _commentsBoxName = 'comments';

  /// Get posts box
  Future<Box<PostHiveModel>> get _postsBox async {
    try {
      if (Hive.isBoxOpen(_postsBoxName)) {
        return Hive.box<PostHiveModel>(_postsBoxName);
      } else {
        return await Hive.openBox<PostHiveModel>(_postsBoxName);
      }
    } on Exception catch (e) {
      log('Error opening posts box: $e', name: '_postsBox');
      // Try to delete and recreate the box if there's an issue
      try {
        if (await Hive.boxExists(_postsBoxName)) {
          await Hive.deleteBoxFromDisk(_postsBoxName);
        }
        return await Hive.openBox<PostHiveModel>(_postsBoxName);
      } on Exception catch (e) {
        log('Failed to recover posts box: $e', name: '_postsBox');
        rethrow;
      }
    }
  }

  /// Get comments box
  Future<Box<CommentHiveModel>> get _commentsBox async {
    try {
      if (Hive.isBoxOpen(_commentsBoxName)) {
        return Hive.box<CommentHiveModel>(_commentsBoxName);
      } else {
        return await Hive.openBox<CommentHiveModel>(_commentsBoxName);
      }
    } on Exception catch (e) {
      log('Error opening comments box: $e', name: '_commentsBox');
      // Try to delete and recreate the box if there's an issue
      try {
        if (await Hive.boxExists(_commentsBoxName)) {
          await Hive.deleteBoxFromDisk(_commentsBoxName);
        }
        return await Hive.openBox<CommentHiveModel>(_commentsBoxName);
      } on Exception catch (e) {
        log('Failed to recover comments box: $e', name: '_commentsBox');
        rethrow;
      }
    }
  }

  @override
  Future<void> cachePost(PostModel post) async {
    try {
      final box = await _postsBox;
      // Create a PostHiveModel directly instead of using fromEntity
      final hiveModel = PostHiveModel(
        postId: post.postId,
        uid: post.uid,
        username: post.username,
        description: post.description,
        postUrl: post.postUrl,
        profImage: post.profImage,
        datePublished: post.datePublished,
        likes: post.likes,
        lastUpdated: DateTime.now(),
      );
      await box.put(post.postId, hiveModel);
      log('Post cached: ${post.postId}', name: 'cachePost');
    } on Exception catch (e) {
      log('Error caching post: $e', name: 'cachePost');
      throw CacheException(message: 'Failed to cache post: $e');
    }
  }

  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final box = await _postsBox;
      return box.values
          .map((hiveModel) => PostModel(
                postId: hiveModel.postId,
                uid: hiveModel.uid,
                username: hiveModel.username,
                description: hiveModel.description,
                postUrl: hiveModel.postUrl,
                profImage: hiveModel.profImage,
                datePublished: hiveModel.datePublished,
                likes: hiveModel.likes,
              ))
          .toList();
    } catch (e) {
      log('Error getting cached posts: $e', name: 'getAllPosts');
      throw CacheException(message: 'Failed to get cached posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(String userId) async {
    try {
      final box = await _postsBox;
      return box.values
          .where((hiveModel) => hiveModel.uid == userId)
          .map((hiveModel) => PostModel(
                postId: hiveModel.postId,
                uid: hiveModel.uid,
                username: hiveModel.username,
                description: hiveModel.description,
                postUrl: hiveModel.postUrl,
                profImage: hiveModel.profImage,
                datePublished: hiveModel.datePublished,
                likes: hiveModel.likes,
              ))
          .toList();
    } catch (e) {
      log('Error getting cached user posts: $e', name: 'getPostsByUserId');
      throw CacheException(message: 'Failed to get cached user posts: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      final box = await _postsBox;
      await box.delete(postId);
      log('Post deleted from cache: $postId', name: 'deletePost');
    } catch (e) {
      log('Error deleting cached post: $e', name: 'deletePost');
      throw CacheException(message: 'Failed to delete cached post: $e');
    }
  }

  @override
  Future<void> cacheComment(CommentModel comment) async {
    try {
      final box = await _commentsBox;
      // Create a CommentHiveModel directly instead of using fromEntity
      final hiveModel = CommentHiveModel(
        commentId: comment.commentId,
        postId: comment.postId,
        uid: comment.uid,
        username: comment.username,
        text: comment.text,
        profilePic: comment.profilePic,
        datePublished: comment.datePublished,
        lastUpdated: DateTime.now(),
      );
      await box.put(comment.commentId, hiveModel);
      log('Comment cached: ${comment.commentId}', name: 'cacheComment');
    } catch (e) {
      log('Error caching comment: $e', name: 'cacheComment');
      throw CacheException(message: 'Failed to cache comment: $e');
    }
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final box = await _commentsBox;
      return box.values
          .where((hiveModel) => hiveModel.postId == postId)
          .map((hiveModel) => CommentModel(
                commentId: hiveModel.commentId,
                postId: hiveModel.postId,
                uid: hiveModel.uid,
                username: hiveModel.username,
                text: hiveModel.text,
                profilePic: hiveModel.profilePic,
                datePublished: hiveModel.datePublished,
              ))
          .toList();
    } catch (e) {
      log('Error getting cached comments: $e', name: 'getComments');
      throw CacheException(message: 'Failed to get cached comments: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId, String postId) async {
    try {
      final box = await _commentsBox;
      await box.delete(commentId);
      log('Comment deleted from cache: $commentId', name: 'deleteComment');
    } catch (e) {
      log('Error deleting cached comment: $e', name: 'deleteComment');
      throw CacheException(message: 'Failed to delete cached comment: $e');
    }
  }

  @override
  Future<void> clearPosts() async {
    try {
      final box = await _postsBox;
      await box.clear();
      log('All posts cleared from cache', name: 'clearPosts');
    } catch (e) {
      log('Error clearing cached posts: $e', name: 'clearPosts');
      throw CacheException(message: 'Failed to clear cached posts: $e');
    }
  }

  @override
  Future<void> clearComments() async {
    try {
      final box = await _commentsBox;
      await box.clear();
      log('All comments cleared from cache', name: 'clearComments');
    } catch (e) {
      log('Error clearing cached comments: $e', name: 'clearComments');
      throw CacheException(message: 'Failed to clear cached comments: $e');
    }
  }
}
