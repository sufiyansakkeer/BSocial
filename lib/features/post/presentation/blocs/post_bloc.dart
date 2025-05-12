import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/comment.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

part 'post_event.dart';
part 'post_state.dart';

/// BLoC for posts
class PostBloc extends Bloc<PostEvent, PostState> {
  /// Constructor
  PostBloc({
    required PostRepository postRepository,
    this.onMissingIndexError,
  })  : _postRepository = postRepository,
        super(const PostState()) {
    on<LoadPostsEvent>(_onLoadPosts);
    on<RefreshPostsEvent>(_onRefreshPosts);
    on<LoadUserPostsEvent>(_onLoadUserPosts);
    on<RefreshUserPostsEvent>(_onRefreshUserPosts);
    on<CreatePostEvent>(_onCreatePost);
    on<DeletePostEvent>(_onDeletePost);
    on<LikePostEvent>(_onLikePost);
    on<UnlikePostEvent>(_onUnlikePost);
    on<LoadCommentsEvent>(_onLoadComments);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<SetSelectedPostEvent>(_onSetSelectedPost);
  }

  /// Repository for posts
  final PostRepository _postRepository;

  /// Callback for missing index error
  final void Function(BuildContext context, String errorMessage)?
      onMissingIndexError;

  /// Handle load posts event
  Future<void> _onLoadPosts(
    LoadPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    // Don't reload if we're already loading or have loaded posts
    if (state.status == PostStatus.loading ||
        (state.status == PostStatus.postsLoaded && !state.isUserPosts)) {
      return;
    }

    emit(state.copyWith(status: PostStatus.loading));

    final result = await _postRepository.getAllPosts();

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (posts) => emit(state.copyWith(
        status: PostStatus.postsLoaded,
        posts: posts,
        isUserPosts: false,
      )),
    );
  }

  /// Handle refresh posts event (background refresh without loading state)
  Future<void> _onRefreshPosts(
    RefreshPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    // Only refresh if we have posts loaded or are in refreshing state
    if (state.status != PostStatus.postsLoaded &&
        state.status != PostStatus.refreshing) {
      return;
    }

    // Set state to refreshing to indicate background refresh
    if (state.status != PostStatus.refreshing) {
      emit(state.copyWith(status: PostStatus.refreshing));
    }

    final result = await _postRepository.getAllPosts();

    result.fold(
      (failure) {
        // On failure, keep showing the old data but log the error
        debugPrint('Background refresh failed: ${failure.message}');
        // Return to postsLoaded state
        emit(state.copyWith(status: PostStatus.postsLoaded));
      },
      (posts) {
        // Check if posts are different from current posts
        final currentPostIds = state.posts.map((p) => p.postId).toSet();
        final newPostIds = posts.map((p) => p.postId).toSet();

        final hasNewPosts =
            !const SetEquality().equals(currentPostIds, newPostIds);
        final hasUpdatedPosts = posts.any((newPost) {
          final oldPost = state.posts.firstWhere(
            (p) => p.postId == newPost.postId,
            orElse: () => newPost,
          );
          return newPost.likes.length != oldPost.likes.length;
        });

        // Only update UI if there are changes
        if (hasNewPosts || hasUpdatedPosts) {
          emit(state.copyWith(
            status: PostStatus.postsLoaded,
            posts: posts,
            isUserPosts: false,
          ));
        } else {
          // No changes, just return to postsLoaded state
          emit(state.copyWith(status: PostStatus.postsLoaded));
        }
      },
    );
  }

  /// Handle load user posts event
  Future<void> _onLoadUserPosts(
    LoadUserPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    // Don't reload if we're already loading or have loaded the same user's posts
    final alreadyLoaded = state.status == PostStatus.userPostsLoaded &&
        state.isUserPosts &&
        state.posts.isNotEmpty &&
        state.posts.first.uid == event.userId;

    if (state.status == PostStatus.loading || alreadyLoaded) {
      return;
    }

    emit(state.copyWith(status: PostStatus.loading));

    final result = await _postRepository.getPostsByUserId(event.userId);

    result.fold(
      (failure) {
        // Check if the error is related to missing index
        if (failure.message.contains('requires an index') &&
            event.context != null &&
            onMissingIndexError != null) {
          // Call the callback to show the missing index dialog
          onMissingIndexError!(event.context!, failure.message);
        }

        emit(state.copyWith(
          status: PostStatus.error,
          errorMessage: failure.message,
        ));
      },
      (posts) => emit(state.copyWith(
        status: PostStatus.userPostsLoaded,
        posts: posts,
        isUserPosts: true,
      )),
    );
  }

  /// Handle refresh user posts event (background refresh without loading state)
  Future<void> _onRefreshUserPosts(
    RefreshUserPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    // Only refresh if we have user posts loaded or are in refreshing state
    if ((state.status != PostStatus.userPostsLoaded &&
            state.status != PostStatus.refreshing) ||
        !state.isUserPosts) {
      return;
    }

    // Set state to refreshing to indicate background refresh
    if (state.status != PostStatus.refreshing) {
      emit(state.copyWith(status: PostStatus.refreshing));
    }

    final result = await _postRepository.getPostsByUserId(event.userId);

    result.fold(
      (failure) {
        // On failure, keep showing the old data but log the error
        debugPrint('Background refresh failed: ${failure.message}');
        // Return to userPostsLoaded state
        emit(state.copyWith(status: PostStatus.userPostsLoaded));
      },
      (posts) {
        // Check if posts are different from current posts
        final currentPostIds = state.posts.map((p) => p.postId).toSet();
        final newPostIds = posts.map((p) => p.postId).toSet();

        final hasNewPosts =
            !const SetEquality().equals(currentPostIds, newPostIds);
        final hasUpdatedPosts = posts.any((newPost) {
          final oldPost = state.posts.firstWhere(
            (p) => p.postId == newPost.postId,
            orElse: () => newPost,
          );
          return newPost.likes.length != oldPost.likes.length;
        });

        // Only update UI if there are changes
        if (hasNewPosts || hasUpdatedPosts) {
          emit(state.copyWith(
            status: PostStatus.userPostsLoaded,
            posts: posts,
            isUserPosts: true,
          ));
        } else {
          // No changes, just return to userPostsLoaded state
          emit(state.copyWith(status: PostStatus.userPostsLoaded));
        }
      },
    );
  }

  /// Handle create post event
  Future<void> _onCreatePost(
    CreatePostEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));

    final result = await _postRepository.createPost(
      description: event.description,
      file: event.image,
      uid: event.userId,
      username: event.username,
      profImage: event.profileImage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (post) => emit(state.copyWith(
        status: PostStatus.postCreated,
        post: post,
      )),
    );
  }

  /// Handle delete post event
  Future<void> _onDeletePost(
    DeletePostEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));

    final result = await _postRepository.deletePost(event.postId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: PostStatus.postDeleted)),
    );
  }

  /// Handle like post event
  Future<void> _onLikePost(
    LikePostEvent event,
    Emitter<PostState> emit,
  ) async {
    final currentState = state;

    // Only proceed if we have posts loaded
    if (currentState.status != PostStatus.postsLoaded &&
        currentState.status != PostStatus.userPostsLoaded) {
      return;
    }

    final result = await _postRepository.likePost(
      event.postId,
      event.userId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.postId == event.postId) {
            return post.copyWith(
              likes: [...post.likes, event.userId],
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(
          posts: updatedPosts,
        ));
      },
    );
  }

  /// Handle unlike post event
  Future<void> _onUnlikePost(
    UnlikePostEvent event,
    Emitter<PostState> emit,
  ) async {
    final currentState = state;

    // Only proceed if we have posts loaded
    if (currentState.status != PostStatus.postsLoaded &&
        currentState.status != PostStatus.userPostsLoaded) {
      return;
    }

    final result = await _postRepository.unlikePost(
      event.postId,
      event.userId,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedPosts = currentState.posts.map((post) {
          if (post.postId == event.postId) {
            return post.copyWith(
              likes: post.likes.where((id) => id != event.userId).toList(),
            );
          }
          return post;
        }).toList();

        emit(currentState.copyWith(
          posts: updatedPosts,
        ));
      },
    );
  }

  /// Handle load comments event
  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loadingComments));

    final result = await _postRepository.getComments(event.postId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (comments) => emit(state.copyWith(
        status: PostStatus.commentsLoaded,
        comments: comments,
      )),
    );
  }

  /// Handle add comment event
  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loadingComment));

    final result = await _postRepository.postComment(
      postId: event.postId,
      text: event.text,
      uid: event.userId,
      username: event.username,
      profilePic: event.profilePic,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (comment) {
        if (state.status == PostStatus.commentsLoaded) {
          // If we already have comments loaded, add the new comment to the list
          emit(state.copyWith(
            status: PostStatus.commentsLoaded,
            comments: [...state.comments, comment],
          ));
        } else {
          // Otherwise just set the comment added status
          emit(state.copyWith(
            status: PostStatus.commentAdded,
            comment: comment,
          ));
        }
      },
    );
  }

  /// Handle delete comment event
  Future<void> _onDeleteComment(
    DeleteCommentEvent event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loadingComment));

    final result = await _postRepository.deleteComment(
      event.commentId,
      event.postId,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: PostStatus.commentDeleted)),
    );
  }

  /// Handle set selected post event
  void _onSetSelectedPost(
    SetSelectedPostEvent event,
    Emitter<PostState> emit,
  ) {
    emit(state.copyWith(
      status: PostStatus.selectedPostLoaded,
      post: event.post,
    ));
  }
}
