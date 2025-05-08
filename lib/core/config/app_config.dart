import 'package:flutter/foundation.dart';

/// Configuration class for the application
/// Contains environment-specific settings and feature flags
class AppConfig {
  /// Factory constructor to return the singleton instance
  factory AppConfig() => _instance;

  /// Private constructor
  AppConfig._internal();

  /// Singleton instance
  static final AppConfig _instance = AppConfig._internal();

  /// Current environment
  late Environment _environment;

  /// API URL
  late String _apiUrl;

  /// Cache duration in hours
  late int _cacheDurationHours;

  /// Whether to enable analytics
  late bool _analyticsEnabled;

  /// Whether to enable crash reporting
  late bool _crashReportingEnabled;

  /// Whether to enable performance monitoring
  late bool _performanceMonitoringEnabled;

  /// Whether to enable offline mode
  late bool _offlineModeEnabled;

  /// Initialize the configuration with the given environment
  void initialize({
    required Environment environment,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? performanceMonitoringEnabled,
    bool? offlineModeEnabled,
    int? cacheDurationHours,
  }) {
    _environment = environment;

    // Set environment-specific values
    switch (environment) {
      case Environment.development:
        _apiUrl = 'https://dev-api.bsocial.com';
        _cacheDurationHours = cacheDurationHours ?? 1;
        _analyticsEnabled = analyticsEnabled ?? false;
        _crashReportingEnabled = crashReportingEnabled ?? false;
        _performanceMonitoringEnabled = performanceMonitoringEnabled ?? false;
        _offlineModeEnabled = offlineModeEnabled ?? true;
        break;
      case Environment.staging:
        _apiUrl = 'https://staging-api.bsocial.com';
        _cacheDurationHours = cacheDurationHours ?? 6;
        _analyticsEnabled = analyticsEnabled ?? true;
        _crashReportingEnabled = crashReportingEnabled ?? true;
        _performanceMonitoringEnabled = performanceMonitoringEnabled ?? true;
        _offlineModeEnabled = offlineModeEnabled ?? true;
        break;
      case Environment.production:
        _apiUrl = 'https://api.bsocial.com';
        _cacheDurationHours = cacheDurationHours ?? 24;
        _analyticsEnabled = analyticsEnabled ?? true;
        _crashReportingEnabled = crashReportingEnabled ?? true;
        _performanceMonitoringEnabled = performanceMonitoringEnabled ?? true;
        _offlineModeEnabled = offlineModeEnabled ?? true;
        break;
    }

    // Log configuration in debug mode
    if (kDebugMode) {
      print('AppConfig initialized:');
      print('Environment: $_environment');
      print('API URL: $_apiUrl');
      print('Cache Duration: $_cacheDurationHours hours');
      print('Analytics Enabled: $_analyticsEnabled');
      print('Crash Reporting Enabled: $_crashReportingEnabled');
      print('Performance Monitoring Enabled: $_performanceMonitoringEnabled');
      print('Offline Mode Enabled: $_offlineModeEnabled');
    }
  }

  /// Get the current environment
  Environment get environment => _environment;

  /// Get the API URL
  String get apiUrl => _apiUrl;

  /// Get the cache duration in hours
  int get cacheDurationHours => _cacheDurationHours;

  /// Get whether analytics is enabled
  bool get analyticsEnabled => _analyticsEnabled;

  /// Get whether crash reporting is enabled
  bool get crashReportingEnabled => _crashReportingEnabled;

  /// Get whether performance monitoring is enabled
  bool get performanceMonitoringEnabled => _performanceMonitoringEnabled;

  /// Get whether offline mode is enabled
  bool get offlineModeEnabled => _offlineModeEnabled;

  /// Get whether the app is running in debug mode
  bool get isDebugMode => kDebugMode;

  /// Get whether the app is running in release mode
  bool get isReleaseMode => kReleaseMode;

  /// Get whether the app is running in profile mode
  bool get isProfileMode => kProfileMode;

  /// Get whether the app is running in development environment
  bool get isDevelopment => _environment == Environment.development;

  /// Get whether the app is running in staging environment
  bool get isStaging => _environment == Environment.staging;

  /// Get whether the app is running in production environment
  bool get isProduction => _environment == Environment.production;
}

/// Environment enum
enum Environment {
  /// Development environment
  development,

  /// Staging environment
  staging,

  /// Production environment
  production,
}
