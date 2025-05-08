import 'dart:developer';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'failures.dart';

class ErrorHandler {
  // Singleton instance
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  // Handle any error and return a user-friendly message
  String handleError(dynamic error, {String fallbackMessage = 'An unexpected error occurred'}) {
    // Log the error
    log('Error: $error');
    
    // Report to Crashlytics if not in debug mode
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
    }
    
    // Handle different error types
    if (error is Failure) {
      return error.message;
    } else if (error is Exception) {
      return _handleException(error);
    } else {
      return fallbackMessage;
    }
  }
  
  // Handle different types of exceptions
  String _handleException(Exception exception) {
    final exceptionString = exception.toString();
    
    // Firebase Auth exceptions
    if (exceptionString.contains('firebase_auth')) {
      if (exceptionString.contains('user-not-found')) {
        return 'User not found. Please check your email and try again.';
      } else if (exceptionString.contains('wrong-password')) {
        return 'Incorrect password. Please try again.';
      } else if (exceptionString.contains('email-already-in-use')) {
        return 'Email is already in use. Please use a different email or try logging in.';
      } else if (exceptionString.contains('weak-password')) {
        return 'Password is too weak. Please use a stronger password.';
      } else if (exceptionString.contains('invalid-email')) {
        return 'Invalid email format. Please enter a valid email address.';
      } else if (exceptionString.contains('account-exists-with-different-credential')) {
        return 'An account already exists with a different sign-in method. Please try another method.';
      } else if (exceptionString.contains('operation-not-allowed')) {
        return 'This operation is not allowed. Please contact support.';
      } else if (exceptionString.contains('too-many-requests')) {
        return 'Too many requests. Please try again later.';
      }
    }
    
    // Network exceptions
    if (exceptionString.contains('SocketException') || 
        exceptionString.contains('ConnectionRefused')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    
    // Timeout exceptions
    if (exceptionString.contains('TimeoutException')) {
      return 'Request timed out. Please try again later.';
    }
    
    // Format exceptions
    if (exceptionString.contains('FormatException')) {
      return 'Invalid data format. Please try again.';
    }
    
    // Default message for unhandled exceptions
    return 'An error occurred: ${exception.toString()}';
  }
  
  // Handle specific failure types
  String handleFailure(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is AuthFailure) {
      return 'Authentication error: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'Cache error: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Network error: ${failure.message}';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'Error: ${failure.message}';
    }
  }
}
