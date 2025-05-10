import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

part 'post_event.dart';
part 'post_state.dart';

/// BLoC for posts
class PostBloc extends Bloc<PostEvent, PostState> {
  /// Constructor
  PostBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(PostInitial()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<LoadUserPostsEvent>(_onLoadUserPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<DeletePostEvent>(_onDeletePost);
    on<LikePostEvent>(_onLikePost);
    on<UnlikePostEvent>(_onUnlikePost);
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<SetSelectedPostEvent>(_onSetSelectedPost);
  }
  final PostRepository _postRepository;

  /// Handle load posts event
  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());

    final result = await _postRepository.getAllPosts();

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (posts) => emit(PostsLoaded(posts: posts)),
    );
  }

  /// Handle load user posts event
  Future<void> _onLoadUserPosts(
    LoadUserPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());

    final result = await _postRepository.getPostsByUserId(event.userId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (posts) => emit(UserPostsLoaded(posts: posts)),
    );
  }

  /// Handle create post event
  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());

    final result = await _postRepository.createPost(
      description: event.description,
      file: event.image,
      uid: event.userId,
      username: event.username,
      profImage: event.profileImage,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (post) => emit(PostCreated(post: post)),
    );
  }

  /// Handle delete post event
  Future<void> _onDeletePost(
    DeletePostEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());

    final result = await _postRepository.deletePost(event.postId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (_) => emit(PostDeleted()),
    );
  }

  /// Handle like post event
  Future<void> _onLikePost(
    LikePostEvent event,
    Emitter<PostState> emit,
  ) async {
    final currentState = state;

    final result = await _postRepository.likePost(
      event.postId,
      event.userId,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (_) {
        if (currentState is PostsLoaded) {
          final updatedPosts = currentState.posts.map((post) {
            if (post.postId == event.postId) {
              return post.copyWith(
                likes: [...post.likes, event.userId],
              );
            }
            return post;
          }).toList();

          emit(PostsLoaded(posts: updatedPosts));
        }
      },
    );
  }

  /// Handle unlike post event
  Future<void> _onUnlikePost(
    UnlikePostEvent event,
    Emitter<PostState> emit,
  ) async {
    final currentState = state;

    final result = await _postRepository.unlikePost(
      event.postId,
      event.userId,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (_) {
        if (currentState is PostsLoaded) {
          final updatedPosts = currentState.posts.map((post) {
            if (post.postId == event.postId) {
              return post.copyWith(
                likes: post.likes.where((id) => id != event.userId).toList(),
              );
            }
            return post;
          }).toList();

          emit(PostsLoaded(posts: updatedPosts));
        }
      },
    );
  }

  /// Handle load comments event
  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(CommentsLoading());

    final result = await _postRepository.getComments(event.postId);

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (comments) => emit(CommentsLoaded(comments: comments)),
    );
  }

  /// Handle add comment event
  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(CommentLoading());

    final result = await _postRepository.postComment(
      postId: event.postId,
      text: event.text,
      uid: event.userId,
      username: event.username,
      profilePic: event.profilePic,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (comment) {
        if (state is CommentsLoaded) {
          final currentComments = (state as CommentsLoaded).comments;
          emit(CommentsLoaded(comments: [...currentComments, comment]));
        } else {
          emit(CommentAdded(comment: comment));
        }
      },
    );
  }

  /// Handle delete comment event
  Future<void> _onDeleteComment(
    DeleteCommentEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(CommentLoading());

    final result = await _postRepository.deleteComment(
      event.commentId,
      event.postId,
    );

    result.fold(
      (failure) => emit(PostError(message: failure.message)),
      (_) => emit(CommentDeleted()),
    );
  }

  /// Handle set selected post event
  void _onSetSelectedPost(
    SetSelectedPostEvent event,
    Emitter<PostState> emit,
  ) {
    emit(SelectedPostLoaded(post: event.post));
  }
}
