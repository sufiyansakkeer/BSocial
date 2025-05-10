part of 'post_bloc.dart';

/// Base class for all post events
abstract class PostEvent extends Equatable {
  /// Constructor
  const PostEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all posts
class LoadPostsEvent extends PostEvent {}

/// Event to load posts by user ID
class LoadUserPostsEvent extends PostEvent {
  /// Constructor
  const LoadUserPostsEvent({required this.userId});

  /// User ID
  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to create a post
class CreatePostEvent extends PostEvent {
  /// Constructor
  const CreatePostEvent({
    required this.description,
    required this.image,
    required this.userId,
    required this.username,
    required this.profileImage,
  });

  /// Description
  final String description;

  /// Image
  final Uint8List image;

  /// User ID
  final String userId;

  /// Username
  final String username;

  /// Profile image URL
  final String profileImage;

  @override
  List<Object> get props => [
        description,
        image,
        userId,
        username,
        profileImage,
      ];
}

/// Event to delete a post
class DeletePostEvent extends PostEvent {
  /// Constructor
  const DeletePostEvent({required this.postId});

  /// Post ID
  final String postId;

  @override
  List<Object> get props => [postId];
}

/// Event to like a post
class LikePostEvent extends PostEvent {
  /// Constructor
  const LikePostEvent({
    required this.postId,
    required this.userId,
  });

  /// Post ID
  final String postId;

  /// User ID
  final String userId;

  @override
  List<Object> get props => [postId, userId];
}

/// Event to unlike a post
class UnlikePostEvent extends PostEvent {
  /// Constructor
  const UnlikePostEvent({
    required this.postId,
    required this.userId,
  });

  /// Post ID
  final String postId;

  /// User ID
  final String userId;

  @override
  List<Object> get props => [postId, userId];
}

/// Event to load comments for a post
class LoadCommentsEvent extends PostEvent {
  /// Constructor
  const LoadCommentsEvent({required this.postId});

  /// Post ID
  final String postId;

  @override
  List<Object> get props => [postId];
}

/// Event to add a comment to a post
class AddCommentEvent extends PostEvent {
  /// Constructor
  const AddCommentEvent({
    required this.postId,
    required this.text,
    required this.userId,
    required this.username,
    required this.profilePic,
  });

  /// Post ID
  final String postId;

  /// Comment text
  final String text;

  /// User ID
  final String userId;

  /// Username
  final String username;

  /// Profile picture URL
  final String profilePic;

  @override
  List<Object> get props => [
        postId,
        text,
        userId,
        username,
        profilePic,
      ];
}

/// Event to delete a comment
class DeleteCommentEvent extends PostEvent {
  /// Constructor
  const DeleteCommentEvent({
    required this.commentId,
    required this.postId,
  });

  /// Comment ID
  final String commentId;

  /// Post ID
  final String postId;

  @override
  List<Object> get props => [commentId, postId];
}

/// Event to set the selected post
class SetSelectedPostEvent extends PostEvent {
  /// Constructor
  const SetSelectedPostEvent({required this.post});

  /// Post
  final Post post;

  @override
  List<Object> get props => [post];
}
