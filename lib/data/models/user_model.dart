import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.email,
    required super.uid,
    required super.photoUrl,
    required super.userName,
    required super.followers,
    required super.following,
    super.status = 'offline',
  });

  // Create model from Firestore snapshot
  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  // Create model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userName: json['username'] ?? '',
        uid: json['uid'] ?? '',
        email: json['email'] ?? '',
        followers: _convertToStringList(json['followers'] ?? []),
        following: _convertToStringList(json['following'] ?? []),
        photoUrl: json['photoUrl'] ?? '',
        status: json['status'] ?? 'offline',
      );

  // Convert model to JSON
  Map<String, dynamic> toJson() => {
        'username': userName,
        'uid': uid,
        'email': email,
        'followers': followers,
        'following': following,
        'photoUrl': photoUrl,
        'status': status,
      };

  // Helper method to convert dynamic list to List<String>
  static List<String> _convertToStringList(List<dynamic> list) =>
      list.map((item) => item.toString()).toList();
}
