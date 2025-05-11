import 'package:flutter/material.dart';

import '../../../../core/utils/animation_utils.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';
import '../../../../core/widgets/cards/bs_card.dart';

/// A skeleton loader for post cards
class PostSkeletonLoader extends StatelessWidget {
  /// Constructor
  const PostSkeletonLoader({
    super.key,
    this.itemCount = 3,
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
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        return BSAnimatedContainer(
          animationType: BSAnimationType.fadeSlide,
          slideDirection: BSSlideDirection.fromBottom,
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: 80 * index),
          child: BSCard(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: BorderRadius.circular(UiConstants.borderRadiusLarge),
            child: AnimationUtils.shimmer(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post header
                  Padding(
                    padding: UiConstants.paddingH16V8,
                    child: Row(
                      children: [
                        // Avatar placeholder
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: baseColor,
                        ),
                        const SizedBox(width: 12),
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
                              const SizedBox(height: 4),
                              // Date placeholder
                              Container(
                                height: 12,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: baseColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Menu icon placeholder
                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Post image placeholder
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: double.infinity,
                    color: baseColor,
                  ),

                  // Post actions
                  Padding(
                    padding: UiConstants.paddingAll16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left actions
                        Row(
                          children: [
                            // Like button placeholder
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Comment button placeholder
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Share button placeholder
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        // Bookmark button placeholder
                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Likes count placeholder
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Caption placeholder
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
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
