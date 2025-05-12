import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/hive_local_data_source.dart';

class CacheManager {
  factory CacheManager() => _instance;
  CacheManager._internal();
  static final CacheManager _instance = CacheManager._internal();

  late HiveLocalDataSource _localDataSource;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialize the cache manager
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Create a new instance directly instead of using GetIt
      _localDataSource = HiveLocalDataSourceImpl();
      _prefs = await SharedPreferences.getInstance();
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

  /// Check if valid cache exists for a specific key
  /// Returns true if cache exists and is not expired
  Future<bool> hasValidCache(String cacheKey, {Duration? maxAge}) async {
    if (!_isInitialized) {
      await init();
    }

    final lastFetchTime = _prefs?.getInt('${cacheKey}_timestamp');
    if (lastFetchTime == null) {
      return false;
    }

    final lastFetchDateTime =
        DateTime.fromMillisecondsSinceEpoch(lastFetchTime);
    final now = DateTime.now();
    final age = now.difference(lastFetchDateTime);

    // If maxAge is provided, use it, otherwise consider cache valid
    if (maxAge != null) {
      return age <= maxAge;
    }

    return true;
  }

  /// Mark cache as refreshed for a specific key
  Future<void> markCacheRefreshed(String cacheKey) async {
    if (!_isInitialized) {
      await init();
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs?.setInt('${cacheKey}_timestamp', now);
    log('Cache marked as refreshed: $cacheKey', name: 'markCacheRefreshed');
  }

  /// Mark a screen as visited
  Future<void> markScreenVisited(String screenKey) async {
    if (!_isInitialized) {
      await init();
    }

    await _prefs?.setBool('visited_$screenKey', true);
    log('Screen marked as visited: $screenKey', name: 'markScreenVisited');
  }

  /// Check if a screen has been visited before
  Future<bool> hasScreenBeenVisited(String screenKey) async {
    if (!_isInitialized) {
      await init();
    }

    return _prefs?.getBool('visited_$screenKey') ?? false;
  }

  /// Clear all cache timestamps
  Future<void> clearAllCacheTimestamps() async {
    if (!_isInitialized) {
      await init();
    }

    final keys = _prefs?.getKeys() ?? {};
    for (final key in keys) {
      if (key.endsWith('_timestamp')) {
        await _prefs?.remove(key);
      }
    }
    log('All cache timestamps cleared', name: 'clearAllCacheTimestamps');
  }

  /// Clear specific cache timestamp
  Future<void> clearCacheTimestamp(String cacheKey) async {
    if (!_isInitialized) {
      await init();
    }

    await _prefs?.remove('${cacheKey}_timestamp');
    log('Cache timestamp cleared: $cacheKey', name: 'clearCacheTimestamp');
  }
}
