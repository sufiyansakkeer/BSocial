import '../../domain/entities/recent_search.dart';

/// Model for recent search
class RecentSearchModel extends RecentSearch {
  /// Constructor
  const RecentSearchModel({
    required super.query,
    required super.timestamp,
  });

  /// Create from JSON
  factory RecentSearchModel.fromJson(Map<String, dynamic> json) =>
      RecentSearchModel(
        query: json['query'] as String,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      );

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'query': query,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  /// Create a copy with updated fields
  RecentSearchModel copyWith({
    String? query,
    DateTime? timestamp,
  }) =>
      RecentSearchModel(
        query: query ?? this.query,
        timestamp: timestamp ?? this.timestamp,
      );
}
