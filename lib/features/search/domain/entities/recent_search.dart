import 'package:equatable/equatable.dart';

/// Entity representing a recent search
class RecentSearch extends Equatable {
  /// Constructor
  const RecentSearch({
    required this.query,
    required this.timestamp,
  });

  /// Search query
  final String query;

  /// Timestamp when the search was performed
  final DateTime timestamp;

  @override
  List<Object?> get props => [query, timestamp];
}
