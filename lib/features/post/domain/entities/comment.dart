/// Comment entity class
class Comment {
  /// Constructor
  const Comment({
    required this.commentId,
    required this.postId,
    required this.uid,
    required this.username,
    required this.text,
    required this.profilePic,
    required this.datePublished,
  });

  /// Comment ID
  final String commentId;

  /// Post ID this comment belongs to
  final String postId;

  /// User ID of the commenter
  final String uid;

  /// Username of the commenter
  final String username;

  /// Comment text content
  final String text;

  /// Profile picture URL of the commenter
  final String profilePic;

  /// Date when the comment was published
  final DateTime datePublished;

  /// Create a copy of this comment with the given fields replaced
  /// with the new values
  Comment copyWith({
    String? commentId,
    String? postId,
    String? uid,
    String? username,
    String? text,
    String? profilePic,
    DateTime? datePublished,
  }) =>
      Comment(
        commentId: commentId ?? this.commentId,
        postId: postId ?? this.postId,
        uid: uid ?? this.uid,
        username: username ?? this.username,
        text: text ?? this.text,
        profilePic: profilePic ?? this.profilePic,
        datePublished: datePublished ?? this.datePublished,
      );
}
