// Comment entity class
class Comment {
  final String commentId;
  final String postId;
  final String uid;
  final String username;
  final String text;
  final String profilePic;
  final DateTime datePublished;
  
  const Comment({
    required this.commentId,
    required this.postId,
    required this.uid,
    required this.username,
    required this.text,
    required this.profilePic,
    required this.datePublished,
  });
}
