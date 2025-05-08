// Post entity class
class Post {
  final String postId;
  final String uid;
  final String username;
  final String description;
  final String postUrl;
  final String profImage;
  final DateTime datePublished;
  final List<String> likes;
  
  const Post({
    required this.postId,
    required this.uid,
    required this.username,
    required this.description,
    required this.postUrl,
    required this.profImage,
    required this.datePublished,
    required this.likes,
  });
}
