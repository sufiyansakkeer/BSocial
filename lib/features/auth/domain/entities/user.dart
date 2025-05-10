import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  /// Constructor
  const User({
    required this.uid,
    required this.email,
    required this.userName,
    required this.photoUrl,
    required this.followers,
    required this.following,
    required this.status,
    this.bio = '',
    this.isMfaEnabled = false,
    this.isEmailVerified = false,
  });

  /// User ID
  final String uid;

  /// Email
  final String email;

  /// Username
  final String userName;

  /// Profile picture URL
  final String photoUrl;

  /// List of followers
  final List<String> followers;

  /// List of following
  final List<String> following;

  /// User status
  final String status;

  /// User bio
  final String bio;

  /// Whether MFA is enabled
  final bool isMfaEnabled;

  /// Whether email is verified
  final bool isEmailVerified;

  @override
  List<Object?> get props => [
        uid,
        email,
        userName,
        photoUrl,
        followers,
        following,
        status,
        bio,
        isMfaEnabled,
        isEmailVerified,
      ];

  /// Create a copy of this user with the given fields replaced
  User copyWith({
    String? uid,
    String? email,
    String? userName,
    String? photoUrl,
    List<String>? followers,
    List<String>? following,
    String? status,
    String? bio,
    bool? isMfaEnabled,
    bool? isEmailVerified,
  }) =>
      User(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        userName: userName ?? this.userName,
        photoUrl: photoUrl ?? this.photoUrl,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        status: status ?? this.status,
        bio: bio ?? this.bio,
        isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      );
}
