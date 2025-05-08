import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.postId,
    required super.uid,
    required super.username,
    required super.description,
    required super.postUrl,
    required super.profImage,
    required super.datePublished,
    required super.likes,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'uid': uid,
        'username': username,
        'description': description,
        'postUrl': postUrl,
        'profImage': profImage,
        'datePublished': datePublished,
        'likes': likes,
      };

  // Create model from JSON
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'] ?? '',
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      description: json['description'] ?? '',
      postUrl: json['postUrl'] ?? '',
      profImage: json['profImage'] ?? '',
      datePublished: (json['datePublished'] as Timestamp).toDate(),
      likes: _convertToStringList(json['likes'] ?? []),
    );
  }

  // Create model from Firestore snapshot
  static PostModel fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PostModel.fromJson(data);
  }
  
  // Helper method to convert dynamic list to List<String>
  static List<String> _convertToStringList(List<dynamic> list) {
    return list.map((item) => item.toString()).toList();
  }
}
