part of 'user_bloc.dart';

/// Base class for user states
abstract class UserState extends Equatable {
  /// Constructor
  const UserState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class UserInitial extends UserState {}

/// Loading state for user operations
class UserLoading extends UserState {}

/// Loading state for users list operations
class UsersLoading extends UserState {}

/// Loading state for user actions
class UserActionLoading extends UserState {}

/// State when a user is loaded
class UserLoaded extends UserState {
  /// Constructor
  const UserLoaded({required this.user});

  /// Loaded user
  final User user;

  @override
  List<Object?> get props => [user];
}

/// State when users are loaded
class UsersLoaded extends UserState {
  /// Constructor
  const UsersLoaded({required this.users});

  /// Loaded users
  final List<User> users;

  @override
  List<Object?> get props => [users];
}

/// State when a user action is successful
class UserActionSuccess extends UserState {
  /// Constructor
  const UserActionSuccess({required this.message});

  /// Success message
  final String message;

  @override
  List<Object?> get props => [message];
}

/// State when a user is updated
class UserUpdated extends UserState {
  /// Constructor
  const UserUpdated({required this.user});

  /// Updated user
  final User user;

  @override
  List<Object?> get props => [user];
}

/// Error state
class UserError extends UserState {
  /// Constructor
  const UserError({required this.message});

  /// Error message
  final String message;

  @override
  List<Object?> get props => [message];
}
