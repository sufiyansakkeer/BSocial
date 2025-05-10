import 'dart:developer';
import 'dart:typed_data';

import 'package:dartz/dartz.dart'; // Added to ensure Either, Left, Right are in scope

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/local/post_local_data_source.dart';
import '../datasources/remote/post_remote_data_source.dart';

/// Implementation of [PostRepository] with caching
class CachedPostRepositoryImpl implements PostRepository {
  /// Constructor
  CachedPostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.cacheMaxAge = const Duration(hours: 1),
  });

  /// Remote data source
  final PostRemoteDataSource remoteDataSource;

  /// Local data source
  final PostLocalDataSource localDataSource;

  /// Maximum age of cached data
  final Duration cacheMaxAge;

  /// Handle remote call with error handling
  Future<T> _handleRemoteCall<T>({
    required Future<T> Function() call,
    required String errorMessage,
  }) async {
    try {
      return await call();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw ServerFailure(message: '$errorMessage: $e');
    }
  }

  /// Handle remote call with local fallback
  Future<T> _handleRemoteCallWithLocalFallback<T>({
    required Future<T> Function() remoteCall,
    required Future<T> Function() localCall,
    required String remoteErrorMessage,
    required String localErrorMessage,
  }) async {
    try {
      return await remoteCall();
    } on ServerException catch (e) {
      log('Remote call failed: ${e.message}. Trying local fallback.');
      try {
        return await localCall();
      } on CacheException catch (e) {
        throw CacheFailure(message: e.message);
      } catch (e) {
        throw CacheFailure(message: '$localErrorMessage: $e');
      }
    } catch (e) {
      log('Remote call failed: $e. Trying local fallback.');
      try {
        return await localCall();
      } on CacheException catch (e) {
        throw CacheFailure(message: e.message);
      } catch (e) {
        throw CacheFailure(message: '$localErrorMessage: $e');
      }
    }
  }

  @override
  ResultFuture<Post> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) async {
    try {
      final post = await _handleRemoteCall(
        call: () => remoteDataSource.createPost(
          description: description,
          file: file,
          uid: uid,
          username: username,
          profImage: profImage,
        ),
        errorMessage: 'Failed to create post',
      );

      // Cache the post locally
      try {
        await localDataSource.cachePost(post);
      } catch (e) {
        log('Error caching post: $e');
        // Continue even if caching fails
      }

      return Right(post);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Post>> getAllPosts() async {
    try {
      final posts = await _handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get posts from remote
          final remotePosts = await remoteDataSource.getAllPosts();

          // Cache posts locally
          for (final post in remotePosts) {
            try {
              await localDataSource.cachePost(post);
            } catch (e) {
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

      return Right(posts);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Post>> getPostsByUserId(String userId) async {
    try {
      final posts = await _handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get posts from remote
          final remotePosts = await remoteDataSource.getPostsByUserId(userId);

          // Cache posts locally
          for (final post in remotePosts) {
            try {
              await localDataSource.cachePost(post);
            } catch (e) {
              log('Error caching post: $e');
              // Continue even if caching fails
            }
          }

          return remotePosts;
        },
        localCall: () async {
          final localPosts = await localDataSource.getPostsByUserId(userId);
          if (localPosts.isEmpty) {
            throw CacheException(
                message: 'No cached posts available for user $userId');
          }
          log('Returning user posts from cache');
          return localPosts;
        },
        remoteErrorMessage: 'Failed to fetch user posts from server',
        localErrorMessage: 'No cached user posts available',
      );

      return Right(posts);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deletePost(String postId) async {
    try {
      await _handleRemoteCall(
        call: () => remoteDataSource.deletePost(postId),
        errorMessage: 'Failed to delete post',
      );

      // Delete from local cache
      try {
        await localDataSource.deletePost(postId);
      } catch (e) {
        log('Error deleting post from cache: $e');
        // Continue even if cache deletion fails
      }

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid likePost(String postId, String userId) async {
    try {
      await _handleRemoteCall(
        call: () => remoteDataSource.likePost(postId, userId),
        errorMessage: 'Failed to like post',
      );

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid unlikePost(String postId, String userId) async {
    try {
      await _handleRemoteCall(
        call: () => remoteDataSource.unlikePost(postId, userId),
        errorMessage: 'Failed to unlike post',
      );

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<Comment> postComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
    required String profilePic,
  }) async {
    try {
      final comment = await _handleRemoteCall(
        call: () => remoteDataSource.postComment(
          postId: postId,
          text: text,
          uid: uid,
          username: username,
          profilePic: profilePic,
        ),
        errorMessage: 'Failed to post comment',
      );

      // Cache the comment locally
      try {
        await localDataSource.cacheComment(comment);
      } catch (e) {
        log('Error caching comment: $e');
        // Continue even if caching fails
      }

      return Right(comment);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Comment>> getComments(String postId) async {
    try {
      final comments = await _handleRemoteCallWithLocalFallback(
        remoteCall: () async {
          // Get comments from remote
          final remoteComments = await remoteDataSource.getComments(postId);

          // Cache comments locally
          for (final comment in remoteComments) {
            try {
              await localDataSource.cacheComment(comment);
            } catch (e) {
              log('Error caching comment: $e');
              // Continue even if caching fails
            }
          }

          return remoteComments;
        },
        localCall: () async {
          final localComments = await localDataSource.getComments(postId);
          if (localComments.isEmpty) {
            throw CacheException(
                message: 'No cached comments available for post $postId');
          }
          log('Returning comments from cache');
          return localComments;
        },
        remoteErrorMessage: 'Failed to fetch comments from server',
        localErrorMessage: 'No cached comments available',
      );

      return Right(comments);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultVoid deleteComment(String commentId, String postId) async {
    try {
      await _handleRemoteCall(
        call: () => remoteDataSource.deleteComment(commentId, postId),
        errorMessage: 'Failed to delete comment',
      );

      // Delete from local cache
      try {
        await localDataSource.deleteComment(commentId, postId);
      } catch (e) {
        log('Error deleting comment from cache: $e');
        // Continue even if cache deletion fails
      }

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
