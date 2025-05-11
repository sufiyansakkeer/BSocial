import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/user/domain/usecases/follow_user.dart';
import '../../../../features/user/domain/usecases/unfollow_user.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC for profile
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// Constructor
  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.followUserUseCase,
    required this.unfollowUserUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateProfileStateEvent>(_onUpdateProfileState);
    on<FollowUserEvent>(_onFollowUser);
    on<UnfollowUserEvent>(_onUnfollowUser);
  }

  /// Get user profile use case
  final GetUserProfileUseCase getUserProfileUseCase;

  /// Update user profile use case
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  /// Follow user use case
  final FollowUserUseCase followUserUseCase;

  /// Unfollow user use case
  final UnfollowUserUseCase unfollowUserUseCase;

  /// Handle load profile event
  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getUserProfileUseCase(event.userId);

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  /// Handle update profile event
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());

    final result = await updateUserProfileUseCase(
      userId: event.userId,
      userName: event.userName,
      bio: event.bio,
      profilePic: event.profilePic,
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileUpdated(user: user)),
    );
  }

  /// Handle update profile state event
  void _onUpdateProfileState(
    UpdateProfileStateEvent event,
    Emitter<ProfileState> emit,
  ) {
    try {
      emit(ProfileLoaded(user: event.user));
    } on Exception catch (e) {
      emit(ProfileError(message: 'Failed to update profile state: $e'));
    }
  }

  /// Handle follow user event
  Future<void> _onFollowUser(
    FollowUserEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // First update the UI optimistically
    final updatedFollowers = List<String>.from(event.profileUser.followers)
      ..add(event.currentUserId);

    // Create updated user
    final updatedUser = event.profileUser.copyWith(
      followers: updatedFollowers,
    );

    // Emit updated state immediately for responsive UI
    emit(ProfileLoaded(user: updatedUser));

    // Then perform the actual follow operation
    final result = await followUserUseCase(event.profileUser.uid);

    // If the operation failed, revert the UI update
    result.fold(
      (failure) {
        // Revert to original state
        emit(ProfileLoaded(user: event.profileUser));
        // Emit error
        emit(ProfileError(message: failure.message));
      },
      (_) {
        // Operation succeeded, no need to do anything as UI is already updated
      },
    );

    // We don't need to refresh the profile here as we've already updated the UI
    // The optimistic update is sufficient for a responsive UI
    // If we need the latest data, it will be fetched when the user refreshes the page
  }

  /// Handle unfollow user event
  Future<void> _onUnfollowUser(
    UnfollowUserEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // First update the UI optimistically
    final updatedFollowers = List<String>.from(event.profileUser.followers)
      ..remove(event.currentUserId);

    // Create updated user
    final updatedUser = event.profileUser.copyWith(
      followers: updatedFollowers,
    );

    // Emit updated state immediately for responsive UI
    emit(ProfileLoaded(user: updatedUser));

    // Then perform the actual unfollow operation
    final result = await unfollowUserUseCase(event.profileUser.uid);

    // If the operation failed, revert the UI update
    result.fold(
      (failure) {
        // Revert to original state
        emit(ProfileLoaded(user: event.profileUser));
        // Emit error
        emit(ProfileError(message: failure.message));
      },
      (_) {
        // Operation succeeded, no need to do anything as UI is already updated
      },
    );

    // We don't need to refresh the profile here as we've already updated the UI
    // The optimistic update is sufficient for a responsive UI
    // If we need the latest data, it will be fetched when the user refreshes the page
  }
}
