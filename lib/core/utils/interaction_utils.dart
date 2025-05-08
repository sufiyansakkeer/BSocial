import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ui_constants.dart';

/// Utility class for micro-interactions throughout the app
class InteractionUtils {
  /// Apply a ripple effect to any widget
  static Widget addRipple({
    required Widget child,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
    bool enableFeedback = true,
    bool enableHaptics = true,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (enableHaptics) {
              HapticFeedback.lightImpact();
            }
            onTap();
          },
          borderRadius: borderRadius,
          splashColor: splashColor,
          highlightColor: highlightColor,
          enableFeedback: enableFeedback,
          child: child,
        ),
      );

  /// Add a bounce effect to any widget
  static Widget addBounce({
    required Widget child,
    required VoidCallback onTap,
    Duration duration = const Duration(milliseconds: 150),
    double scale = 0.95,
    bool enableHaptics = true,
  }) =>
      BounceInteraction(
        onTap: onTap,
        duration: duration,
        scale: scale,
        enableHaptics: enableHaptics,
        child: child,
      );

  /// Add a pulse effect to any widget
  static Widget addPulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    double minScale = 0.97,
    double maxScale = 1.03,
  }) =>
      PulseInteraction(
        duration: duration,
        minScale: minScale,
        maxScale: maxScale,
        child: child,
      );

  /// Show a custom toast message
  static void showToast(
    BuildContext context, {
    required String message,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
    ToastType type = ToastType.info,
  }) {
    // Remove any existing toast
    _removeToast();

    // Create overlay entry
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => ToastOverlay(
        message: message,
        icon: icon,
        duration: duration,
        type: type,
      ),
    );

    // Insert the overlay
    overlayState.insert(_overlayEntry!);

    // Remove after duration
    Future.delayed(duration, _removeToast);
  }

  /// Remove the current toast
  static void _removeToast() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Overlay entry for toast
  static OverlayEntry? _overlayEntry;
}

/// Toast type enum
enum ToastType {
  info,
  success,
  warning,
  error,
}

/// Toast overlay widget
class ToastOverlay extends StatefulWidget {
  const ToastOverlay({
    required this.message,
    required this.duration,
    required this.type,
    super.key,
    this.icon,
  });
  final String message;
  final IconData? icon;
  final Duration duration;
  final ToastType type;

  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Start reverse animation before the toast is removed
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get colors based on type
    final Color backgroundColor;
    final Color iconColor;
    final IconData iconData;

    switch (widget.type) {
      case ToastType.success:
        backgroundColor = Colors.green.shade700;
        iconColor = Colors.white;
        iconData = widget.icon ?? Icons.check_circle;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange.shade700;
        iconColor = Colors.white;
        iconData = widget.icon ?? Icons.warning_amber;
        break;
      case ToastType.error:
        backgroundColor = Colors.red.shade700;
        iconColor = Colors.white;
        iconData = widget.icon ?? Icons.error;
        break;
      case ToastType.info:
      default:
        backgroundColor = Theme.of(context).colorScheme.primary;
        iconColor = Colors.white;
        iconData = widget.icon ?? Icons.info;
        break;
    }

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Material(
                elevation: 6,
                borderRadius:
                    BorderRadius.circular(UiConstants.borderRadiusMedium),
                color: backgroundColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconData,
                        color: iconColor,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bounce interaction widget
class BounceInteraction extends StatefulWidget {
  const BounceInteraction({
    required this.child,
    required this.onTap,
    super.key,
    this.duration = const Duration(milliseconds: 150),
    this.scale = 0.95,
    this.enableHaptics = true,
  });
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  final double scale;
  final bool enableHaptics;

  @override
  State<BounceInteraction> createState() => _BounceInteractionState();
}

class _BounceInteractionState extends State<BounceInteraction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: widget.scale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isPressed) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse().then((_) {
        widget.onTap();
      });
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: widget.child,
        ),
      );
}

/// Pulse interaction widget
class PulseInteraction extends StatefulWidget {
  const PulseInteraction({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.97,
    this.maxScale = 1.03,
  });
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  @override
  State<PulseInteraction> createState() => _PulseInteractionState();
}

class _PulseInteractionState extends State<PulseInteraction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      );
}
