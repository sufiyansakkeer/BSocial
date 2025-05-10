import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../domain/entities/post.dart';
import '../blocs/post_bloc.dart';

/// A card widget that displays a post
class PostCard extends StatefulWidget {
  /// Constructor
  const PostCard({
    required this.post,
    super.key,
  });

  /// The post to display
  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    // Use a simpler animation curve to reduce GPU load
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Simplify animation to reduce flickering
    _likeAnimation = Tween<double>(
      begin: 1,
      end: 1.4, // Reduce the scale amount
    ).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeOut, // Use simpler curve
      ),
    );

    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _likeAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final currentUserId =
            authState is Authenticated ? authState.user.uid : null;
        final isLiked = widget.post.likes.contains(currentUserId);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UiConstants.borderRadiusLarge),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Header
              Padding(
                padding: UiConstants.paddingH16V8,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(widget.post.profImage),
                    ),
                    UiConstants.kWidth12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            DateFormat.yMMMd()
                                .format(widget.post.datePublished),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withAlpha(150),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.post.uid == currentUserId)
                      IconButton(
                        onPressed: () => _showDeleteDialog(context),
                        icon: const Icon(Icons.more_vert),
                      ),
                  ],
                ),
              ),

              // Post Image
              GestureDetector(
                onDoubleTap: () {
                  if (currentUserId != null) {
                    HapticFeedback.mediumImpact();
                    _likePost(context, currentUserId);
                    _likeAnimationController.forward();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image with RepaintBoundary for better performance
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      child: RepaintBoundary(
                        child: Image.network(
                          widget.post.postUrl,
                          fit: BoxFit.cover,
                          cacheWidth: MediaQuery.of(context).size.width.toInt(),
                          gaplessPlayback: true,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Container(
                              color: theme.colorScheme.surface,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: theme.colorScheme.surface,
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Like animation overlay
                    ScaleTransition(
                      scale: _likeAnimation,
                      child: AnimatedOpacity(
                        opacity: _likeAnimationController.value,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Post Actions
              Padding(
                padding: UiConstants.paddingH8,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: currentUserId != null
                          ? () => _likePost(context, currentUserId)
                          : null,
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? AppColors.accentPink : null,
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _navigateToComments(context),
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bookmarks coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.bookmark_border,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Like Count and Description
              Padding(
                padding: UiConstants.paddingH16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.post.likes.length} likes',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    UiConstants.kHeight8,
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: widget.post.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(text: widget.post.description),
                        ],
                      ),
                    ),
                    UiConstants.kHeight16,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _likePost(BuildContext context, String currentUserId) {
    if (widget.post.likes.contains(currentUserId)) {
      context.read<PostBloc>().add(UnlikePostEvent(
            postId: widget.post.postId,
            userId: currentUserId,
          ));
    } else {
      context.read<PostBloc>().add(LikePostEvent(
            postId: widget.post.postId,
            userId: currentUserId,
          ));
    }
  }

  void _navigateToComments(BuildContext context) {
    context.read<PostBloc>().add(SetSelectedPostEvent(post: widget.post));
    context.go('/post/${widget.post.postId}');
  }

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
        ),
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PostBloc>().add(DeletePostEvent(
                    postId: widget.post.postId,
                  ));
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
