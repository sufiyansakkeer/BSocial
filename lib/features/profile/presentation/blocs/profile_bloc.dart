import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../features/auth/domain/entities/user.dart';
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
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  /// Get user profile use case
  final GetUserProfileUseCase getUserProfileUseCase;
  
  /// Update user profile use case
  final UpdateUserProfileUseCase updateUserProfileUseCase;

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
}
