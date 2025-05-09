import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../local/storage_local_data_source.dart';

abstract class PostRemoteDataSource {
  Future<PostModel> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  });

  Future<List<PostModel>> getAllPosts();

  Future<List<PostModel>> getPostsByUserId(String userId);

  Future<void> deletePost(String postId);

  Future<void> likePost(String postId, String userId);

  Future<void> unlikePost(String postId, String userId);

  Future<CommentModel> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  });

  Future<List<CommentModel>> getComments(String postId);

  Future<void> deleteComment(String commentId, String postId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
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
      log('Error creating post: $e');
      throw ServerException(message: 'Failed to create post: ${e.toString()}');
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
      log('Error deleting comment: $e');
      throw ServerException(
          message: 'Failed to delete comment: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      // Get the post to get the image URL
      final postDoc = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .get();

      if (!postDoc.exists) {
        throw ServerException(message: 'Post not found');
      }

      final postData = postDoc.data() as Map<String, dynamic>;
      final postUrl = postData['postUrl'] as String;

      // Delete the image from storage
      await _storageDataSource.deleteImage(postUrl);

      // Delete all comments for the post
      final commentsSnapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .get();

      for (final commentDoc in commentsSnapshot.docs) {
        await commentDoc.reference.delete();
      }

      // Delete the post document
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .delete();
    } catch (e) {
      log('Error deleting post: $e');
      throw ServerException(message: 'Failed to delete post: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .orderBy('datePublished', descending: true)
          .get();

      return querySnapshot.docs.map(PostModel.fromSnapshot).toList();
    } catch (e) {
      log('Error getting all posts: $e');
      throw ServerException(message: 'Failed to get posts: ${e.toString()}');
    }
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.commentsCollection)
          .orderBy('datePublished', descending: true)
          .get();

      return querySnapshot.docs.map(CommentModel.fromSnapshot).toList();
    } catch (e) {
      log('Error getting comments: $e');
      throw ServerException(message: 'Failed to get comments: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .where('uid', isEqualTo: userId)
          .orderBy('datePublished', descending: true)
          .get();

      return querySnapshot.docs.map(PostModel.fromSnapshot).toList();
    } catch (e) {
      log('Error getting posts by user ID: $e');
      throw ServerException(
          message: 'Failed to get user posts: ${e.toString()}');
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
      log('Error liking post: $e');
      throw ServerException(message: 'Failed to like post: ${e.toString()}');
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
      log('Error posting comment: $e');
      throw ServerException(message: 'Failed to post comment: ${e.toString()}');
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
      log('Error unliking post: $e');
      throw ServerException(message: 'Failed to unlike post: ${e.toString()}');
    }
  }
}
