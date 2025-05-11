import 'package:flutter/material.dart';
import 'ui_constants.dart';

/// Animation utilities for the app
class AnimationUtils {
  // Private constructor to prevent instantiation
  AnimationUtils._();

  /// Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeIn,
    double begin = 0.0,
    double end = 1.0,
    bool animate = true,
  }) {
    if (!animate) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: child,
      ),
      child: child,
    );
  }

  /// Slide animation
  static Widget slide({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    Offset begin = const Offset(0, 0.2),
    Offset end = Offset.zero,
    bool animate = true,
  }) {
    if (!animate) {
      return child;
    }

    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(value.dx * 100, value.dy * 100),
        child: child,
      ),
      child: child,
    );
  }

  /// Scale animation
  static Widget scale({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
    double begin = 0.8,
    double end = 1.0,
    bool animate = true,
  }) {
    if (!animate) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: child,
    );
  }

  /// Fade and slide animation (combined)
  static Widget fadeSlide({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
    Offset beginOffset = const Offset(0, 0.2),
    Offset endOffset = Offset.zero,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
    bool animate = true,
  }) {
    if (!animate) {
      return child;
    }

    return fadeIn(
      duration: duration,
      curve: curve,
      begin: beginOpacity,
      end: endOpacity,
      child: slide(
        duration: duration,
        curve: curve,
        begin: beginOffset,
        end: endOffset,
        child: child,
      ),
    );
  }

  /// Staggered list animation
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration initialDelay = Duration.zero,
    Duration staggerDuration = const Duration(milliseconds: 50),
    Duration animationDuration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOut,
    bool animate = true,
  }) {
    if (!animate) {
      return children;
    }

    return List.generate(children.length, (index) {
      final delay = initialDelay + (staggerDuration * index);

      return AnimatedBuilder(
        animation: const AlwaysStoppedAnimation(0),
        builder: (context, child) => FutureBuilder(
          future: Future.delayed(delay),
          builder: (context, snapshot) {
            final isDelayComplete =
                snapshot.connectionState == ConnectionState.done;

            return fadeSlide(
              duration: animationDuration,
              curve: curve,
              animate: isDelayComplete,
              child: children[index],
            );
          },
        ),
      );
    });
  }

  /// Pulse animation
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.97,
    double maxScale = 1.03,
    bool repeat = true,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: minScale, end: maxScale),
        duration: duration,
        curve: UiConstants.animCurveSmooth,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: child,
        ),
        onEnd: repeat ? () {} : null,
        child: child,
      );

  /// Shimmer loading effect
  static Widget shimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
  }) =>
      ShimmerEffect(
        duration: duration,
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: child,
      );

  /// Bounce animation
  static Widget bounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double height = 20.0,
    bool repeat = true,
  }) =>
      BounceEffect(
        duration: duration,
        height: height,
        repeat: repeat,
        child: child,
      );

  /// Shake animation
  static Widget shake({
    required Widget child,
    Duration duration = const Duration(milliseconds: 700),
    double offset = 10.0,
    bool repeat = false,
  }) =>
      ShakeEffect(
        duration: duration,
        offset: offset,
        repeat: repeat,
        child: child,
      );
}

/// Shimmer effect widget
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({
    required this.child,
    required this.duration,
    required this.baseColor,
    required this.highlightColor,
    super.key,
  });
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              widget.baseColor,
              widget.highlightColor,
              widget.baseColor,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value, 0),
          ).createShader(bounds),
          child: widget.child,
        ),
      );
}

/// Page transition animations
class PageTransitions {
  // Private constructor to prevent instantiation
  PageTransitions._();

  /// Fade transition
  static PageRouteBuilder<T> fade<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) =>
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: duration,
      );

  /// Slide transition
  static PageRouteBuilder<T> slide<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    SlideDirection direction = SlideDirection.right,
  }) {
    Offset begin;

    switch (direction) {
      case SlideDirection.right:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.left:
        begin = const Offset(-1, 0);
        break;
      case SlideDirection.up:
        begin = const Offset(0, 1);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -1);
        break;
    }

    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      ),
      transitionDuration: duration,
    );
  }
}

/// Bounce effect widget
class BounceEffect extends StatefulWidget {
  const BounceEffect({
    required this.child,
    required this.duration,
    required this.height,
    required this.repeat,
    super.key,
  });
  final Widget child;
  final Duration duration;
  final double height;
  final bool repeat;

  @override
  State<BounceEffect> createState() => _BounceEffectState();
}

class _BounceEffectState extends State<BounceEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -widget.height * _animation.value),
          child: widget.child,
        ),
      );
}

/// Shake effect widget
class ShakeEffect extends StatefulWidget {
  const ShakeEffect({
    required this.child,
    required this.duration,
    required this.offset,
    required this.repeat,
    super.key,
  });
  final Widget child;
  final Duration duration;
  final double offset;
  final bool repeat;

  @override
  State<ShakeEffect> createState() => _ShakeEffectState();
}

class _ShakeEffectState extends State<ShakeEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn,
      ),
    );

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(widget.offset * _animation.value, 0),
          child: widget.child,
        ),
      );
}

/// Slide direction enum
enum SlideDirection {
  right,
  left,
  up,
  down,
}
