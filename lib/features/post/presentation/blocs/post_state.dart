part of 'post_bloc.dart';

/// Enum representing the status of the post state
enum PostStatus {
  /// Initial state
  initial,

  /// Loading state
  loading,

  /// Loading comments state
  loadingComments,

  /// Loading a single comment state
  loadingComment,

  /// Posts loaded state
  postsLoaded,

  /// User posts loaded state
  userPostsLoaded,

  /// Post created state
  postCreated,

  /// Post deleted state
  postDeleted,

  /// Comments loaded state
  commentsLoaded,

  /// Comment added state
  commentAdded,

  /// Comment deleted state
  commentDeleted,

  /// Selected post loaded state
  selectedPostLoaded,

  /// Background refreshing state - showing cached data while refreshing
  refreshing,

  /// Error state
  error
}

/// Unified post state class
class PostState extends Equatable {
  /// Constructor
  const PostState({
    this.status = PostStatus.initial,
    this.posts = const [],
    this.post,
    this.comments = const [],
    this.comment,
    this.errorMessage,
    this.isUserPosts = false,
  });

  /// Status of the post state
  final PostStatus status;

  /// List of posts
  final List<Post> posts;

  /// Single post (for creation, selection, etc.)
  final Post? post;

  /// List of comments
  final List<Comment> comments;

  /// Single comment (for addition, etc.)
  final Comment? comment;

  /// Error message
  final String? errorMessage;

  /// Flag to indicate if posts are user posts
  final bool isUserPosts;

  /// Create a copy of this state with the given fields replaced
  PostState copyWith({
    PostStatus? status,
    List<Post>? posts,
    Post? post,
    List<Comment>? comments,
    Comment? comment,
    String? errorMessage,
    bool? isUserPosts,
  }) =>
      PostState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        post: post ?? this.post,
        comments: comments ?? this.comments,
        comment: comment ?? this.comment,
        errorMessage: errorMessage ?? this.errorMessage,
        isUserPosts: isUserPosts ?? this.isUserPosts,
      );

  @override
  List<Object?> get props => [
        status,
        posts,
        post,
        comments,
        comment,
        errorMessage,
        isUserPosts,
      ];

  /// Helper method to check if the state is in loading status
  bool get isLoading =>
      status == PostStatus.loading ||
      status == PostStatus.loadingComments ||
      status == PostStatus.loadingComment;

  /// Helper method to check if the state is refreshing in the background
  bool get isRefreshing => status == PostStatus.refreshing;

  /// Helper method to check if the state has an error
  bool get hasError => status == PostStatus.error;

  /// Helper method to check if the state has loaded data (either from cache or remote)
  bool get hasLoadedData =>
      status == PostStatus.postsLoaded ||
      status == PostStatus.userPostsLoaded ||
      status == PostStatus.refreshing;
}
