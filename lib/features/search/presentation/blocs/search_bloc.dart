import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../features/auth/domain/entities/user.dart';
import '../../data/datasources/local/recent_searches_local_data_source.dart';
import '../../data/models/recent_search_model.dart';
import '../../domain/usecases/search_users.dart';

part 'search_event.dart';
part 'search_state.dart';

/// BLoC for search
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// Constructor
  SearchBloc({
    required this.searchUsersUseCase,
    required this.recentSearchesDataSource,
  }) : super(const SearchInitial()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<ClearSearchEvent>(_onClearSearch);
    on<LoadRecentSearchesEvent>(_onLoadRecentSearches);
    on<ClearRecentSearchesEvent>(_onClearRecentSearches);
    on<UseRecentSearchEvent>(_onUseRecentSearch);
  }

  /// Search users use case
  final SearchUsersUseCase searchUsersUseCase;

  /// Recent searches data source
  final RecentSearchesLocalDataSource recentSearchesDataSource;

  /// Handle search users event
  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      await _loadRecentSearches(emit);
      return;
    }

    emit(SearchLoading());

    final result = await searchUsersUseCase(event.query);

    await result.fold(
      (failure) async {
        emit(SearchError(message: failure.message));
      },
      (users) async {
        // Save the search query to recent searches
        if (event.saveToRecent && event.query.trim().isNotEmpty) {
          await _saveRecentSearch(event.query);
        }

        emit(SearchResults(users: users, query: event.query));
      },
    );
  }

  /// Handle clear search event
  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    await _loadRecentSearches(emit);
  }

  /// Handle load recent searches event
  Future<void> _onLoadRecentSearches(
    LoadRecentSearchesEvent event,
    Emitter<SearchState> emit,
  ) async {
    await _loadRecentSearches(emit);
  }

  /// Handle clear recent searches event
  Future<void> _onClearRecentSearches(
    ClearRecentSearchesEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await recentSearchesDataSource.clearRecentSearches();
      emit(const SearchInitial());
    } on Exception catch (e) {
      emit(SearchError(
          message: 'Failed to clear recent searches: ${e.toString()}'));
    }
  }

  /// Handle use recent search event
  Future<void> _onUseRecentSearch(
    UseRecentSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    add(SearchUsersEvent(query: event.query));
  }

  /// Helper method to load recent searches
  Future<void> _loadRecentSearches(Emitter<SearchState> emit) async {
    try {
      final recentSearches = await recentSearchesDataSource.getRecentSearches();
      emit(SearchInitial(recentSearches: recentSearches));
    } on Exception {
      emit(const SearchInitial());
    }
  }

  /// Helper method to save a recent search
  Future<void> _saveRecentSearch(String query) async {
    try {
      final search = RecentSearchModel(
        query: query,
        timestamp: DateTime.now(),
      );
      await recentSearchesDataSource.saveRecentSearch(search);
    } on Exception {
      // Silently fail - this is not critical functionality
    }
  }
}
