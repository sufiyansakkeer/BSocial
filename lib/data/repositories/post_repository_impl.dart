import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/typedefs.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/remote/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
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
  ResultVoid deleteComment(String commentId, String postId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteComment(commentId, postId);
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
  ResultVoid deletePost(String postId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deletePost(postId);
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
        final posts = await remoteDataSource.getAllPosts();
        return Right(posts);
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
        final comments = await remoteDataSource.getComments(postId);
        return Right(comments);
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
  ResultFuture<List<Post>> getPostsByUserId(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final posts = await remoteDataSource.getPostsByUserId(userId);
        return Right(posts);
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
  ResultVoid likePost(String postId, String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.likePost(postId, userId);
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
  ResultVoid unlikePost(String postId, String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unlikePost(postId, userId);
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
