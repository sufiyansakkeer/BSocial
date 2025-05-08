import 'dart:developer';
import 'dart:typed_data';
import '../../core/errors/exceptions.dart';
import '../../core/repositories/base_repository.dart';
import '../../core/utils/typedefs.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/local/hive_local_data_source.dart';
import '../datasources/remote/post_remote_data_source.dart';

/// Implementation of [PostRepository] that uses both remote and local data sources
/// with offline caching support
class CachedPostRepositoryImpl extends BaseRepository
    implements PostRepository {
  CachedPostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required super.networkInfo,
    this.cacheMaxAge =
        const Duration(hours: 24), // Default cache age is 24 hours
  });
  final PostRemoteDataSource remoteDataSource;
  final HiveLocalDataSource localDataSource;
  final Duration cacheMaxAge;

  @override
  ResultFuture<Post> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) =>
      handleRemoteCall(
        call: () async {
          final post = await remoteDataSource.createPost(
            description: description,
            file: file,
            uid: uid,
            username: username,
            profImage: profImage,
          );

          // Cache the post locally
          try {
            await localDataSource.cachePost(post);
          } on Exception catch (e) {
            log('Error caching post: $e');
            // Continue even if caching fails
          }

          return post;
        },
        errorMessage: 'Failed to create post',
      );

  @override
  ResultVoid deletePost(String postId) => handleRemoteCall(
        call: () async {
          await remoteDataSource.deletePost(postId);

          // Delete from local cache
          try {
            await localDataSource.deletePost(postId);
          } on Exception catch (e) {
            log('Error deleting post from cache: $e');
            // Continue even if cache deletion fails
          }

          return;
        },
        errorMessage: 'Failed to delete post',
      );

  @override
  ResultFuture<List<Post>> getAllPosts() => handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get posts from remote
          final remotePosts = await remoteDataSource.getAllPosts();

          // Cache posts locally
          for (final post in remotePosts) {
            try {
              await localDataSource.cachePost(post);
            } on Exception catch (e) {
              log('Error caching post: $e');
              // Continue even if caching fails
            }
          }

          return remotePosts;
        },
        localCall: () async {
          final localPosts = await localDataSource.getAllPosts();
          if (localPosts.isEmpty) {
            throw CacheException(message: 'No cached posts available');
          }
          log('Returning posts from cache');
          return localPosts;
        },
        remoteErrorMessage: 'Failed to fetch posts from server',
        localErrorMessage: 'No cached posts available',
      );

  @override
  ResultFuture<List<Post>> getPostsByUserId(String userId) =>
      handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get posts from remote
          final remotePosts = await remoteDataSource.getPostsByUserId(userId);

          // Cache posts locally
          for (final post in remotePosts) {
            try {
              await localDataSource.cachePost(post);
            } on Exception catch (e) {
              log('Error caching user post: $e');
              // Continue even if caching fails
            }
          }

          return remotePosts;
        },
        localCall: () async {
          final localPosts = await localDataSource.getPostsByUserId(userId);
          if (localPosts.isEmpty) {
            throw CacheException(
                message: 'No cached posts available for this user');
          }
          log('Returning user posts from cache');
          return localPosts;
        },
        remoteErrorMessage: 'Failed to fetch user posts from server',
        localErrorMessage: 'No cached posts available for this user',
      );

  @override
  ResultVoid likePost(String postId, String userId) => handleRemoteCall(
        call: () async {
          await remoteDataSource.likePost(postId, userId);

          // Update post likes in local cache
          try {
            final post = await localDataSource.getPost(postId);
            if (post != null) {
              final updatedLikes = [...post.likes, userId];
              await localDataSource.updatePostLikes(postId, updatedLikes);
            }
          } on Exception catch (e) {
            log('Error updating post likes in cache: $e');
            // Continue even if cache update fails
          }

          return;
        },
        errorMessage: 'Failed to like post',
      );

  @override
  ResultVoid unlikePost(String postId, String userId) => handleRemoteCall(
        call: () async {
          await remoteDataSource.unlikePost(postId, userId);

          // Update post likes in local cache
          try {
            final post = await localDataSource.getPost(postId);
            if (post != null) {
              final updatedLikes =
                  post.likes.where((id) => id != userId).toList();
              await localDataSource.updatePostLikes(postId, updatedLikes);
            }
          } on Exception catch (e) {
            log('Error updating post likes in cache: $e');
            // Continue even if cache update fails
          }

          return;
        },
        errorMessage: 'Failed to unlike post',
      );

  @override
  ResultFuture<Comment> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  }) =>
      handleRemoteCall(
        call: () async {
          final comment = await remoteDataSource.postComment(
            postId: postId,
            text: text,
            uid: uid,
            username: username,
            profilePic: profilePic,
          );

          // Cache the comment locally
          try {
            await localDataSource.cacheComment(comment);
          } on Exception catch (e) {
            log('Error caching comment: $e');
            // Continue even if caching fails
          }

          return comment;
        },
        errorMessage: 'Failed to post comment',
      );

  @override
  ResultFuture<List<Comment>> getComments(String postId) =>
      handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get comments from remote
          final remoteComments = await remoteDataSource.getComments(postId);

          // Cache comments locally
          for (final comment in remoteComments) {
            try {
              await localDataSource.cacheComment(comment);
            } on Exception catch (e) {
              log('Error caching comment: $e');
              // Continue even if caching fails
            }
          }

          return remoteComments;
        },
        localCall: () async {
          final localComments =
              await localDataSource.getCommentsByPostId(postId);
          if (localComments.isEmpty) {
            throw CacheException(
                message: 'No cached comments available for this post');
          }
          log('Returning comments from cache');
          return localComments;
        },
        remoteErrorMessage: 'Failed to fetch comments from server',
        localErrorMessage: 'No cached comments available for this post',
      );

  @override
  ResultVoid deleteComment(String commentId, String postId) => handleRemoteCall(
        call: () async {
          await remoteDataSource.deleteComment(commentId, postId);

          // Delete from local cache
          try {
            await localDataSource.deleteComment(commentId);
          } on Exception catch (e) {
            log('Error deleting comment from cache: $e');
            // Continue even if cache deletion fails
          }

          return;
        },
        errorMessage: 'Failed to delete comment',
      );
}
