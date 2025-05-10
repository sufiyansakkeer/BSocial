import 'package:equatable/equatable.dart';

/// User role enum
enum UserRole {
  /// Regular user
  user,

  /// Moderator with additional permissions
  moderator,

  /// Administrator with full permissions
  admin
}

/// User authentication entity
///
/// This entity contains the user information needed for authentication and authorization.
/// It's separate from the full User entity to avoid circular dependencies between features.
class UserAuth extends Equatable {
  /// Creates a new [UserAuth] instance
  const UserAuth({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.userName,
    required this.followers,
    required this.following,
    this.status = 'offline',
    this.role = UserRole.user,
    this.permissions = const [],
    this.isEmailVerified = false,
    this.isMfaEnabled = false,
    this.createdAt,
    this.lastLoginAt,
  });

  /// User's email address
  final String email;

  /// User's unique identifier
  final String uid;

  /// URL to user's profile photo
  final String photoUrl;

  /// User's display name
  final String userName;

  /// List of user IDs who follow this user
  final List<String> followers;

  /// List of user IDs this user follows
  final List<String> following;

  /// User's online status
  final String status;

  /// User's role for authorization
  final UserRole role;

  /// User's specific permissions
  final List<String> permissions;

  /// Whether the user's email is verified
  final bool isEmailVerified;

  /// Whether multi-factor authentication is enabled
  final bool isMfaEnabled;

  /// When the user account was created
  final DateTime? createdAt;

  /// When the user last logged in
  final DateTime? lastLoginAt;

  /// Creates a copy of this [UserAuth] with the given fields replaced with new values
  UserAuth copyWith({
    String? email,
    String? uid,
    String? photoUrl,
    String? userName,
    List<String>? followers,
    List<String>? following,
    String? status,
    UserRole? role,
    List<String>? permissions,
    bool? isEmailVerified,
    bool? isMfaEnabled,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) =>
      UserAuth(
        email: email ?? this.email,
        uid: uid ?? this.uid,
        photoUrl: photoUrl ?? this.photoUrl,
        userName: userName ?? this.userName,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        status: status ?? this.status,
        role: role ?? this.role,
        permissions: permissions ?? this.permissions,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
        createdAt: createdAt ?? this.createdAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      );

  /// Converts this [UserAuth] to a JSON map
  Map<String, dynamic> toJson() => {
        'email': email,
        'uid': uid,
        'photoUrl': photoUrl,
        'userName': userName,
        'followers': followers,
        'following': following,
        'status': status,
        'role': role.toString().split('.').last,
        'permissions': permissions,
        'isEmailVerified': isEmailVerified,
        'isMfaEnabled': isMfaEnabled,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      };

  /// Check if user has a specific permission
  bool hasPermission(String permission) =>
      role == UserRole.admin || permissions.contains(permission);

  /// Check if user has admin role
  bool get isAdmin => role == UserRole.admin;

  /// Check if user has moderator role
  bool get isModerator => role == UserRole.moderator || role == UserRole.admin;

  @override
  List<Object?> get props => [
        email,
        uid,
        photoUrl,
        userName,
        followers,
        following,
        status,
        role,
        permissions,
        isEmailVerified,
        isMfaEnabled,
        createdAt,
        lastLoginAt,
      ];
}
