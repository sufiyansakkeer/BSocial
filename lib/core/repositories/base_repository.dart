import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';
import '../network/network_info.dart';
import '../utils/retry_util.dart';

/// Base repository class with common error handling logic
abstract class BaseRepository {
  BaseRepository({required this.networkInfo});
  final NetworkInfo networkInfo;

  /// Execute a remote data source call with proper error handling and retry logic.
  /// Returns `Either<Failure, T>` where T is the success type.
  Future<Either<Failure, T>> handleRemoteCall<T>({
    required Future<T> Function() call,
    String? errorMessage,
    int maxRetries = 3,
    int initialDelayMs = 500,
    int maxDelayMs = 5000,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Use retry utility with exponential backoff for remote calls
        final result = await RetryUtil.retry(
          operation: call,
          maxRetries: maxRetries,
          initialDelayMs: initialDelayMs,
          maxDelayMs: maxDelayMs,
          retryIf: (e) {
            // Only retry for server-related exceptions that might be transient
            final message = e.toString().toLowerCase();
            return message.contains('unavailable') ||
                message.contains('timeout') ||
                message.contains('temporarily') ||
                message.contains('transient') ||
                message.contains('overloaded') ||
                message.contains('busy');
          },
          onRetry: (e, attempt, delayMs) {
            log('Retrying remote call (attempt $attempt): $e',
                name: 'handleRemoteCall');
          },
        );
        return Right(result);
      } on AuthException catch (e) {
        log('AuthException: ${e.message}', name: 'handleRemoteCall');
        return Left(AuthFailure(message: e.message));
      } on ServerException catch (e) {
        log('ServerException: ${e.message}', name: 'handleRemoteCall');
        return Left(ServerFailure(message: e.message));
      } on CacheException catch (e) {
        log('CacheException: ${e.message}', name: 'handleRemoteCall');
        return Left(CacheFailure(message: e.message));
      } on Exception catch (e) {
        log('Unexpected error: $e', name: 'handleRemoteCall');
        return Left(ServerFailure(
          message: errorMessage ?? 'An unexpected error occurred: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  /// Execute a local data source call with proper error handling
  /// Returns `Either<Failure, T>` where T is the success type
  Future<Either<Failure, T>> handleLocalCall<T>({
    required Future<T> Function() call,
    String? errorMessage,
  }) async {
    try {
      final result = await call();
      return Right(result);
    } on CacheException catch (e) {
      log('CacheException: ${e.message}', name: 'handleLocalCall');
      return Left(CacheFailure(message: e.message));
    } on Exception catch (e) {
      log('Unexpected error in local call: $e', name: 'handleLocalCall');
      return Left(CacheFailure(
        message: errorMessage ?? 'An unexpected error occurred: $e',
      ));
    }
  }

  /// Execute a remote call with fallback to local cache if remote fails
  /// Returns `Either<Failure, T>` where T is the success type
  Future<Either<Failure, T>> handleRemoteCallWithLocalFallback<T>({
    required Future<T> Function() remoteCall,
    required Future<T> Function() localCall,
    String? remoteErrorMessage,
    String? localErrorMessage,
    bool cacheResult = true,
    Future<void> Function(T)? cacheCall,
    int maxRetries = 3,
    int initialDelayMs = 500,
    int maxDelayMs = 5000,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Use retry utility with exponential backoff for remote calls
        final remoteResult = await RetryUtil.retry(
          operation: remoteCall,
          maxRetries: maxRetries,
          initialDelayMs: initialDelayMs,
          maxDelayMs: maxDelayMs,
          retryIf: (e) {
            // Only retry for server-related exceptions that might be transient
            final message = e.toString().toLowerCase();
            return message.contains('unavailable') ||
                message.contains('timeout') ||
                message.contains('temporarily') ||
                message.contains('transient') ||
                message.contains('overloaded') ||
                message.contains('busy');
          },
          onRetry: (e, attempt, delayMs) {
            log(
              'Retrying remote call with local fallback (attempt $attempt): $e',
              name: 'handleRemoteCallWithLocalFallback',
            );
          },
        );

        // Cache the result if needed
        if (cacheResult && cacheCall != null) {
          try {
            await cacheCall(remoteResult);
          } on Exception catch (e) {
            log('Error caching result: $e',
                name: 'handleRemoteCallWithLocalFallback');
            // Continue even if caching fails
          }
        }

        return Right(remoteResult);
      } on Exception catch (e) {
        log('Remote call failed after retries, trying local fallback: $e',
            name: 'handleRemoteCallWithLocalFallback');

        // Try local fallback
        return handleLocalCall(
          call: localCall,
          errorMessage: localErrorMessage,
        );
      }
    } else {
      log('No internet connection, using local data',
          name: 'handleRemoteCallWithLocalFallback');
      return handleLocalCall(
        call: localCall,
        errorMessage: localErrorMessage,
      );
    }
  }
}
