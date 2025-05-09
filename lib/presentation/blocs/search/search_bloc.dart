import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchUsers>(_onSearchUsers);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      // TODO: Implement actual search functionality
      // This is just a placeholder for demonstration
      await Future.delayed(const Duration(seconds: 1));

      final users = List.generate(
        5,
        (index) => User(
          email: 'user_${event.query}$index@example.com',
          uid: 'user$index',
          photoUrl: 'https://via.placeholder.com/150',
          userName: 'user_${event.query}$index',
          followers: const [],
          following: const [],
          status: 'online',
        ),
      );

      emit(SearchSuccess(users: users));
    } on Exception catch (e) {
      emit(SearchFailure(message: e.toString()));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}
