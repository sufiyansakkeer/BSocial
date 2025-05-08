import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';
import '../utils/typedefs.dart';

/// Base repository class with common error handling logic
abstract class BaseRepository {
  BaseRepository({required this.networkInfo});
  final NetworkInfo networkInfo;

  /// Execute a remote data source call with proper error handling
  /// Returns Either<Failure, T> where T is the success type
  Future<Either<Failure, T>> handleRemoteCall<T>({
    required Future<T> Function() call,
    String? errorMessage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await call();
        return Right(result);
      } on AuthException catch (e) {
        log('AuthException: ${e.message}');
        return Left(AuthFailure(message: e.message));
      } on ServerException catch (e) {
        log('ServerException: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } on CacheException catch (e) {
        log('CacheException: ${e.message}');
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        log('Unexpected error: $e');
        return Left(ServerFailure(
          message: errorMessage ?? 'An unexpected error occurred: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  /// Execute a local data source call with proper error handling
  /// Returns Either<Failure, T> where T is the success type
  Future<Either<Failure, T>> handleLocalCall<T>({
    required Future<T> Function() call,
    String? errorMessage,
  }) async {
    try {
      final result = await call();
      return Right(result);
    } on CacheException catch (e) {
      log('CacheException: ${e.message}');
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      log('Unexpected error in local call: $e');
      return Left(CacheFailure(
        message: errorMessage ?? 'An unexpected error occurred: $e',
      ));
    }
  }

  /// Execute a remote call with fallback to local cache if remote fails
  /// Returns Either<Failure, T> where T is the success type
  Future<Either<Failure, T>> handleRemoteCallWithLocalFallback<T>({
    required Future<T> Function() remoteCall,
    required Future<T> Function() localCall,
    String? remoteErrorMessage,
    String? localErrorMessage,
    bool cacheResult = true,
    Future<void> Function(T)? cacheCall,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteResult = await remoteCall();

        // Cache the result if needed
        if (cacheResult && cacheCall != null) {
          try {
            await cacheCall(remoteResult);
          } catch (e) {
            log('Error caching result: $e');
            // Continue even if caching fails
          }
        }

        return Right(remoteResult);
      } catch (e) {
        log('Remote call failed, trying local fallback: $e');

        // Try local fallback
        return handleLocalCall(
          call: localCall,
          errorMessage: localErrorMessage,
        );
      }
    } else {
      log('No internet connection, using local data');
      return handleLocalCall(
        call: localCall,
        errorMessage: localErrorMessage,
      );
    }
  }
}
