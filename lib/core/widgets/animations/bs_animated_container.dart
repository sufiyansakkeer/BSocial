import 'package:flutter/material.dart';
import '../../utils/ui_constants.dart';

/// Animation types for BSocial
enum BSAnimationType {
  /// Fade animation
  fade,

  /// Scale animation
  scale,

  /// Slide animation
  slide,

  /// Fade and scale animation
  fadeScale,

  /// Fade and slide animation
  fadeSlide,
}

/// Slide directions for BSocial
enum BSSlideDirection {
  /// Slide from top to bottom
  fromTop,

  /// Slide from bottom to top
  fromBottom,

  /// Slide from left to right
  fromLeft,

  /// Slide from right to left
  fromRight,
}

/// A customizable animated container component for BSocial
class BSAnimatedContainer extends StatefulWidget {
  /// Creates a BSocial animated container
  const BSAnimatedContainer({
    required this.child,
    super.key,
    this.animationType = BSAnimationType.fade,
    this.slideDirection = BSSlideDirection.fromBottom,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
    this.curve = Curves.easeOut,
    this.repeat = false,
    this.reverse = false,
    this.animateOnInit = true,
  });

  /// The child widget to animate
  final Widget child;

  /// The type of animation to apply
  final BSAnimationType animationType;

  /// The direction of the slide animation
  final BSSlideDirection slideDirection;

  /// The duration of the animation
  final Duration duration;

  /// The delay before starting the animation
  final Duration delay;

  /// The curve of the animation
  final Curve curve;

  /// Whether to repeat the animation
  final bool repeat;

  /// Whether to reverse the animation
  final bool reverse;

  /// Whether to animate on initialization
  final bool animateOnInit;

  @override
  State<BSAnimatedContainer> createState() => _BSAnimatedContainerState();
}

class _BSAnimatedContainerState extends State<BSAnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _setupAnimations();

    if (widget.animateOnInit) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
          setState(() {
            _isInitialized = true;
          });
        }
      });
    } else {
      _controller.value = 1.0;
      _isInitialized = true;
    }

    if (widget.repeat) {
      _controller.addStatusListener(_handleRepeat);
    }
  }

  @override
  void didUpdateWidget(BSAnimatedContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.repeat != widget.repeat) {
      if (widget.repeat) {
        _controller.addStatusListener(_handleRepeat);
      } else {
        _controller.removeStatusListener(_handleRepeat);
      }
    }

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.animationType != widget.animationType ||
        oldWidget.slideDirection != widget.slideDirection ||
        oldWidget.curve != widget.curve) {
      _setupAnimations();
    }
  }

  void _setupAnimations() {
    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Slide animation
    final beginOffset = _getSlideBeginOffset();
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
  }

  Offset _getSlideBeginOffset() {
    switch (widget.slideDirection) {
      case BSSlideDirection.fromTop:
        return const Offset(0, -0.2);
      case BSSlideDirection.fromBottom:
        return const Offset(0, 0.2);
      case BSSlideDirection.fromLeft:
        return const Offset(-0.2, 0);
      case BSSlideDirection.fromRight:
        return const Offset(0.2, 0);
    }
  }

  void _handleRepeat(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (widget.reverse) {
        _controller.reverse();
      } else {
        _controller.reset();
        _controller.forward();
      }
    } else if (status == AnimationStatus.dismissed && widget.reverse) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleRepeat)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized && !widget.animateOnInit) {
      return widget.child;
    }

    switch (widget.animationType) {
      case BSAnimationType.fade:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        );
      case BSAnimationType.scale:
        return ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        );
      case BSAnimationType.slide:
        return SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        );
      case BSAnimationType.fadeScale:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        );
      case BSAnimationType.fadeSlide:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
    }
  }
}

/// A staggered list animation component for BSocial
class BSStaggeredList extends StatelessWidget {
  /// Creates a BSocial staggered list
  const BSStaggeredList({
    required this.children,
    super.key,
    this.itemAnimationType = BSAnimationType.fadeSlide,
    this.slideDirection = BSSlideDirection.fromBottom,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDuration = const Duration(milliseconds: 50),
    this.curve = Curves.easeOut,
    this.initialDelay = Duration.zero,
  });

  /// The children to animate
  final List<Widget> children;

  /// The type of animation to apply to each item
  final BSAnimationType itemAnimationType;

  /// The direction of the slide animation
  final BSSlideDirection slideDirection;

  /// The duration of each item's animation
  final Duration itemDuration;

  /// The duration between each item's animation
  final Duration staggerDuration;

  /// The curve of the animation
  final Curve curve;

  /// The initial delay before starting the first animation
  final Duration initialDelay;

  @override
  Widget build(BuildContext context) => Column(
        children: List.generate(
          children.length,
          (index) {
            final delay = initialDelay + (staggerDuration * index);
            return BSAnimatedContainer(
              animationType: itemAnimationType,
              slideDirection: slideDirection,
              duration: itemDuration,
              delay: delay,
              curve: curve,
              child: children[index],
            );
          },
        ),
      );
}
