import 'package:hive/hive.dart';
import '../../../domain/entities/comment.dart';

part 'comment_hive_model.g.dart';

@HiveType(typeId: 5)
class CommentHiveModel extends HiveObject {
  @HiveField(0)
  final String commentId;

  @HiveField(1)
  final String postId;

  @HiveField(2)
  final String uid;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String text;

  @HiveField(5)
  final String profilePic;

  @HiveField(6)
  final DateTime datePublished;

  @HiveField(7)
  final DateTime lastUpdated;

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

  // Convert from domain entity to Hive model
  factory CommentHiveModel.fromEntity(Comment comment) {
    return CommentHiveModel(
      commentId: comment.commentId,
      postId: comment.postId,
      uid: comment.uid,
      username: comment.username,
      text: comment.text,
      profilePic: comment.profilePic,
      datePublished: comment.datePublished,
      lastUpdated: DateTime.now(),
    );
  }

  // Convert to domain entity
  Comment toEntity() {
    return Comment(
      commentId: commentId,
      postId: postId,
      uid: uid,
      username: username,
      text: text,
      profilePic: profilePic,
      datePublished: datePublished,
    );
  }
}
