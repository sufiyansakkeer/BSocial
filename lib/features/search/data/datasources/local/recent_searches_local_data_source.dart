import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../models/recent_search_model.dart';

/// Interface for recent searches local data source
abstract class RecentSearchesLocalDataSource {
  /// Get recent searches
  Future<List<RecentSearchModel>> getRecentSearches();

  /// Save a recent search
  Future<void> saveRecentSearch(RecentSearchModel search);

  /// Clear all recent searches
  Future<void> clearRecentSearches();
}

/// Implementation of [RecentSearchesLocalDataSource]
class RecentSearchesLocalDataSourceImpl
    implements RecentSearchesLocalDataSource {
  /// Constructor
  RecentSearchesLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  /// Factory method to create an instance with initialized SharedPreferences
  static Future<RecentSearchesLocalDataSourceImpl> create() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return RecentSearchesLocalDataSourceImpl(
      sharedPreferences: sharedPreferences,
    );
  }

  /// Shared preferences instance
  final SharedPreferences sharedPreferences;

  /// Key for storing recent searches
  static const recentSearchesKey = 'RECENT_SEARCHES';

  /// Maximum number of recent searches to store
  static const maxRecentSearches = 10;

  @override
  Future<List<RecentSearchModel>> getRecentSearches() async {
    try {
      final jsonString = sharedPreferences.getString(recentSearchesKey);
      if (jsonString == null) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((item) =>
              RecentSearchModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on Exception {
      throw CacheException(message: 'Failed to get recent searches');
    }
  }

  @override
  Future<void> saveRecentSearch(RecentSearchModel search) async {
    try {
      final searches = await getRecentSearches();

      // Remove existing search with the same query if it exists
      searches
        ..removeWhere((item) => item.query == search.query)

        // Add new search at the beginning
        ..insert(0, search);

      // Limit the number of recent searches
      final limitedSearches = searches.take(maxRecentSearches).toList();

      // Save to shared preferences
      final jsonString =
          json.encode(limitedSearches.map((s) => s.toJson()).toList());
      await sharedPreferences.setString(recentSearchesKey, jsonString);
    } on Exception catch (_) {
      throw CacheException(message: 'Failed to save recent search');
    }
  }

  @override
  Future<void> clearRecentSearches() async {
    try {
      await sharedPreferences.remove(recentSearchesKey);
    } on Exception {
      throw CacheException(message: 'Failed to clear recent searches');
    }
  }
}
