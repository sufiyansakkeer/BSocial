/// Post entity class
class Post {
  /// Constructor
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

  /// Post ID
  final String postId;

  /// User ID of the post creator
  final String uid;

  /// Username of the post creator
  final String username;

  /// Post description/caption
  final String description;

  /// URL to the post image
  final String postUrl;

  /// URL to the profile image of the post creator
  final String profImage;

  /// Date when the post was published
  final DateTime datePublished;

  /// List of user IDs who liked the post
  final List<String> likes;

  /// Create a copy of this post with the given fields replaced
  /// with the new values
  Post copyWith({
    String? postId,
    String? uid,
    String? username,
    String? description,
    String? postUrl,
    String? profImage,
    DateTime? datePublished,
    List<String>? likes,
  }) =>
      Post(
        postId: postId ?? this.postId,
        uid: uid ?? this.uid,
        username: username ?? this.username,
        description: description ?? this.description,
        postUrl: postUrl ?? this.postUrl,
        profImage: profImage ?? this.profImage,
        datePublished: datePublished ?? this.datePublished,
        likes: likes ?? this.likes,
      );
}
