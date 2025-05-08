import 'package:flutter/material.dart';
import '../../../core/utils/ui_constants.dart';

/// Skeleton loading widget for content placeholders
class SkeletonLoading extends StatefulWidget {
  const SkeletonLoading({
    required this.height,
    super.key,
    this.width = double.infinity,
    this.borderRadius,
    this.isCircle = false,
    this.shimmerDuration = const Duration(milliseconds: 1500),
  });
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Duration shimmerDuration;

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.shimmerDuration,
    )..repeat();

    // Reduce animation range to improve performance
    _animation = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircle
              ? null
              : (widget.borderRadius ??
                  BorderRadius.circular(UiConstants.borderRadiusSmall)),
          // Use a simpler gradient configuration to reduce GPU load
          gradient: LinearGradient(
            colors: [
              baseColor,
              highlightColor,
              baseColor,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(_animation.value - 0.5, 0),
            end: Alignment(_animation.value + 0.5, 0),
          ),
        ),
      ),
    );
  }
}

/// Post card skeleton for loading states
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  // Use a single shimmer duration for all skeleton elements to improve performance
  static const shimmerDuration = Duration(milliseconds: 2000);

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusLarge),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: UiConstants.paddingH16V8,
              child: Row(
                children: [
                  // Profile picture
                  const SkeletonLoading(
                    width: 40,
                    height: 40,
                    isCircle: true,
                    shimmerDuration: shimmerDuration,
                  ),
                  UiConstants.kWidth12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        SkeletonLoading(
                          width: 120,
                          height: 16,
                          borderRadius: BorderRadius.circular(
                              UiConstants.borderRadiusSmall),
                          shimmerDuration: shimmerDuration,
                        ),
                        UiConstants.kHeight8,
                        // Date
                        SkeletonLoading(
                          width: 80,
                          height: 12,
                          borderRadius: BorderRadius.circular(
                              UiConstants.borderRadiusSmall),
                          shimmerDuration: shimmerDuration,
                        ),
                      ],
                    ),
                  ),
                  // Menu icon
                  const SkeletonLoading(
                    width: 24,
                    height: 24,
                    isCircle: true,
                    shimmerDuration: shimmerDuration,
                  ),
                ],
              ),
            ),

            // Image - most visible part, so keep the animation
            SkeletonLoading(
              height: MediaQuery.of(context).size.height * 0.3,
              shimmerDuration: shimmerDuration,
            ),

            // Actions
            Padding(
              padding: UiConstants.paddingH8,
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    const SkeletonLoading(
                      width: 24,
                      height: 24,
                      isCircle: true,
                    ),
                    UiConstants.kWidth20,
                  ],
                  const Spacer(),
                  const SkeletonLoading(
                    width: 24,
                    height: 24,
                    isCircle: true,
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: UiConstants.paddingH16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UiConstants.kHeight16,
                  // Likes count
                  SkeletonLoading(
                    width: 80,
                    height: 16,
                    borderRadius:
                        BorderRadius.circular(UiConstants.borderRadiusSmall),
                  ),
                  UiConstants.kHeight8,
                  // Description
                  SkeletonLoading(
                    height: 16,
                    borderRadius:
                        BorderRadius.circular(UiConstants.borderRadiusSmall),
                  ),
                  UiConstants.kHeight8,
                  SkeletonLoading(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 16,
                    borderRadius:
                        BorderRadius.circular(UiConstants.borderRadiusSmall),
                  ),
                  UiConstants.kHeight16,
                ],
              ),
            ),
          ],
        ),
      );
}

/// Profile skeleton for loading states
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Profile header
          Padding(
            padding: UiConstants.paddingAll16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture
                const SkeletonLoading(
                  width: 80,
                  height: 80,
                  isCircle: true,
                ),
                UiConstants.kWidth20,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      SkeletonLoading(
                        width: 150,
                        height: 20,
                        borderRadius: BorderRadius.circular(
                            UiConstants.borderRadiusSmall),
                      ),
                      UiConstants.kHeight12,
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < 3; i++)
                            SkeletonLoading(
                              width: 70,
                              height: 40,
                              borderRadius: BorderRadius.circular(
                                  UiConstants.borderRadiusSmall),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bio
          Padding(
            padding: UiConstants.paddingH16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoading(
                  height: 16,
                  borderRadius:
                      BorderRadius.circular(UiConstants.borderRadiusSmall),
                ),
                UiConstants.kHeight8,
                SkeletonLoading(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 16,
                  borderRadius:
                      BorderRadius.circular(UiConstants.borderRadiusSmall),
                ),
                UiConstants.kHeight20,
              ],
            ),
          ),

          // Buttons
          Padding(
            padding: UiConstants.paddingH16,
            child: Row(
              children: [
                Expanded(
                  child: SkeletonLoading(
                    height: 40,
                    borderRadius:
                        BorderRadius.circular(UiConstants.borderRadiusMedium),
                  ),
                ),
                UiConstants.kWidth12,
                Expanded(
                  child: SkeletonLoading(
                    height: 40,
                    borderRadius:
                        BorderRadius.circular(UiConstants.borderRadiusMedium),
                  ),
                ),
              ],
            ),
          ),

          UiConstants.kHeight20,

          // Posts grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => SkeletonLoading(
              height: MediaQuery.of(context).size.width / 3,
            ),
          ),
        ],
      );
}
