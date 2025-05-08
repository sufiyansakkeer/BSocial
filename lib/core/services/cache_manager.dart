import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../../data/datasources/local/hive_local_data_source.dart';
import '../../di/injection_container.dart' as di;

class CacheManager {
  factory CacheManager() => _instance;
  CacheManager._internal();
  static final CacheManager _instance = CacheManager._internal();

  late HiveLocalDataSource _localDataSource;
  bool _isInitialized = false;

  /// Initialize the cache manager
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _localDataSource = di.sl<HiveLocalDataSource>();
      _isInitialized = true;
      log('CacheManager initialized successfully');
    } catch (e) {
      log('Error initializing CacheManager: $e');
      rethrow;
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache({
    Duration maxAge = const Duration(days: 7),
  }) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      await _localDataSource.clearExpiredCache(maxAge);
      log('Expired cache cleared successfully');
    } catch (e) {
      log('Error clearing expired cache: $e');
      // Don't rethrow, just log the error
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    if (!_isInitialized) {
      await init();
    }

    try {
      await _localDataSource.clearCache();
      log('All cache cleared successfully');
    } catch (e) {
      log('Error clearing all cache: $e');
      // Don't rethrow, just log the error
    }
  }

  /// Schedule periodic cache cleanup
  void scheduleCacheCleanup({
    Duration cleanupInterval = const Duration(days: 1),
    Duration maxAge = const Duration(days: 7),
  }) {
    // Only schedule in release mode to avoid issues during development
    if (kReleaseMode) {
      Future.delayed(cleanupInterval, () async {
        await clearExpiredCache(maxAge: maxAge);
        scheduleCacheCleanup(
          cleanupInterval: cleanupInterval,
          maxAge: maxAge,
        );
      });
      log('Cache cleanup scheduled every ${cleanupInterval.inHours} hours');
    }
  }
}
