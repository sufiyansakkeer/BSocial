part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  const SearchSuccess({required this.users});
  final List<User> users;

  @override
  List<Object> get props => [users];
}

class SearchFailure extends SearchState {
  const SearchFailure({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
