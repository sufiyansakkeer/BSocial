part of 'search_bloc.dart';

/// Base class for all search states
abstract class SearchState extends Equatable {
  /// Constructor
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial search state
class SearchInitial extends SearchState {}

/// Loading search state
class SearchLoading extends SearchState {}

/// Search results state
class SearchResults extends SearchState {
  /// Constructor
  const SearchResults({
    required this.users,
    required this.query,
  });

  /// List of users
  final List<User> users;

  /// Search query
  final String query;

  @override
  List<Object> get props => [users, query];
}

/// Search error state
class SearchError extends SearchState {
  /// Constructor
  const SearchError({required this.message});

  /// Error message
  final String message;

  @override
  List<Object> get props => [message];
}
