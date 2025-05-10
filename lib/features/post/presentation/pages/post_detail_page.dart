import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../blocs/post_bloc.dart';

/// Page for viewing post details and comments
class PostDetailPage extends StatefulWidget {
  /// Constructor
  const PostDetailPage({
    required this.postId,
    super.key,
  });
  
  /// Post ID
  final String postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load comments when the page is first loaded
    context.read<PostBloc>().add(LoadCommentsEvent(postId: widget.postId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Post a comment
  void _postComment() {
    if (_commentController.text.isEmpty) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<PostBloc>().add(
            AddCommentEvent(
              postId: widget.postId,
              text: _commentController.text,
              userId: authState.user.uid,
              username: authState.user.userName,
              profilePic: authState.user.photoUrl,
            ),
          );
      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to comment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Post Details'),
        ),
        body: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {
            if (state is CommentLoading) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }

            if (state is CommentAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is CommentDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is PostError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CommentsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CommentsLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: state.comments.isEmpty
                        ? const Center(
                            child: Text(
                                'No comments yet. Be the first to comment!'),
                          )
                        : ListView.builder(
                            itemCount: state.comments.length,
                            itemBuilder: (context, index) {
                              final comment = state.comments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(comment.profilePic),
                                ),
                                title: Text(comment.username),
                                subtitle: Text(comment.text),
                                trailing: context.read<AuthBloc>().state
                                            is Authenticated &&
                                        (context.read<AuthBloc>().state
                                                    as Authenticated)
                                                .user
                                                .uid ==
                                            comment.uid
                                    ? IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          context.read<PostBloc>().add(
                                                DeleteCommentEvent(
                                                  commentId: comment.commentId,
                                                  postId: widget.postId,
                                                ),
                                              );
                                        },
                                      )
                                    : null,
                              );
                            },
                          ),
                  ),
                  // Comment input
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: _isLoading
                              ? const CircularProgressIndicator()
                              : const Icon(Icons.send),
                          onPressed: _isLoading ? null : _postComment,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is PostError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<PostBloc>()
                            .add(LoadCommentsEvent(postId: widget.postId));
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Post Detail Page - To be implemented'),
                    const SizedBox(height: 8),
                    Text('Post ID: ${widget.postId}'),
                  ],
                ),
              );
            }
          },
        ),
      );
}
