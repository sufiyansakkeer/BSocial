import 'package:flutter/material.dart';

import '../../../../core/utils/animation_utils.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';

/// A skeleton loader for chat messages
class ChatMessageSkeletonLoader extends StatelessWidget {
  /// Constructor
  const ChatMessageSkeletonLoader({
    super.key,
    this.itemCount = 10,
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
      reverse: true, // To show latest messages at the bottom
      itemBuilder: (context, index) {
        // Alternate between left and right alignment for messages
        final isRight = index % 2 == 0;

        return BSAnimatedContainer(
          animationType: BSAnimationType.fadeSlide,
          slideDirection: isRight
              ? BSSlideDirection.fromRight
              : BSSlideDirection.fromLeft,
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: 50 * index),
          child: AnimationUtils.shimmer(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Align(
              alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(
                  left: isRight ? 64 : 16,
                  right: isRight ? 16 : 64,
                  top: 4,
                  bottom: 4,
                ),
                padding: UiConstants.paddingH16V8,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius:
                      BorderRadius.circular(UiConstants.borderRadiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message content placeholder
                    Container(
                      height: 16,
                      width: 150 + (index % 3) * 30, // Vary the width
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Time and status placeholder
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 10,
                          width: 40,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        if (isRight) ...[
                          const SizedBox(width: 4),
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: baseColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
