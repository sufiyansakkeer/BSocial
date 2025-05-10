part of 'profile_bloc.dart';

/// Base class for all profile states
abstract class ProfileState extends Equatable {
  /// Constructor
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial profile state
class ProfileInitial extends ProfileState {}

/// Loading profile state
class ProfileLoading extends ProfileState {}

/// Profile loaded state
class ProfileLoaded extends ProfileState {
  /// Constructor
  const ProfileLoaded({required this.user});

  /// User
  final User user;

  @override
  List<Object> get props => [user];
}

/// Updating profile state
class ProfileUpdating extends ProfileState {}

/// Profile updated state
class ProfileUpdated extends ProfileState {
  /// Constructor
  const ProfileUpdated({required this.user});

  /// Updated user
  final User user;

  @override
  List<Object> get props => [user];
}

/// Profile error state
class ProfileError extends ProfileState {
  /// Constructor
  const ProfileError({required this.message});

  /// Error message
  final String message;

  @override
  List<Object> get props => [message];
}
