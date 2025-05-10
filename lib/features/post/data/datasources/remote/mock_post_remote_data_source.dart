import 'dart:typed_data';

import '../../../../../core/errors/exceptions.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import 'post_remote_data_source.dart';

/// Mock implementation of [PostRemoteDataSource] for offline mode
class MockPostRemoteDataSourceImpl implements PostRemoteDataSource {
  @override
  Future<PostModel> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) async {
    // Return a mock post or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<List<PostModel>> getAllPosts() async =>
      []; // Return an empty list in offline mode

  @override
  Future<List<PostModel>> getPostsByUserId(String userId) async =>
      []; // Return an empty list in offline mode

  @override
  Future<void> deletePost(String postId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<CommentModel> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  }) async {
    // Return a mock comment or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async =>
      []; // Return an empty list in offline mode

  @override
  Future<void> deleteComment(String commentId, String postId) async {
    // No-op in offline mode or throw an exception
    throw ServerException(message: 'Not available in offline mode');
  }
}
