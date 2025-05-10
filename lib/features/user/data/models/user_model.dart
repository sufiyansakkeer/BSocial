import 'package:bsocial/domain/entities/user.dart'; // Use package import
import 'package:cloud_firestore/cloud_firestore.dart';

/// User model that extends the User entity
class UserModel extends User {
  /// Constructor
  const UserModel({
    // Parameters for User superclass
    required super.uid,
    required super.username,
    required super.profilePic,
    super.email,
    super.photoUrl,
    super.userName,
    super.followers,
    super.following,
    super.status,
    // Parameters for UserModel specific fields
    this.bio = '',
    this.isMfaEnabled = false,
    this.isEmailVerified = false,
  });

  /// Create model from Firestore snapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data();
    if (data is! Map<String, dynamic>) {
      // Fallback for when snapshot data is not as expected
      return const UserModel(
        uid: '', // Required by User
        username: '', // Required by User
        profilePic: '', // Required by User
        // UserModel specific fields will use their default values from constructor
        // Other User fields will use their defaults from User constructor
      );
    }
    return UserModel.fromJson(data);
  }

  /// Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] ?? '',
        username: json['username'] ?? '',
        profilePic: json['profilePic'] ?? '',
        email: json['email'] ?? '',
        photoUrl: json['photoUrl'] ?? '', // This is one photoUrl
        userName: json['userName'] ?? '',
        followers: _convertToStringList(json['followers'] ?? []),
        following: _convertToStringList(json['following'] ?? []),
        status: json['status'] ?? 'offline',
        // UserModel specific fields
        bio: json['bio'] ?? '',
        isMfaEnabled: json['isMfaEnabled'] ?? false,
        isEmailVerified: json['isEmailVerified'] ?? false,
      );
  // UserModel specific fields (not in canonical User entity)
  final String bio;
  final bool isMfaEnabled;
  final bool isEmailVerified;

  /// Convert model to JSON
  Map<String, dynamic> toJson() => {
        // Fields from User superclass
        'uid': super.uid,
        'username': super.username,
        'profilePic': super.profilePic,
        'email': super.email,
        'photoUrl': super.photoUrl,
        'userName': super.userName,
        'followers': super.followers,
        'following': super.following,
        'status': super.status,
        // UserModel specific fields
        'bio': bio,
        'isMfaEnabled': isMfaEnabled,
        'isEmailVerified': isEmailVerified,
      };

  // Helper method to convert dynamic list to List<String>
  static List<String> _convertToStringList(List<dynamic> list) =>
      list.map((item) => item.toString()).toList();

  /// Convert model to entity
  User toEntity() => User(
        uid: super.uid,
        username: super.username,
        profilePic: super.profilePic,
        email: super.email,
        photoUrl: super.photoUrl,
        userName: super.userName,
        followers: super.followers,
        following: super.following,
        status: super.status,
        // UserModel-specific fields (bio, isMfaEnabled, isEmailVerified) are not in the canonical User entity.
      );
}
