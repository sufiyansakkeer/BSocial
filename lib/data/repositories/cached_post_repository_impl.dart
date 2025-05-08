import 'dart:developer';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/typedefs.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/local/hive_local_data_source.dart';
import '../datasources/remote/post_remote_data_source.dart';

/// Implementation of [PostRepository] that uses both remote and local data sources
/// with offline caching support
class CachedPostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final HiveLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Duration cacheMaxAge;

  CachedPostRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    this.cacheMaxAge =
        const Duration(hours: 24), // Default cache age is 24 hours
  });

  @override
  ResultFuture<Post> createPost({
    required String description,
    required Uint8List file,
    required String uid,
    required String username,
    required String profImage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
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
        } catch (e) {
          log('Error caching post: $e');
          // Continue even if caching fails
        }

        return Right(post);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultVoid deletePost(String postId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deletePost(postId);

        // Delete from local cache
        try {
          await localDataSource.deletePost(postId);
        } catch (e) {
          log('Error deleting post from cache: $e');
          // Continue even if cache deletion fails
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultFuture<List<Post>> getAllPosts() async {
    if (await networkInfo.isConnected) {
      try {
        // Get posts from remote
        final remotePosts = await remoteDataSource.getAllPosts();

        // Cache posts locally
        try {
          for (var post in remotePosts) {
            await localDataSource.cachePost(post);
          }
        } catch (e) {
          log('Error caching posts: $e');
          // Continue even if caching fails
        }

        return Right(remotePosts);
      } on ServerException catch (e) {
        // Try to get posts from local cache if remote fails
        try {
          final localPosts = await localDataSource.getAllPosts();
          if (localPosts.isNotEmpty) {
            log('Returning posts from cache after remote failure');
            return Right(localPosts);
          }
        } catch (cacheE) {
          log('Error getting posts from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Try to get posts from local cache if remote fails
        try {
          final localPosts = await localDataSource.getAllPosts();
          if (localPosts.isNotEmpty) {
            log('Returning posts from cache after remote failure');
            return Right(localPosts);
          }
        } catch (cacheE) {
          log('Error getting posts from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get posts from local cache
      try {
        final localPosts = await localDataSource.getAllPosts();
        if (localPosts.isNotEmpty) {
          log('Returning posts from cache due to no internet');
          return Right(localPosts);
        } else {
          return const Left(CacheFailure(message: 'No cached posts available'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultFuture<List<Post>> getPostsByUserId(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get posts from remote
        final remotePosts = await remoteDataSource.getPostsByUserId(userId);

        // Cache posts locally
        try {
          for (var post in remotePosts) {
            await localDataSource.cachePost(post);
          }
        } catch (e) {
          log('Error caching user posts: $e');
          // Continue even if caching fails
        }

        return Right(remotePosts);
      } on ServerException catch (e) {
        // Try to get posts from local cache if remote fails
        try {
          final localPosts = await localDataSource.getPostsByUserId(userId);
          if (localPosts.isNotEmpty) {
            log('Returning user posts from cache after remote failure');
            return Right(localPosts);
          }
        } catch (cacheE) {
          log('Error getting user posts from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Try to get posts from local cache if remote fails
        try {
          final localPosts = await localDataSource.getPostsByUserId(userId);
          if (localPosts.isNotEmpty) {
            log('Returning user posts from cache after remote failure');
            return Right(localPosts);
          }
        } catch (cacheE) {
          log('Error getting user posts from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get posts from local cache
      try {
        final localPosts = await localDataSource.getPostsByUserId(userId);
        if (localPosts.isNotEmpty) {
          log('Returning user posts from cache due to no internet');
          return Right(localPosts);
        } else {
          return const Left(
              CacheFailure(message: 'No cached posts available for this user'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultVoid likePost(String postId, String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.likePost(postId, userId);

        // Update post likes in local cache
        try {
          final post = await localDataSource.getPost(postId);
          if (post != null) {
            final updatedLikes = [...post.likes, userId];
            await localDataSource.updatePostLikes(postId, updatedLikes);
          }
        } catch (e) {
          log('Error updating post likes in cache: $e');
          // Continue even if cache update fails
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultVoid unlikePost(String postId, String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unlikePost(postId, userId);

        // Update post likes in local cache
        try {
          final post = await localDataSource.getPost(postId);
          if (post != null) {
            final updatedLikes =
                post.likes.where((id) => id != userId).toList();
            await localDataSource.updatePostLikes(postId, updatedLikes);
          }
        } catch (e) {
          log('Error updating post likes in cache: $e');
          // Continue even if cache update fails
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
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
    if (await networkInfo.isConnected) {
      try {
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
        } catch (e) {
          log('Error caching comment: $e');
          // Continue even if caching fails
        }

        return Right(comment);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  ResultFuture<List<Comment>> getComments(String postId) async {
    if (await networkInfo.isConnected) {
      try {
        // Get comments from remote
        final remoteComments = await remoteDataSource.getComments(postId);

        // Cache comments locally
        try {
          for (var comment in remoteComments) {
            await localDataSource.cacheComment(comment);
          }
        } catch (e) {
          log('Error caching comments: $e');
          // Continue even if caching fails
        }

        return Right(remoteComments);
      } on ServerException catch (e) {
        // Try to get comments from local cache if remote fails
        try {
          final localComments =
              await localDataSource.getCommentsByPostId(postId);
          if (localComments.isNotEmpty) {
            log('Returning comments from cache after remote failure');
            return Right(localComments);
          }
        } catch (cacheE) {
          log('Error getting comments from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.message));
      } catch (e) {
        // Try to get comments from local cache if remote fails
        try {
          final localComments =
              await localDataSource.getCommentsByPostId(postId);
          if (localComments.isNotEmpty) {
            log('Returning comments from cache after remote failure');
            return Right(localComments);
          }
        } catch (cacheE) {
          log('Error getting comments from cache: $cacheE');
        }

        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      // No internet connection, try to get comments from local cache
      try {
        final localComments = await localDataSource.getCommentsByPostId(postId);
        if (localComments.isNotEmpty) {
          log('Returning comments from cache due to no internet');
          return Right(localComments);
        } else {
          return const Left(CacheFailure(
              message: 'No cached comments available for this post'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  ResultVoid deleteComment(String commentId, String postId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteComment(commentId, postId);

        // Delete from local cache
        try {
          await localDataSource.deleteComment(commentId);
        } catch (e) {
          log('Error deleting comment from cache: $e');
          // Continue even if cache deletion fails
        }

        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
