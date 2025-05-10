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
  const SearchUsersEvent({required this.query});

  /// Search query
  final String query;

  @override
  List<Object> get props => [query];
}

/// Event to clear search results
class ClearSearchEvent extends SearchEvent {}
