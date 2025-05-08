import 'package:flutter/material.dart';
import '../../../core/utils/ui_constants.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final IconData? icon;
  final ButtonVariant variant;
  final bool animateOnTap;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.animateOnTap = true,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: UiConstants.animFast,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.animateOnTap) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading && widget.animateOnTap) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading && widget.animateOnTap) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine colors based on variant
    Color bgColor;
    Color fgColor;

    switch (widget.variant) {
      case ButtonVariant.filled:
        bgColor = widget.backgroundColor ?? theme.colorScheme.primary;
        fgColor = widget.textColor ?? theme.colorScheme.onPrimary;
        break;
      case ButtonVariant.outlined:
        bgColor = Colors.transparent;
        fgColor = widget.textColor ?? theme.colorScheme.primary;
        break;
      case ButtonVariant.text:
        bgColor = Colors.transparent;
        fgColor = widget.textColor ?? theme.colorScheme.primary;
        break;
      case ButtonVariant.tonal:
        bgColor = widget.backgroundColor ?? theme.colorScheme.primaryContainer;
        fgColor = widget.textColor ?? theme.colorScheme.onPrimaryContainer;
        break;
    }

    // Build button content
    Widget buttonContent = widget.isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: fgColor,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fgColor),
                UiConstants.kWidth8,
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: fgColor,
                ),
              ),
            ],
          );

    // Apply animation if enabled
    if (widget.animateOnTap) {
      buttonContent = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: buttonContent,
      );
    }

    // Build button with appropriate style based on variant
    Widget button;
    switch (widget.variant) {
      case ButtonVariant.filled:
        button = ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            padding: widget.padding ?? UiConstants.paddingH24V16,
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius ??
                  BorderRadius.circular(UiConstants.borderRadiusMedium),
            ),
            elevation: _isPressed ? 0 : UiConstants.elevationSmall,
            disabledBackgroundColor: bgColor.withAlpha((0.6 * 255).round()),
            disabledForegroundColor: fgColor.withAlpha((0.6 * 255).round()),
          ),
          child: buttonContent,
        );
        break;

      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: fgColor,
            padding: widget.padding ?? UiConstants.paddingH24V16,
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius ??
                  BorderRadius.circular(UiConstants.borderRadiusMedium),
            ),
            side: BorderSide(
                color:
                    fgColor.withAlpha(((_isPressed ? 0.5 : 1.0) * 255).round()),
                width: 1.5),
          ),
          child: buttonContent,
        );
        break;

      case ButtonVariant.text:
        button = TextButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: fgColor,
            padding: widget.padding ?? UiConstants.paddingH24V16,
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius ??
                  BorderRadius.circular(UiConstants.borderRadiusMedium),
            ),
          ),
          child: buttonContent,
        );
        break;

      case ButtonVariant.tonal:
        button = ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            padding: widget.padding ?? UiConstants.paddingH24V16,
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius ??
                  BorderRadius.circular(UiConstants.borderRadiusMedium),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: buttonContent,
        );
        break;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: button,
      ),
    );
  }
}

/// Button variants
enum ButtonVariant {
  filled,
  outlined,
  text,
  tonal,
}
