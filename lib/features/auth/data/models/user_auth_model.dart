import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_auth.dart';

/// Model class for [UserAuth] entity
///
/// This class extends [UserAuth] and adds serialization/deserialization functionality
class UserAuthModel extends UserAuth {
  /// Creates a new [UserAuthModel] instance
  const UserAuthModel({
    required super.email,
    required super.uid,
    required super.photoUrl,
    required super.userName,
    required super.followers,
    required super.following,
    super.status = 'offline',
    super.role = UserRole.user,
    super.permissions = const [],
    super.isEmailVerified = false,
    super.isMfaEnabled = false,
    super.createdAt,
    super.lastLoginAt,
  });

  /// Creates a [UserAuthModel] from a Firestore document snapshot
  factory UserAuthModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserAuthModel.fromJson(data);
  }

  /// Creates a [UserAuthModel] from a JSON map
  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    // Parse role from string
    var role = UserRole.user;
    if (json['role'] != null) {
      final roleStr = json['role'].toString();
      if (roleStr == 'admin') {
        role = UserRole.admin;
      } else if (roleStr == 'moderator') {
        role = UserRole.moderator;
      }
    }

    // Parse timestamps
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        createdAt = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt']);
      }
    }

    DateTime? lastLoginAt;
    if (json['lastLoginAt'] != null) {
      if (json['lastLoginAt'] is Timestamp) {
        lastLoginAt = (json['lastLoginAt'] as Timestamp).toDate();
      } else if (json['lastLoginAt'] is int) {
        lastLoginAt = DateTime.fromMillisecondsSinceEpoch(json['lastLoginAt']);
      }
    }

    return UserAuthModel(
      email: json['email'] ?? '',
      uid: json['uid'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      userName: json['userName'] ?? '',
      followers: _convertToStringList(json['followers'] ?? []),
      following: _convertToStringList(json['following'] ?? []),
      status: json['status'] ?? 'offline',
      role: role,
      permissions: _convertToStringList(json['permissions'] ?? []),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isMfaEnabled: json['isMfaEnabled'] ?? false,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Helper method to convert dynamic list to `List<String>`
  static List<String> _convertToStringList(List<dynamic> list) =>
      list.map((item) => item.toString()).toList();

  /// Converts this [UserAuthModel] to a JSON map
  @override
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
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
        'lastLoginAt':
            lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      };
}
