import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_constants.dart';
import '../../../domain/entities/post.dart';
import '../../pages/post/comments_page.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/post/post_provider.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final isLiked = post.likes.contains(currentUser?.uid);

    return Container(
      color: AppColors.mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(post.profImage),
                ),
                UiConstants.kWidth,
                Expanded(
                  child: Text(
                    post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (post.uid == currentUser?.uid)
                  IconButton(
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.more_vert),
                  ),
              ],
            ),
          ),

          // Post Image
          GestureDetector(
            onDoubleTap: () => _likePost(context),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: Image.network(
                post.postUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Post Actions
          Row(
            children: [
              IconButton(
                onPressed: () => _likePost(context),
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                ),
              ),
              IconButton(
                onPressed: () => _navigateToComments(context),
                icon: const Icon(Icons.comment_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border),
              ),
            ],
          ),

          // Like Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.likes.length} likes',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                UiConstants.kHeight,
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
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
                UiConstants.kHeight,
                Text(
                  DateFormat.yMMMd().format(post.datePublished),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
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

    if (post.likes.contains(currentUserId)) {
      postProvider.unlikePost(post.postId, currentUserId);
    } else {
      postProvider.likePost(post.postId, currentUserId);
    }
  }

  void _navigateToComments(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.setSelectedPost(post);

    // Navigate to comments screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentsPage(postId: post.postId),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.mobileBackgroundColor,
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
              postProvider.deletePost(post.postId);
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
