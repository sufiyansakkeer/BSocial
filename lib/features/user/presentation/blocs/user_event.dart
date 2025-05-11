part of 'user_bloc.dart';

/// Base class for user events
abstract class UserEvent extends Equatable {
  /// Constructor
  const UserEvent();

  @override
  List<Object?> get props => [];
}

/// Event to get user by ID
class GetUserByIdEvent extends UserEvent {
  /// Constructor
  const GetUserByIdEvent({required this.userId});

  /// User ID
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to search users
class SearchUsersEvent extends UserEvent {
  /// Constructor
  const SearchUsersEvent({required this.query});

  /// Search query
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to follow a user
class FollowUserEvent extends UserEvent {
  /// Constructor
  const FollowUserEvent({required this.userId});

  /// User ID to follow
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to unfollow a user
class UnfollowUserEvent extends UserEvent {
  /// Constructor
  const UnfollowUserEvent({required this.userId});

  /// User ID to unfollow
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to get followers of a user
class GetFollowersEvent extends UserEvent {
  /// Constructor
  const GetFollowersEvent({required this.userId});

  /// User ID to get followers for
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to get users followed by a user
class GetFollowingEvent extends UserEvent {
  /// Constructor
  const GetFollowingEvent({required this.userId});

  /// User ID to get following for
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to update user profile
class UpdateUserProfileEvent extends UserEvent {
  /// Constructor
  const UpdateUserProfileEvent({
    required this.userId,
    this.userName,
    this.photoUrl,
    this.status,
    this.bio,
  });

  /// User ID
  final String userId;

  /// New username
  final String? userName;

  /// New photo URL
  final String? photoUrl;

  /// New status
  final String? status;

  /// New bio
  final String? bio;

  @override
  List<Object?> get props => [userId, userName, photoUrl, status, bio];
}
