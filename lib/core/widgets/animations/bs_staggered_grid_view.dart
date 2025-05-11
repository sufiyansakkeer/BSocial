import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../utils/ui_constants.dart';
import 'bs_animated_container.dart';

/// A staggered grid view that animates its items when they appear
class BSStaggeredGridView extends StatelessWidget {
  /// Creates a BSocial staggered grid view
  const BSStaggeredGridView({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = 4.0,
    this.crossAxisSpacing = 4.0,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemAnimationType = BSAnimationType.fadeScale,
    this.slideDirection = BSSlideDirection.fromBottom,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDuration = const Duration(milliseconds: 30),
    this.initialDelay = const Duration(),
    this.curve = Curves.easeOut,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  /// The number of items in the grid
  final int itemCount;

  /// Builder for grid items
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// The number of children in the cross axis
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis
  final double crossAxisSpacing;

  /// The axis along which the grid view scrolls
  final Axis scrollDirection;

  /// Whether the grid view scrolls in the reading direction
  final bool reverse;

  /// An object that can be used to control the position to which this grid view is scrolled
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  final bool? primary;

  /// How the grid view should respond to user input
  final ScrollPhysics? physics;

  /// Whether the extent of the grid view in the scrollDirection should be determined by the contents being viewed
  final bool shrinkWrap;

  /// The amount of space by which to inset the grid view
  final EdgeInsetsGeometry? padding;

  /// The type of animation to apply to each item
  final BSAnimationType itemAnimationType;

  /// The direction of the slide animation
  final BSSlideDirection slideDirection;

  /// The duration of each item's animation
  final Duration itemDuration;

  /// The duration between each item's animation
  final Duration staggerDuration;

  /// The initial delay before starting the first animation
  final Duration initialDelay;

  /// The curve of the animation
  final Curve curve;

  /// Whether to wrap each child in an [AutomaticKeepAlive]
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary]
  final bool addRepaintBoundaries;

  /// Whether to wrap each child in an [IndexedSemantics]
  final bool addSemanticIndexes;

  /// The number of children that will contribute semantic information
  final double? cacheExtent;

  /// Determines the way that drag start behavior is handled
  final DragStartBehavior dragStartBehavior;

  /// Determines how the [ScrollView] will dismiss the keyboard automatically
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Restoration ID to save and restore the scroll offset of the grid view
  final String? restorationId;

  /// How to clip the grid view's contents
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) => MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final delay = initialDelay + (staggerDuration * index);
          return BSAnimatedContainer(
            animationType: itemAnimationType,
            slideDirection: slideDirection,
            duration: itemDuration,
            delay: delay,
            curve: curve,
            child: itemBuilder(context, index),
          );
        },
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        cacheExtent: cacheExtent,
        dragStartBehavior: dragStartBehavior,
        keyboardDismissBehavior: keyboardDismissBehavior,
        restorationId: restorationId,
        clipBehavior: clipBehavior,
      );
}
