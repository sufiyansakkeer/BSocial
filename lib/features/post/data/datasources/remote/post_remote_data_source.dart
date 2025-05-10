import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/datasources/local/storage_local_data_source.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';

/// Interface for post remote data source
abstract class PostRemoteDataSource {
  /// Create a new post
  Future<PostModel> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  });

  /// Get all posts
  Future<List<PostModel>> getAllPosts();

  /// Get posts by user ID
  Future<List<PostModel>> getPostsByUserId(String userId);

  /// Delete a post
  Future<void> deletePost(String postId);

  /// Like a post
  Future<void> likePost(String postId, String userId);

  /// Unlike a post
  Future<void> unlikePost(String postId, String userId);

  /// Add a comment to a post
  Future<CommentModel> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  });

  /// Get comments for a post
  Future<List<CommentModel>> getComments(String postId);

  /// Delete a comment
  Future<void> deleteComment(String commentId, String postId);
}

/// Implementation of [PostRemoteDataSource]
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  /// Constructor
  PostRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required StorageLocalDataSource storageDataSource,
  })  : _firestore = firestore,
        _storageDataSource = storageDataSource;

  final FirebaseFirestore _firestore;
  final StorageLocalDataSource _storageDataSource;

  @override
  Future<PostModel> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) async {
    try {
      // Upload image to storage
      final postUrl = await _storageDataSource.uploadImage(
        AppConstants.postsPath,
        file,
        isPost: true,
      );

      // Generate a unique post ID
      final postId = const Uuid().v1();

      // Create post model
      final post = PostModel(
        postId: postId,
        uid: uid,
        username: username,
        description: description,
        postUrl: postUrl,
        profImage: profImage,
        datePublished: DateTime.now(),
        likes: [],
      );

      // Save post to Firestore
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .set(post.toJson());

      return post;
    } catch (e) {
      throw ServerException(message: 'Failed to create post: $e');
    }
  }

  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .orderBy('datePublished', descending: true)
          .get();

      return snapshot.docs.map(PostModel.fromSnapshot).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .where('uid', isEqualTo: userId)
          .orderBy('datePublished', descending: true)
          .get();

      return snapshot.docs.map(PostModel.fromSnapshot).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get user posts: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete post: $e');
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'likes': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      throw ServerException(message: 'Failed to like post: $e');
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      throw ServerException(message: 'Failed to unlike post: $e');
    }
  }

  @override
  Future<CommentModel> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  }) async {
    try {
      // Generate a unique comment ID
      final commentId = const Uuid().v1();

      // Create comment model
      final comment = CommentModel(
        commentId: commentId,
        postId: postId,
        uid: uid,
        username: username,
        text: text,
        profilePic: profilePic,
        datePublished: DateTime.now(),
      );

      // Save comment to Firestore
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .set(comment.toJson());

      return comment;
    } catch (e) {
      throw ServerException(message: 'Failed to post comment: $e');
    }
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .orderBy('datePublished', descending: true)
          .get();

      return snapshot.docs.map(CommentModel.fromSnapshot).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get comments: $e');
    }
  }

  @override
  Future<void> deleteComment(String commentId, String postId) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete comment: $e');
    }
  }
}
