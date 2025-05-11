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

/// Event to update the profile state directly
class UpdateProfileStateEvent extends ProfileEvent {
  /// Constructor
  const UpdateProfileStateEvent({required this.user});

  /// Updated user
  final User user;

  @override
  List<Object?> get props => [user];
}

/// Event to follow a user
class FollowUserEvent extends ProfileEvent {
  /// Constructor
  const FollowUserEvent({
    required this.profileUser,
    required this.currentUserId,
  });

  /// Profile user to follow
  final User profileUser;

  /// Current user ID
  final String currentUserId;

  @override
  List<Object?> get props => [profileUser, currentUserId];
}

/// Event to unfollow a user
class UnfollowUserEvent extends ProfileEvent {
  /// Constructor
  const UnfollowUserEvent({
    required this.profileUser,
    required this.currentUserId,
  });

  /// Profile user to unfollow
  final User profileUser;

  /// Current user ID
  final String currentUserId;

  @override
  List<Object?> get props => [profileUser, currentUserId];
}
