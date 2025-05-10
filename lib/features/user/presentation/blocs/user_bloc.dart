import 'package:bsocial/domain/entities/user.dart'; // Use package import for canonical User
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/follow_user.dart';
import '../../domain/usecases/get_user_by_id.dart';
import '../../domain/usecases/search_users.dart';
import '../../domain/usecases/unfollow_user.dart';
import '../../domain/usecases/update_user_profile.dart';

part 'user_event.dart';
part 'user_state.dart';

/// BLoC for user-related operations
class UserBloc extends Bloc<UserEvent, UserState> {
  /// Constructor
  UserBloc({
    required this.getUserByIdUseCase,
    required this.searchUsersUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
    required this.updateUserProfileUseCase,
  }) : super(UserInitial()) {
    on<GetUserByIdEvent>(_onGetUserById);
    on<SearchUsersEvent>(_onSearchUsers);
    on<FollowUserEvent>(_onFollowUser);
    on<UnfollowUserEvent>(_onUnfollowUser);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
  }

  /// Use case to get user by ID
  final GetUserByIdUseCase getUserByIdUseCase;

  /// Use case to search users
  final SearchUsersUseCase searchUsersUseCase;

  /// Use case to follow a user
  final FollowUserUseCase followUserUseCase;

  /// Use case to unfollow a user
  final UnfollowUserUseCase unfollowUserUseCase;

  /// Use case to update user profile
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  Future<void> _onGetUserById(
    GetUserByIdEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await getUserByIdUseCase(event.userId);
    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (user) => emit(UserLoaded(user: user)),
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UsersLoading());
    final result = await searchUsersUseCase(event.query);
    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (users) => emit(UsersLoaded(users: users)),
    );
  }

  Future<void> _onFollowUser(
    FollowUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserActionLoading());
    final result = await followUserUseCase(event.userId);
    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (_) =>
          emit(const UserActionSuccess(message: 'User followed successfully')),
    );
  }

  Future<void> _onUnfollowUser(
    UnfollowUserEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserActionLoading());
    final result = await unfollowUserUseCase(event.userId);
    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (_) => emit(
          const UserActionSuccess(message: 'User unfollowed successfully')),
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserActionLoading());
    final result = await updateUserProfileUseCase(
      userId: event.userId,
      userName: event.userName,
      photoUrl: event.photoUrl,
      status: event.status,
      bio: event.bio,
    );
    result.fold(
      (failure) => emit(UserError(message: failure.message)),
      (user) => emit(UserUpdated(user: user)),
    );
  }
}
