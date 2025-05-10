part of 'profile_bloc.dart';

/// Base class for all profile events
abstract class ProfileEvent extends Equatable {
  /// Constructor
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a profile
class LoadProfileEvent extends ProfileEvent {
  /// Constructor
  const LoadProfileEvent({required this.userId});

  /// User ID
  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to update a profile
class UpdateProfileEvent extends ProfileEvent {
  /// Constructor
  const UpdateProfileEvent({
    required this.userId,
    this.userName,
    this.bio,
    this.profilePic,
  });

  /// User ID
  final String userId;

  /// Username
  final String? userName;

  /// Bio
  final String? bio;

  /// Profile picture
  final Uint8List? profilePic;

  @override
  List<Object?> get props => [userId, userName, bio, profilePic];
}
