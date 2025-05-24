import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_system.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';
import '../../../../core/widgets/avatars/bs_avatar.dart';
import '../../../../core/widgets/buttons/bs_button.dart';
import '../../../../core/widgets/cards/bs_card.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../domain/entities/post.dart';
import '../blocs/post_bloc.dart';
import 'post_card_like_animation.dart';

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
  Widget build(BuildContext context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final currentUserId =
              authState is Authenticated ? authState.user.uid : null;
          final isLiked = widget.post.likes.contains(currentUserId);

          return BSCard(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: BorderRadius.circular(UiConstants.borderRadiusLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostHeaderWidget(
                  post: widget.post,
                  currentUserId: currentUserId,
                  onDeletePressed: () => _showDeleteDialog(context),
                ),
                _PostImageWidget(
                  postUrl: widget.post.postUrl,
                  onDoubleTap: () {
                    if (currentUserId != null) {
                      HapticFeedback.mediumImpact();
                      _likePost(context, currentUserId);
                      _likeAnimationController.forward();
                    }
                  },
                  likeAnimationController: _likeAnimationController,
                  likeAnimation: _likeAnimation,
                ),
                _PostActionsWidget(
                  post: widget.post, // Pass the post object
                  isLiked: isLiked,
                  onLikePressed: currentUserId != null
                      ? () => _likePost(context, currentUserId)
                      : null,
                  onCommentPressed: () => _navigateToComments(context),
                ),
                _PostEngagementWidget(
                  post: widget.post,
                ),
              ],
            ),
          );
        },
      );

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
          BSButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
            type: BSButtonType.text,
          ),
          BSButton(
            label: 'Delete',
            onPressed: () {
              context.read<PostBloc>().add(DeletePostEvent(
                    postId: widget.post.postId,
                  ));
              Navigator.of(context).pop();
            },
            type: BSButtonType.text,
          ),
        ],
      ),
    );
  }
}

// --- Separated Widgets ---

class _PostHeaderWidget extends StatelessWidget {
  const _PostHeaderWidget({
    required this.post,
    required this.currentUserId,
    required this.onDeletePressed,
  });

  final Post post;
  final String? currentUserId;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: UiConstants.paddingH16V8,
      child: Row(
        children: [
          BSAvatar(
            imageUrl: post.profImage,
          ),
          UiConstants.kWidth12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(post.datePublished),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (post.uid == currentUserId)
            IconButton(
              onPressed: onDeletePressed,
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
    );
  }
}

class _PostImageWidget extends StatelessWidget {
  const _PostImageWidget({
    required this.postUrl,
    required this.onDoubleTap,
    required this.likeAnimationController,
    required this.likeAnimation,
  });

  final String postUrl;
  final VoidCallback onDoubleTap;
  final AnimationController likeAnimationController;
  final Animation<double> likeAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            child: RepaintBoundary(
              child: Image.network(
                postUrl,
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
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
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
          PostLikeAnimation(
            animation: likeAnimation,
            opacity: likeAnimationController.value,
          ),
        ],
      ),
    );
  }
}

class _PostActionsWidget extends StatelessWidget {
  const _PostActionsWidget({
    required this.post, // Add post field
    required this.isLiked,
    required this.onLikePressed,
    required this.onCommentPressed,
  });

  final Post post; // Declare post field
  final bool isLiked;
  final VoidCallback? onLikePressed;
  final VoidCallback onCommentPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: UiConstants.paddingH8,
        child: Row(
          children: [
            IconButton(
              onPressed: onLikePressed,
              style: DesignSystem.iconButton(context),
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? AppColors.accentPink : null,
                size: 28,
              ),
            ),
            IconButton(
              onPressed: onCommentPressed,
              style: DesignSystem.iconButton(context),
              icon: const Icon(
                Icons.chat_bubble_outline,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                final String postDescription = post.description;
                final String postUser = post.username;
                final String postImageURL = post.postUrl;

                String shareText =
                    'Check out this post by $postUser: "$postDescription"';
                if (postImageURL.isNotEmpty) {
                  // Assuming postUrl is a direct link to the image/content.
                  // For a real app, this might be a deep link to the post within the app.
                  shareText += '\nSee it here: $postImageURL';
                }
                Share.share(shareText);
              },
              style: DesignSystem.iconButton(context),
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
              style: DesignSystem.iconButton(context),
              icon: const Icon(
                Icons.bookmark_border,
                size: 24,
              ),
            ),
          ],
        ),
      );
}

class _PostEngagementWidget extends StatelessWidget {
  const _PostEngagementWidget({
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: UiConstants.paddingH16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${post.likes.length} likes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
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
                  text: post.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(text: post.description),
              ],
            ),
          ),
          UiConstants.kHeight16,
        ],
      ),
    );
  }
}
