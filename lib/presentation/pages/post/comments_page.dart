import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/ui_constants.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/post/post_provider.dart';
import '../../widgets/common/custom_text_field.dart';

class CommentsPage extends StatefulWidget {
  final String postId;

  const CommentsPage({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load comments when the page is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false)
          .getComments(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mobileBackgroundColor,
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, postProvider, _) {
                if (postProvider.status == PostStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (postProvider.status == PostStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${postProvider.errorMessage}'),
                        UiConstants.kHeight20,
                        ElevatedButton(
                          onPressed: () =>
                              postProvider.getComments(widget.postId),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (postProvider.comments.isEmpty) {
                  return const Center(
                    child: Text('No comments yet. Be the first to comment!'),
                  );
                }

                return ListView.builder(
                  itemCount: postProvider.comments.length,
                  itemBuilder: (context, index) {
                    final comment = postProvider.comments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(comment.profilePic),
                          ),
                          UiConstants.kWidth,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormat.yMMMd()
                                          .format(comment.datePublished),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, _) {
                                        final currentUser =
                                            authProvider.currentUser;
                                        if (currentUser != null &&
                                            (comment.uid == currentUser.uid ||
                                                postProvider
                                                        .selectedPost?.uid ==
                                                    currentUser.uid)) {
                                          return IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                size: 16),
                                            onPressed: () => _deleteComment(
                                              context,
                                              comment.commentId,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ],
                                ),
                                Text(comment.text),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Comment input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final currentUser = authProvider.currentUser;
                if (currentUser == null) {
                  return const Center(
                    child: Text('You need to be logged in to comment'),
                  );
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(currentUser.photoUrl),
                    ),
                    UiConstants.kWidth,
                    Expanded(
                      child: CustomTextField(
                        controller: _commentController,
                        hintText: 'Add a comment...',
                        enabled: !_isSubmitting,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _postComment(context),
                      ),
                    ),
                    IconButton(
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send),
                      onPressed:
                          _isSubmitting ? null : () => _postComment(context),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _postComment(BuildContext context) async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        SnackbarUtils.showSnackBar(
            'You need to be logged in to comment', context);
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final success = await postProvider.postComment(
        postId: widget.postId,
        text: comment,
        uid: currentUser.uid,
        username: currentUser.userName,
        profilePic: currentUser.photoUrl,
      );

      if (!mounted) return;

      if (success) {
        _commentController.clear();
      } else {
        final errorMessage = postProvider.errorMessage.isNotEmpty
            ? postProvider.errorMessage
            : 'Failed to post comment';

        if (context.mounted) {
          SnackbarUtils.showSnackBar(errorMessage, context);
        }
      }
    } catch (e) {
      if (!mounted) return;

      if (context.mounted) {
        SnackbarUtils.showSnackBar('An error occurred: $e', context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _deleteComment(BuildContext context, String commentId) async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await postProvider.deleteComment(commentId, widget.postId);

      if (!mounted) return;

      if (!success && context.mounted) {
        final errorMessage = postProvider.errorMessage.isNotEmpty
            ? postProvider.errorMessage
            : 'Failed to delete comment';

        SnackbarUtils.showSnackBar(errorMessage, context);
      }
    }
  }
}
