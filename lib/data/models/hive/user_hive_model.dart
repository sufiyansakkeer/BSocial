import 'package:hive/hive.dart';
import '../../../domain/entities/user.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 1)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String photoUrl;

  @HiveField(3)
  final String userName;

  @HiveField(4)
  final List<String> followers;

  @HiveField(5)
  final List<String> following;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final DateTime lastUpdated;

  UserHiveModel({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.userName,
    required this.followers,
    required this.following,
    this.status = "offline",
    required this.lastUpdated,
  });

  // Convert from domain entity to Hive model
  factory UserHiveModel.fromEntity(User user) {
    return UserHiveModel(
      email: user.email,
      uid: user.uid,
      photoUrl: user.photoUrl,
      userName: user.userName,
      followers: user.followers,
      following: user.following,
      status: user.status,
      lastUpdated: DateTime.now(),
    );
  }

  // Convert to domain entity
  User toEntity() {
    return User(
      email: email,
      uid: uid,
      photoUrl: photoUrl,
      userName: userName,
      followers: followers,
      following: following,
      status: status,
    );
  }
}
