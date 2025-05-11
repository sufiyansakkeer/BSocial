import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A widget that displays a heart animation when a post is liked
class PostLikeAnimation extends StatelessWidget {
  /// Creates a post like animation
  const PostLikeAnimation({
    required this.animation,
    required this.opacity,
    super.key,
  });

  /// The animation controller for the scale animation
  final Animation<double> animation;

  /// The opacity value for the animation
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          Icons.favorite,
          color: AppColors.accentPink,
          size: 100,
        ),
      ),
    );
  }
}
