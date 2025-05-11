import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

/// A utility class for retrying operations with exponential backoff
class RetryUtil {
  /// Executes a function with retry logic and exponential backoff
  /// 
  /// Parameters:
  /// - [operation]: The async function to execute
  /// - [maxRetries]: Maximum number of retry attempts (default: 3)
  /// - [initialDelayMs]: Initial delay in milliseconds before first retry (default: 500ms)
  /// - [maxDelayMs]: Maximum delay in milliseconds between retries (default: 5000ms)
  /// - [retryIf]: Optional function to determine if a specific error should trigger a retry
  /// - [onRetry]: Optional callback that is called before each retry attempt
  /// 
  /// Returns the result of the operation if successful
  /// Throws the last error encountered if all retries fail
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    int initialDelayMs = 500,
    int maxDelayMs = 5000,
    bool Function(Exception)? retryIf,
    void Function(Exception, int, int)? onRetry,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts <= maxRetries) {
      try {
        return await operation();
      } on Exception catch (e) {
        lastException = e;
        
        // Check if we should retry this specific exception
        final shouldRetry = retryIf?.call(e) ?? _defaultRetryCheck(e);
        
        // If we shouldn't retry this exception, rethrow it immediately
        if (!shouldRetry) {
          rethrow;
        }
        
        // If we've reached max retries, throw the last exception
        if (attempts == maxRetries) {
          rethrow;
        }
        
        // Calculate backoff delay with jitter
        final delayMs = _calculateBackoffDelay(
          attempts: attempts,
          initialDelayMs: initialDelayMs,
          maxDelayMs: maxDelayMs,
        );
        
        // Log retry attempt
        log(
          'Operation failed, retrying in ${delayMs}ms (attempt ${attempts + 1}/$maxRetries): $e',
          name: 'RetryUtil',
        );
        
        // Notify about retry if callback provided
        onRetry?.call(e, attempts + 1, delayMs);
        
        // Wait before retrying
        await Future.delayed(Duration(milliseconds: delayMs));
        
        attempts++;
      }
    }
    
    // This should never be reached due to the rethrow above,
    // but Dart requires a return statement
    throw lastException!;
  }
  
  /// Default logic to determine if an exception should trigger a retry
  static bool _defaultRetryCheck(Exception exception) {
    final message = exception.toString().toLowerCase();
    
    // Retry for common transient errors
    return message.contains('unavailable') ||
           message.contains('timeout') ||
           message.contains('temporarily') ||
           message.contains('transient') ||
           message.contains('overloaded') ||
           message.contains('busy') ||
           message.contains('backoff') ||
           message.contains('network') ||
           message.contains('connection');
  }
  
  /// Calculate backoff delay with jitter to prevent thundering herd problem
  static int _calculateBackoffDelay({
    required int attempts,
    required int initialDelayMs,
    required int maxDelayMs,
  }) {
    // Calculate exponential backoff: initialDelay * 2^attempt
    final exponentialDelay = initialDelayMs * math.pow(2, attempts).toInt();
    
    // Apply a random jitter factor between 0.5 and 1.5
    final jitterFactor = 0.5 + math.Random().nextDouble();
    
    // Calculate final delay with jitter, capped at maxDelay
    return math.min(
      (exponentialDelay * jitterFactor).toInt(),
      maxDelayMs,
    );
  }
}
