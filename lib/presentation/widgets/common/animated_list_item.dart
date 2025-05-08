import 'package:flutter/material.dart';

/// Animation types for list items
enum AnimationItemType {
  fadeIn,
  slideIn,
  scaleIn,
  fadeSlideIn,
  fadeScaleIn,
  slideScaleIn,
  fadeSlideScaleIn,
}

/// Direction for slide animations
enum SlideDirection {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
}

/// Animated list item widget
class AnimatedListItem extends StatefulWidget {
  const AnimatedListItem({
    required this.child,
    required this.index,
    required this.itemCount,
    super.key,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutQuad,
    this.animationType = AnimationItemType.fadeSlideIn,
    this.slideDirection = SlideDirection.fromBottom,
    this.slideDistance = 50.0,
    this.initialScale = 0.8,
    this.initialOpacity = 0.0,
    this.animate = true,
  });
  final Widget child;
  final int index;
  final int itemCount;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final AnimationItemType animationType;
  final SlideDirection slideDirection;
  final double slideDistance;
  final double initialScale;
  final double initialOpacity;
  final bool animate;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Calculate staggered delay
    final staggeredDelay =
        widget.delay + Duration(milliseconds: widget.index * 50);

    // Initialize animations
    _initializeAnimations();

    // Start animation after delay
    if (widget.animate) {
      Future.delayed(staggeredDelay, () {
        if (!_isDisposed) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  void _initializeAnimations() {
    // Opacity animation
    _opacityAnimation = Tween<double>(
      begin: _needsOpacityAnimation() ? widget.initialOpacity : 1.0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: _needsScaleAnimation() ? widget.initialScale : 1.0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: _needsSlideAnimation() ? _getInitialSlideOffset() : Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
  }

  bool _needsOpacityAnimation() =>
      widget.animationType == AnimationItemType.fadeIn ||
      widget.animationType == AnimationItemType.fadeSlideIn ||
      widget.animationType == AnimationItemType.fadeScaleIn ||
      widget.animationType == AnimationItemType.fadeSlideScaleIn;

  bool _needsScaleAnimation() =>
      widget.animationType == AnimationItemType.scaleIn ||
      widget.animationType == AnimationItemType.fadeScaleIn ||
      widget.animationType == AnimationItemType.slideScaleIn ||
      widget.animationType == AnimationItemType.fadeSlideScaleIn;

  bool _needsSlideAnimation() =>
      widget.animationType == AnimationItemType.slideIn ||
      widget.animationType == AnimationItemType.fadeSlideIn ||
      widget.animationType == AnimationItemType.slideScaleIn ||
      widget.animationType == AnimationItemType.fadeSlideScaleIn;

  Offset _getInitialSlideOffset() {
    switch (widget.slideDirection) {
      case SlideDirection.fromTop:
        return Offset(0, -widget.slideDistance / 100);
      case SlideDirection.fromBottom:
        return Offset(0, widget.slideDistance / 100);
      case SlideDirection.fromLeft:
        return Offset(-widget.slideDistance / 100, 0);
      case SlideDirection.fromRight:
        return Offset(widget.slideDistance / 100, 0);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * 100,
              _slideAnimation.value.dy * 100,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        ),
        child: widget.child,
      );
}

/// Animated list widget that applies animations to all children
class AnimatedListView extends StatelessWidget {
  const AnimatedListView({
    required this.children,
    super.key,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.primary,
    this.animationType = AnimationItemType.fadeSlideIn,
    this.slideDirection = SlideDirection.fromBottom,
    this.itemDuration = const Duration(milliseconds: 400),
    this.initialDelay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutQuad,
    this.animate = true,
  });
  final List<Widget> children;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool? primary;
  final AnimationItemType animationType;
  final SlideDirection slideDirection;
  final Duration itemDuration;
  final Duration initialDelay;
  final Curve curve;
  final bool animate;

  @override
  Widget build(BuildContext context) => ListView.builder(
        controller: controller,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        primary: primary,
        itemCount: children.length,
        itemBuilder: (context, index) => AnimatedListItem(
          index: index,
          itemCount: children.length,
          animationType: animationType,
          slideDirection: slideDirection,
          duration: itemDuration,
          delay: initialDelay,
          curve: curve,
          animate: animate,
          child: children[index],
        ),
      );
}

/// Animated grid widget that applies animations to all children
class AnimatedGridView extends StatelessWidget {
  const AnimatedGridView({
    required this.children,
    required this.gridDelegate,
    super.key,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.primary,
    this.animationType = AnimationItemType.fadeScaleIn,
    this.slideDirection = SlideDirection.fromBottom,
    this.itemDuration = const Duration(milliseconds: 400),
    this.initialDelay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutQuad,
    this.animate = true,
  });
  final List<Widget> children;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool? primary;
  final SliverGridDelegate gridDelegate;
  final AnimationItemType animationType;
  final SlideDirection slideDirection;
  final Duration itemDuration;
  final Duration initialDelay;
  final Curve curve;
  final bool animate;

  @override
  Widget build(BuildContext context) => GridView.builder(
        controller: controller,
        shrinkWrap: shrinkWrap,
        physics: physics,
        padding: padding,
        primary: primary,
        gridDelegate: gridDelegate,
        itemCount: children.length,
        itemBuilder: (context, index) => AnimatedListItem(
          index: index,
          itemCount: children.length,
          animationType: animationType,
          slideDirection: slideDirection,
          duration: itemDuration,
          delay: initialDelay,
          curve: curve,
          animate: animate,
          child: children[index],
        ),
      );
}
