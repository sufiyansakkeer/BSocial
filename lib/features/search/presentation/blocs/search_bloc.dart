import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../features/auth/domain/entities/user.dart';
import '../../domain/usecases/search_users.dart';

part 'search_event.dart';
part 'search_state.dart';

/// BLoC for search
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// Constructor
  SearchBloc({required this.searchUsersUseCase}) : super(SearchInitial()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<ClearSearchEvent>(_onClearSearch);
  }

  /// Search users use case
  final SearchUsersUseCase searchUsersUseCase;

  /// Handle search users event
  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    final result = await searchUsersUseCase(event.query);

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (users) => emit(SearchResults(users: users, query: event.query)),
    );
  }

  /// Handle clear search event
  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}
