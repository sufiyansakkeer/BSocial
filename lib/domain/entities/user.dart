import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.uid,
    required this.username,
    required this.profilePic,
    this.email = '',
    this.photoUrl = '',
    this.userName = '',
    this.followers = const [],
    this.following = const [],
    this.status = '',
  });

  final String uid;
  final String username;
  final String profilePic;
  final String email;
  final String photoUrl;
  final String userName;
  final List<String> followers;
  final List<String> following;
  final String status;

  User copyWith({
    String? uid,
    String? username,
    String? profilePic,
    String? email,
    String? photoUrl,
    String? userName,
    List<String>? followers,
    List<String>? following,
    String? status,
  }) =>
      User(
        uid: uid ?? this.uid,
        username: username ?? this.username,
        profilePic: profilePic ?? this.profilePic,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        userName: userName ?? this.userName,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [
        uid,
        username,
        profilePic,
        email,
        photoUrl,
        userName,
        followers,
        following,
        status,
      ];
}
