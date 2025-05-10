import 'package:hive/hive.dart';
import '../../../features/user/domain/entities/user.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 1)
class UserHiveModel extends HiveObject {
  UserHiveModel({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.userName,
    required this.followers,
    required this.following,
    required this.lastUpdated,
    this.status = 'offline',
    this.bio = '',
    this.isMfaEnabled = false,
    this.isEmailVerified = false,
  });

  // Convert from domain entity to Hive model
  factory UserHiveModel.fromEntity(User user) => UserHiveModel(
        email: user.email,
        uid: user.uid,
        photoUrl: user.photoUrl,
        userName: user.userName,
        followers: user.followers,
        following: user.following,
        status: user.status,
        bio: user.bio,
        isMfaEnabled: user.isMfaEnabled,
        isEmailVerified: user.isEmailVerified,
        lastUpdated: DateTime.now(),
      );
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

  @HiveField(8)
  final String bio;

  @HiveField(9)
  final bool isMfaEnabled;

  @HiveField(10)
  final bool isEmailVerified;

  // Convert to domain entity
  User toEntity() => User(
        email: email,
        uid: uid,
        photoUrl: photoUrl,
        userName: userName,
        followers: followers,
        following: following,
        status: status,
        bio: bio,
        isMfaEnabled: isMfaEnabled,
        isEmailVerified: isEmailVerified,
      );
}
