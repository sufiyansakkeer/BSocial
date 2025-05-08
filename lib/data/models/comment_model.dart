import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.commentId,
    required super.postId,
    required super.uid,
    required super.username,
    required super.text,
    required super.profilePic,
    required super.datePublished,
  });

  // Create model from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        commentId: json['commentId'] ?? '',
        postId: json['postId'] ?? '',
        uid: json['uid'] ?? '',
        username: json['username'] ?? '',
        text: json['text'] ?? '',
        profilePic: json['profilePic'] ?? '',
        datePublished: (json['datePublished'] as Timestamp).toDate(),
      );

  // Convert model to JSON
  Map<String, dynamic> toJson() => {
        'commentId': commentId,
        'postId': postId,
        'uid': uid,
        'username': username,
        'text': text,
        'profilePic': profilePic,
        'datePublished': datePublished,
      };

  // Create model from Firestore snapshot
  static CommentModel fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return CommentModel.fromJson(data);
  }
}
