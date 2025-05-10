import 'package:flutter/material.dart';

/// Profile stats widget
class ProfileStats extends StatelessWidget {
  /// Constructor
  const ProfileStats({
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    super.key,
  });

  /// Number of posts
  final int postsCount;

  /// Number of followers
  final int followersCount;

  /// Number of following
  final int followingCount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStat('Posts', postsCount),
            _buildStat('Followers', followersCount),
            _buildStat('Following', followingCount),
          ],
        ),
      );

  Widget _buildStat(String label, int count) => Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      );
}
