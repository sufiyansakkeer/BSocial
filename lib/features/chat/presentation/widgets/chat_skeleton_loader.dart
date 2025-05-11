import 'package:flutter/material.dart';

import '../../../../core/utils/animation_utils.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';

/// A skeleton loader for chat list
class ChatSkeletonLoader extends StatelessWidget {
  /// Constructor
  const ChatSkeletonLoader({
    super.key,
    this.itemCount = 8,
  });

  /// Number of skeleton items to show
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return ListView.builder(
      itemCount: itemCount,
      padding: UiConstants.paddingH16V8,
      itemBuilder: (context, index) {
        return BSAnimatedContainer(
          animationType: BSAnimationType.fadeSlide,
          slideDirection: BSSlideDirection.fromRight,
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: 50 * index),
          child: AnimationUtils.shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  // Avatar placeholder
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: baseColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username placeholder
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Last message placeholder
                        Container(
                          height: 12,
                          width: 200,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time placeholder
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 12,
                        width: 40,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Unread indicator placeholder
                      Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          color: baseColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
