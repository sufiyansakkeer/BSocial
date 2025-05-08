import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_constants.dart';
import '../../../domain/entities/post.dart';
import '../../pages/post/comments_page.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/post/post_provider.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

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
      begin: 1.0,
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
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final isLiked = widget.post.likes.contains(currentUser?.uid);
    final theme = Theme.of(context);

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
                        DateFormat.yMMMd().format(widget.post.datePublished),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withAlpha(150),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.post.uid == currentUser?.uid)
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
              HapticFeedback.mediumImpact();
              _likePost(context);
              _likeAnimationController.forward();
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
                              strokeWidth: 3.0,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: theme.colorScheme.surface,
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Like animation overlay
                AnimatedBuilder(
                  animation: _likeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _likeAnimationController.value,
                      child: Transform.scale(
                        scale: _likeAnimation.value,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    );
                  },
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
                  onPressed: () => _likePost(context),
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
  }

  void _likePost(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid;

    if (currentUserId == null) return;

    if (widget.post.likes.contains(currentUserId)) {
      postProvider.unlikePost(widget.post.postId, currentUserId);
    } else {
      postProvider.likePost(widget.post.postId, currentUserId);
    }
  }

  void _navigateToComments(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.setSelectedPost(widget.post);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentsPage(postId: widget.post.postId),
      ),
    );
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
              final postProvider =
                  Provider.of<PostProvider>(context, listen: false);
              postProvider.deletePost(widget.post.postId);
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
