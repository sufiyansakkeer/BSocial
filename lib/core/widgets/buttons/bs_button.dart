import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../../utils/animation_utils.dart';

/// Button types for BSocial
enum BSButtonType {
  /// Primary button with filled background
  primary,

  /// Secondary button with filled background
  secondary,

  /// Outlined button with border
  outlined,

  /// Text button with no background or border
  text,
}

/// Button sizes for BSocial
enum BSButtonSize {
  /// Small button
  small,

  /// Medium button (default)
  medium,

  /// Large button
  large,
}

/// A customizable button component for BSocial
class BSButton extends StatelessWidget {
  /// Creates a BSocial button
  const BSButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.type = BSButtonType.primary,
    this.size = BSButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
    this.animateOnTap = true,
  });

  /// The text to display on the button
  final String label;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// The type of button to display
  final BSButtonType type;

  /// The size of the button
  final BSButtonSize size;

  /// Optional icon to display
  final IconData? icon;

  /// Position of the icon relative to the label
  final IconPosition iconPosition;

  /// Whether the button is in a loading state
  final bool isLoading;

  /// Whether the button should take up the full width of its container
  final bool isFullWidth;

  /// Whether the button is disabled
  final bool isDisabled;

  /// Whether to animate the button when tapped
  final bool animateOnTap;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;
    final buttonStyle = _getButtonStyle(context);
    final buttonContent = _buildButtonContent(context);
    final buttonWidget =
        _buildButton(context, buttonStyle, buttonContent, effectiveOnPressed);

    return animateOnTap ? _wrapWithAnimation(buttonWidget) : buttonWidget;
  }

  /// Get the appropriate button style based on type
  ButtonStyle _getButtonStyle(BuildContext context) {
    switch (type) {
      case BSButtonType.primary:
        return DesignSystem.primaryButton(context);
      case BSButtonType.secondary:
        return DesignSystem.secondaryButton(context);
      case BSButtonType.outlined:
        return DesignSystem.outlinedButton(context);
      case BSButtonType.text:
        return DesignSystem.textButton(context);
    }
  }

  /// Build the button content with icon and label
  Widget _buildButtonContent(BuildContext context) {
    final textStyle = _getTextStyle(context);
    final spacing = _getSpacing();

    if (isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getLoadingColor(context),
          ),
        ),
      );
    }

    if (icon == null) {
      return Text(label, style: textStyle);
    }

    final iconWidget = Icon(icon, size: _getIconSize());

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == IconPosition.left
          ? [
              iconWidget,
              SizedBox(width: spacing),
              Text(label, style: textStyle),
            ]
          : [
              Text(label, style: textStyle),
              SizedBox(width: spacing),
              iconWidget,
            ],
    );
  }

  /// Build the button with the appropriate widget type
  Widget _buildButton(
    BuildContext context,
    ButtonStyle style,
    Widget content,
    final VoidCallback? effectiveOnPressed,
  ) {
    final buttonWidget = switch (type) {
      BSButtonType.primary || BSButtonType.secondary => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
      BSButtonType.outlined => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
      BSButtonType.text => TextButton(
          onPressed: effectiveOnPressed,
          style: style,
          child: content,
        ),
    };

    return isFullWidth
        ? SizedBox(width: double.infinity, child: buttonWidget)
        : buttonWidget;
  }

  /// Wrap the button with animation if enabled
  Widget _wrapWithAnimation(Widget button) => AnimationUtils.scale(
        child: button,
        begin: 1,
        end: 0.95,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );

  /// Get the appropriate text style based on size
  TextStyle? _getTextStyle(BuildContext context) {
    final baseStyle = switch (type) {
      BSButtonType.primary ||
      BSButtonType.secondary =>
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      BSButtonType.outlined ||
      BSButtonType.text =>
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
    };

    return switch (size) {
      BSButtonSize.small => baseStyle?.copyWith(fontSize: 12),
      BSButtonSize.medium => baseStyle,
      BSButtonSize.large => baseStyle?.copyWith(fontSize: 16),
    };
  }

  /// Get the appropriate spacing between icon and label
  double _getSpacing() => switch (size) {
        BSButtonSize.small => 8,
        BSButtonSize.medium => 12,
        BSButtonSize.large => 16,
      };

  /// Get the appropriate icon size based on button size
  double _getIconSize() => switch (size) {
        BSButtonSize.small => 16,
        BSButtonSize.medium => 20,
        BSButtonSize.large => 24,
      };

  /// Get the appropriate loading indicator color
  Color _getLoadingColor(BuildContext context) => switch (type) {
        BSButtonType.primary || BSButtonType.secondary => Colors.white,
        BSButtonType.outlined ||
        BSButtonType.text =>
          Theme.of(context).colorScheme.primary,
      };
}

/// Icon position enum
enum IconPosition {
  /// Icon on the left of the label
  left,

  /// Icon on the right of the label
  right,
}
