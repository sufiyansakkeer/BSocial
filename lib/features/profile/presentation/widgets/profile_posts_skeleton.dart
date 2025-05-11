import 'package:flutter/material.dart';

import '../../../../core/utils/animation_utils.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';

/// A skeleton loader for profile posts grid
class ProfilePostsSkeleton extends StatelessWidget {
  /// Constructor
  const ProfilePostsSkeleton({
    super.key,
    this.itemCount = 9,
    this.crossAxisCount = 3,
    this.spacing = 2.0,
  });

  /// Number of skeleton items to show
  final int itemCount;

  /// Number of items in the cross axis
  final int crossAxisCount;

  /// Spacing between items
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return BSAnimatedContainer(
          animationType: BSAnimationType.fadeScale,
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: 40 * index),
          child: AnimationUtils.shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              color: baseColor,
            ),
          ),
        );
      },
    );
  }
}
