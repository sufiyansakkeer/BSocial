import 'package:hive/hive.dart';
import '../../../domain/entities/post.dart';

part 'post_hive_model.g.dart';

/// Hive model for [Post] entity
@HiveType(typeId: 2)
class PostHiveModel extends HiveObject {
  /// Constructor
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

  /// Convert from domain entity to Hive model
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
      
  /// Post ID
  @HiveField(0)
  final String postId;

  /// User ID of the post creator
  @HiveField(1)
  final String uid;

  /// Username of the post creator
  @HiveField(2)
  final String username;

  /// Post description/caption
  @HiveField(3)
  final String description;

  /// URL to the post image
  @HiveField(4)
  final String postUrl;

  /// URL to the profile image of the post creator
  @HiveField(5)
  final String profImage;

  /// Date when the post was published
  @HiveField(6)
  final DateTime datePublished;

  /// List of user IDs who liked the post
  @HiveField(7)
  final List<String> likes;

  /// When the post was last updated in local storage
  @HiveField(8)
  final DateTime lastUpdated;

  /// Convert to domain entity
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
