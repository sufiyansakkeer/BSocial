part of 'post_bloc.dart';

/// Base class for all post states
abstract class PostState extends Equatable {
  /// Constructor
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Initial post state
class PostInitial extends PostState {}

/// Loading post state
class PostLoading extends PostState {}

/// Posts loaded state
class PostsLoaded extends PostState {
  /// Constructor
  const PostsLoaded({required this.posts});

  /// List of posts
  final List<Post> posts;

  @override
  List<Object> get props => [posts];
}

/// User posts loaded state
class UserPostsLoaded extends PostState {
  /// Constructor
  const UserPostsLoaded({required this.posts});

  /// List of posts
  final List<Post> posts;

  @override
  List<Object> get props => [posts];
}

/// Post created state
class PostCreated extends PostState {
  /// Constructor
  const PostCreated({required this.post});

  /// Created post
  final Post post;

  @override
  List<Object> get props => [post];
}

/// Post deleted state
class PostDeleted extends PostState {}

/// Comments loading state
class CommentsLoading extends PostState {}

/// Comment loading state
class CommentLoading extends PostState {}

/// Comments loaded state
class CommentsLoaded extends PostState {
  /// Constructor
  const CommentsLoaded({required this.comments});

  /// List of comments
  final List<Comment> comments;

  @override
  List<Object> get props => [comments];
}

/// Comment added state
class CommentAdded extends PostState {
  /// Constructor
  const CommentAdded({required this.comment});

  /// Added comment
  final Comment comment;

  @override
  List<Object> get props => [comment];
}

/// Comment deleted state
class CommentDeleted extends PostState {}

/// Post error state
class PostError extends PostState {
  /// Constructor
  const PostError({required this.message});

  /// Error message
  final String message;

  @override
  List<Object> get props => [message];
}

/// Selected post loaded state
class SelectedPostLoaded extends PostState {
  /// Constructor
  const SelectedPostLoaded({required this.post});

  /// Selected post
  final Post post;

  @override
  List<Object> get props => [post];
}
