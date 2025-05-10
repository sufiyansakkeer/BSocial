import 'package:hive/hive.dart';
import '../../../domain/entities/comment.dart';

part 'comment_hive_model.g.dart';

/// Hive model for [Comment] entity
@HiveType(typeId: 5)
class CommentHiveModel extends HiveObject {
  /// Constructor
  CommentHiveModel({
    required this.commentId,
    required this.postId,
    required this.uid,
    required this.username,
    required this.text,
    required this.profilePic,
    required this.datePublished,
    required this.lastUpdated,
  });

  /// Convert from domain entity to Hive model
  factory CommentHiveModel.fromEntity(Comment comment) => CommentHiveModel(
        commentId: comment.commentId,
        postId: comment.postId,
        uid: comment.uid,
        username: comment.username,
        text: comment.text,
        profilePic: comment.profilePic,
        datePublished: comment.datePublished,
        lastUpdated: DateTime.now(),
      );
      
  /// Comment ID
  @HiveField(0)
  final String commentId;

  /// Post ID this comment belongs to
  @HiveField(1)
  final String postId;

  /// User ID of the commenter
  @HiveField(2)
  final String uid;

  /// Username of the commenter
  @HiveField(3)
  final String username;

  /// Comment text content
  @HiveField(4)
  final String text;

  /// Profile picture URL of the commenter
  @HiveField(5)
  final String profilePic;

  /// Date when the comment was published
  @HiveField(6)
  final DateTime datePublished;

  /// When the comment was last updated in local storage
  @HiveField(7)
  final DateTime lastUpdated;

  /// Convert to domain entity
  Comment toEntity() => Comment(
        commentId: commentId,
        postId: postId,
        uid: uid,
        username: username,
        text: text,
        profilePic: profilePic,
        datePublished: datePublished,
      );
}
