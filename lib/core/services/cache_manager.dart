import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../../data/datasources/local/hive_local_data_source.dart';

class CacheManager {
  factory CacheManager() => _instance;
  CacheManager._internal();
  static final CacheManager _instance = CacheManager._internal();

  late HiveLocalDataSource _localDataSource;
  bool _isInitialized = false;

  /// Initialize the cache manager
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Create a new instance directly instead of using GetIt
      _localDataSource = HiveLocalDataSourceImpl();
      _isInitialized = true;
      log('CacheManager initialized successfully', name: 'init');
    } catch (e) {
      log('Error initializing CacheManager: $e', name: 'init');
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
      log('Expired cache cleared successfully', name: 'clearExpiredCache');
    } on Exception catch (e) {
      log('Error clearing expired cache: $e', name: 'clearExpiredCache');
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
      log('All cache cleared successfully', name: 'clearAllCache');
    } on Exception catch (e) {
      log('Error clearing all cache: $e', name: 'clearAllCache');
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
      log('Cache cleanup scheduled every ${cleanupInterval.inHours} hours',
          name: 'scheduleCacheCleanup');
    }
  }
}
