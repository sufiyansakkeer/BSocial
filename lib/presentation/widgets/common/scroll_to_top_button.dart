import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A button that appears when the user scrolls down and allows them to scroll
/// back to the top
class ScrollToTopButton extends StatefulWidget {
  const ScrollToTopButton({
    required this.scrollController,
    super.key,
    this.showThreshold = 300.0,
    this.backgroundColor,
    this.iconColor,
    this.size = 44.0,
    this.iconSize = 24.0,
  });
  final ScrollController scrollController;
  final double showThreshold;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton>
    with SingleTickerProviderStateMixin {
  bool _showButton = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with a short duration
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Create fade animation
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Add listener to scroll controller
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    _animationController.dispose();
    super.dispose();
  }

  // Listen to scroll events and show/hide button accordingly
  void _scrollListener() {
    // Use a simple check to avoid unnecessary setState calls
    final shouldShowButton =
        widget.scrollController.offset >= widget.showThreshold;

    if (shouldShowButton != _showButton) {
      setState(() {
        _showButton = shouldShowButton;
      });

      if (_showButton) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  // Scroll to top with animation
  void _scrollToTop() {
    HapticFeedback.lightImpact();
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Don't build anything if button shouldn't be shown
    if (!_showButton && _animationController.isDismissed) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Positioned(
      right: 16,
      bottom: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 4,
          shadowColor: Colors.black26,
          shape: const CircleBorder(),
          color: widget.backgroundColor ?? theme.colorScheme.primary,
          child: InkWell(
            onTap: _scrollToTop,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Center(
                child: Icon(
                  Icons.arrow_upward,
                  color: widget.iconColor ?? Colors.white,
                  size: widget.iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
