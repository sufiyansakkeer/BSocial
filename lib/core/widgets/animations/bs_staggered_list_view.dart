import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../utils/ui_constants.dart';
import 'bs_animated_container.dart';

/// A staggered list view that animates its items when they appear
class BSStaggeredListView extends StatelessWidget {
  /// Creates a BSocial staggered list view
  const BSStaggeredListView({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.itemAnimationType = BSAnimationType.fadeSlide,
    this.slideDirection = BSSlideDirection.fromBottom,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDuration = const Duration(milliseconds: 50),
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
    this.onRefresh,
  });

  /// The number of items in the list
  final int itemCount;

  /// Builder for list items
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// The axis along which the list view scrolls
  final Axis scrollDirection;

  /// Whether the list view scrolls in the reading direction
  final bool reverse;

  /// An object that can be used to control the position to which this list view is scrolled
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  final bool? primary;

  /// How the list view should respond to user input
  final ScrollPhysics? physics;

  /// Whether the extent of the list view in the scrollDirection should be determined by the contents being viewed
  final bool shrinkWrap;

  /// The amount of space by which to inset the list view
  final EdgeInsetsGeometry? padding;

  /// If non-null, forces the children to have the given extent in the scroll direction
  final double? itemExtent;

  /// If non-null, forces the children to have the same extent as the given widget in the scroll direction
  final Widget? prototypeItem;

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

  /// Restoration ID to save and restore the scroll offset of the list view
  final String? restorationId;

  /// How to clip the list view's contents
  final Clip clipBehavior;

  /// A function that's called when the user has dragged the refresh indicator
  /// far enough to demonstrate that they want the app to refresh
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final listView = ListView.builder(
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
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      cacheExtent: cacheExtent,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}
