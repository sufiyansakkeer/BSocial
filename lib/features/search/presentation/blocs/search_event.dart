part of 'search_bloc.dart';

/// Base class for all search events
abstract class SearchEvent extends Equatable {
  /// Constructor
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to search for users
class SearchUsersEvent extends SearchEvent {
  /// Constructor
  const SearchUsersEvent({
    required this.query,
    this.saveToRecent = true,
  });

  /// Search query
  final String query;

  /// Whether to save this search to recent searches
  final bool saveToRecent;

  @override
  List<Object> get props => [query, saveToRecent];
}

/// Event to clear search results
class ClearSearchEvent extends SearchEvent {}

/// Event to load recent searches
class LoadRecentSearchesEvent extends SearchEvent {}

/// Event to clear recent searches
class ClearRecentSearchesEvent extends SearchEvent {}

/// Event to use a recent search
class UseRecentSearchEvent extends SearchEvent {
  /// Constructor
  const UseRecentSearchEvent({required this.query});

  /// Search query
  final String query;

  @override
  List<Object> get props => [query];
}
