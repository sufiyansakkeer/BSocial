import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/ui_constants.dart';

/// Swipeable list item with actions
class SwipeableItem extends StatefulWidget {
  const SwipeableItem({
    required this.child,
    super.key,
    this.leftActions = const [],
    this.rightActions = const [],
    this.actionThreshold = 0.3,
    this.actionWidth = 80.0,
    this.confirmDismiss = false,
    this.confirmDismissTitle,
    this.confirmDismissContent,
    this.confirmDismissConfirmText,
    this.confirmDismissCancelText,
    this.onDismissed,
    this.enableHapticFeedback = true,
  });
  final Widget child;
  final List<SwipeAction> leftActions;
  final List<SwipeAction> rightActions;
  final double actionThreshold;
  final double actionWidth;
  final bool confirmDismiss;
  final String? confirmDismissTitle;
  final String? confirmDismissContent;
  final String? confirmDismissConfirmText;
  final String? confirmDismissCancelText;
  final VoidCallback? onDismissed;
  final bool enableHapticFeedback;

  @override
  State<SwipeableItem> createState() => _SwipeableItemState();
}

class _SwipeableItemState extends State<SwipeableItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragExtent = 0;
  bool _dragUnderway = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: UiConstants.animMedium,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasLeftActions => widget.leftActions.isNotEmpty;
  bool get _hasRightActions => widget.rightActions.isNotEmpty;

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragUnderway) {
      return;
    }

    final delta = details.primaryDelta ?? 0;
    _dragExtent += delta;

    // Limit drag based on available actions
    if ((_dragExtent > 0 && !_hasLeftActions) ||
        (_dragExtent < 0 && !_hasRightActions)) {
      _dragExtent = 0;
    }

    // Calculate max drag extent based on number of actions
    final maxLeftExtent = widget.leftActions.length * widget.actionWidth;
    final maxRightExtent = widget.rightActions.length * widget.actionWidth;

    // Limit drag extent
    if (_dragExtent > 0) {
      _dragExtent = _dragExtent.clamp(0.0, maxLeftExtent);
    } else {
      _dragExtent = _dragExtent.clamp(-maxRightExtent, 0.0);
    }

    // Update animation
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(_dragExtent / context.size!.width, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.value = 1.0;

    // Provide haptic feedback at threshold
    if (widget.enableHapticFeedback) {
      if (_dragExtent.abs() > context.size!.width * widget.actionThreshold) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    if (!_dragUnderway) {
      return;
    }

    _dragUnderway = false;

    // Check if drag exceeds threshold
    final screenWidth = context.size!.width;
    final dragRatio = _dragExtent / screenWidth;

    if (dragRatio.abs() > widget.actionThreshold) {
      // Determine which action to trigger
      if (_dragExtent > 0) {
        // Left actions (swipe right)
        final actionIndex = (_dragExtent / widget.actionWidth)
            .floor()
            .clamp(0, widget.leftActions.length - 1);
        final action = widget.leftActions[actionIndex];

        // Check if confirmation is needed
        if (widget.confirmDismiss && action.isDestructive) {
          final confirmed = await _showConfirmationDialog();
          if (confirmed != true) {
            _resetPosition();
            return;
          }
        }

        // Execute action
        action.onTap();

        // Handle dismissal
        if (action.dismissible && widget.onDismissed != null) {
          widget.onDismissed!();
        } else {
          _resetPosition();
        }
      } else {
        // Right actions (swipe left)
        final actionIndex = (_dragExtent.abs() / widget.actionWidth)
            .floor()
            .clamp(0, widget.rightActions.length - 1);
        final action = widget.rightActions[actionIndex];

        // Check if confirmation is needed
        if (widget.confirmDismiss && action.isDestructive) {
          final confirmed = await _showConfirmationDialog();
          if (confirmed != true) {
            _resetPosition();
            return;
          }
        }

        // Execute action
        action.onTap();

        // Handle dismissal
        if (action.dismissible && widget.onDismissed != null) {
          widget.onDismissed!();
        } else {
          _resetPosition();
        }
      }
    } else {
      _resetPosition();
    }
  }

  void _resetPosition() {
    _animation = Tween<Offset>(
      begin: Offset(_dragExtent / context.size!.width, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller
      ..reset()
      ..forward();
    _dragExtent = 0.0;
  }

  Future<bool?> _showConfirmationDialog() => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.confirmDismissTitle ?? 'Confirm'),
          content: Text(widget.confirmDismissContent ??
              'Are you sure you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(widget.confirmDismissCancelText ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                widget.confirmDismissConfirmText ?? 'Confirm',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Build action buttons
    final leftActionWidgets = widget.leftActions.asMap().entries.map((entry) {
      final index = entry.key;
      final action = entry.value;
      final isVisible = _dragExtent > index * widget.actionWidth;

      return Positioned(
        left: index * widget.actionWidth,
        top: 0,
        bottom: 0,
        width: widget.actionWidth,
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: UiConstants.animFast,
          child: _buildActionButton(action),
        ),
      );
    }).toList();

    final rightActionWidgets = widget.rightActions.asMap().entries.map((entry) {
      final index = entry.key;
      final action = entry.value;
      final isVisible = _dragExtent < -(index * widget.actionWidth);

      return Positioned(
        right: index * widget.actionWidth,
        top: 0,
        bottom: 0,
        width: widget.actionWidth,
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: UiConstants.animFast,
          child: _buildActionButton(action),
        ),
      );
    }).toList();

    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background with action buttons
          if (_hasLeftActions || _hasRightActions)
            Positioned.fill(
              child: Stack(
                children: [
                  // Left actions
                  ...leftActionWidgets,

                  // Right actions
                  ...rightActionWidgets,
                ],
              ),
            ),

          // Foreground content
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_dragExtent, 0),
              child: child,
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(SwipeAction action) => Container(
        color: action.backgroundColor,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action.icon,
              color: action.iconColor ?? Colors.white,
            ),
            if (action.label != null) ...[
              const SizedBox(height: 4),
              Text(
                action.label!,
                style: TextStyle(
                  color: action.iconColor ?? Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
}

/// Swipe action configuration
class SwipeAction {
  const SwipeAction({
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    this.label,
    this.iconColor,
    this.isDestructive = false,
    this.dismissible = false,
  });
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color? iconColor;
  final bool isDestructive;
  final bool dismissible;
}
