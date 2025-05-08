import 'package:hive/hive.dart';
import '../../../domain/entities/post.dart';

part 'post_hive_model.g.dart';

@HiveType(typeId: 2)
class PostHiveModel extends HiveObject {
  PostHiveModel({
    required this.postId,
    required this.uid,
    required this.username,
    required this.description,
    required this.postUrl,
    required this.profImage,
    required this.datePublished,
    required this.likes,
    required this.lastUpdated,
  });

  // Convert from domain entity to Hive model
  factory PostHiveModel.fromEntity(Post post) => PostHiveModel(
        postId: post.postId,
        uid: post.uid,
        username: post.username,
        description: post.description,
        postUrl: post.postUrl,
        profImage: post.profImage,
        datePublished: post.datePublished,
        likes: post.likes,
        lastUpdated: DateTime.now(),
      );
  @HiveField(0)
  final String postId;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String postUrl;

  @HiveField(5)
  final String profImage;

  @HiveField(6)
  final DateTime datePublished;

  @HiveField(7)
  final List<String> likes;

  @HiveField(8)
  final DateTime lastUpdated;

  // Convert to domain entity
  Post toEntity() => Post(
        postId: postId,
        uid: uid,
        username: username,
        description: description,
        postUrl: postUrl,
        profImage: profImage,
        datePublished: datePublished,
        likes: likes,
      );
}
