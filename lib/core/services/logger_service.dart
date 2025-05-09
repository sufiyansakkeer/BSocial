import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// A service for logging messages
class LoggerService {
  /// Factory constructor to return the singleton instance
  factory LoggerService() => _instance;

  /// Private constructor
  LoggerService._internal() {
    _initLogger();
  }

  /// Singleton instance
  static final LoggerService _instance = LoggerService._internal();

  late Logger _logger;

  /// Initialize the logger
  void _initLogger() {
    final appConfig = AppConfig();

    // Configure logger based on environment
    if (appConfig.isDebugMode) {
      _logger = Logger(
        printer: PrettyPrinter(
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        level: Level.trace,
      );
    } else {
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 80,
          colors: false,
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        level: appConfig.isProduction ? Level.warning : Level.info,
      );
    }
  }

  /// Log a verbose message
  void v(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log a debug message
  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an info message
  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal error message
  void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
