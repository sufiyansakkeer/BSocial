import 'package:flutter/material.dart';

/// Custom scroll physics with enhanced bouncing and friction
class CustomScrollPhysics extends BouncingScrollPhysics {
  const CustomScrollPhysics({super.parent});

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double frictionFactor(double overscrollFraction) =>
      0.8; // Lower friction for smoother scrolling

  @override
  double get dragStartDistanceMotionThreshold =>
      3.5; // More responsive drag start

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80, // Higher mass for more pronounced bouncing
        stiffness: 100, // Lower stiffness for softer bouncing
        damping: 1, // Lower damping for more bouncy effect
      );
}

/// Custom scroll behavior to apply custom scroll physics app-wide
class CustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const CustomScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Use GlowingOverscrollIndicator on all platforms for consistent experience
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color:
          Theme.of(context).colorScheme.primary.withAlpha(76), // 0.3 * 255 = 76
      child: child,
    );
  }
}

/// Scroll to top button widget with animation
class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final double showThreshold;
  final Duration animationDuration;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final EdgeInsetsGeometry padding;

  const ScrollToTopButton({
    super.key,
    required this.scrollController,
    this.showThreshold = 300.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.backgroundColor,
    this.iconColor,
    this.size = 48.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final shouldBeVisible =
        widget.scrollController.offset >= widget.showThreshold;

    if (shouldBeVisible != _isVisible) {
      setState(() {
        _isVisible = shouldBeVisible;
      });

      if (_isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          right: widget.padding.horizontal / 2,
          bottom: widget.padding.vertical / 2,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: _scrollToTop,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51), // 0.2 * 255 = 51
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: widget.iconColor ?? Colors.white,
                    size: widget.size * 0.6,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
