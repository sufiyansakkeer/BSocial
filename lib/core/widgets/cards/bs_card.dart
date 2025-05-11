import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../../utils/ui_constants.dart';

/// Card elevation levels
enum BSCardElevation {
  /// No elevation
  none,

  /// Subtle elevation
  subtle,

  /// Medium elevation
  medium,

  /// Emphasized elevation
  emphasized,
}

/// A customizable card component for BSocial
class BSCard extends StatelessWidget {
  /// Creates a BSocial card
  const BSCard({
    required this.child,
    super.key,
    this.elevation = BSCardElevation.subtle,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.border,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
  });

  /// The content of the card
  final Widget child;

  /// The elevation level of the card
  final BSCardElevation elevation;

  /// The border radius of the card
  final BorderRadius? borderRadius;

  /// The padding inside the card
  final EdgeInsetsGeometry? padding;

  /// The margin around the card
  final EdgeInsetsGeometry? margin;

  /// The background color of the card
  final Color? color;

  /// The border of the card
  final Border? border;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// How to clip the card's content
  final Clip clipBehavior;

  /// The width of the card
  final double? width;

  /// The height of the card
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? 
        BorderRadius.circular(UiConstants.borderRadiusLarge);
    final effectiveColor = color ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    
    final cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: _getShadow(),
      ),
      clipBehavior: clipBehavior,
      child: child,
    );

    return Container(
      margin: margin,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: effectiveBorderRadius,
                child: cardContent,
              ),
            )
          : cardContent,
    );
  }

  /// Get the appropriate shadow based on elevation
  List<BoxShadow>? _getShadow() {
    return switch (elevation) {
      BSCardElevation.none => null,
      BSCardElevation.subtle => DesignSystem.subtleShadow,
      BSCardElevation.medium => DesignSystem.mediumShadow,
      BSCardElevation.emphasized => DesignSystem.emphasizedShadow,
    };
  }
}

/// A card with a header, content, and optional footer
class BSContentCard extends StatelessWidget {
  /// Creates a BSocial content card
  const BSContentCard({
    required this.content,
    super.key,
    this.header,
    this.footer,
    this.elevation = BSCardElevation.subtle,
    this.borderRadius,
    this.margin,
    this.color,
    this.border,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.width,
    this.height,
    this.contentPadding = const EdgeInsets.all(16),
    this.headerPadding = const EdgeInsets.all(16),
    this.footerPadding = const EdgeInsets.all(16),
    this.headerDivider = true,
    this.footerDivider = true,
  });

  /// The header widget
  final Widget? header;

  /// The content widget
  final Widget content;

  /// The footer widget
  final Widget? footer;

  /// The elevation level of the card
  final BSCardElevation elevation;

  /// The border radius of the card
  final BorderRadius? borderRadius;

  /// The margin around the card
  final EdgeInsetsGeometry? margin;

  /// The background color of the card
  final Color? color;

  /// The border of the card
  final Border? border;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// How to clip the card's content
  final Clip clipBehavior;

  /// The width of the card
  final double? width;

  /// The height of the card
  final double? height;

  /// The padding for the content
  final EdgeInsetsGeometry contentPadding;

  /// The padding for the header
  final EdgeInsetsGeometry headerPadding;

  /// The padding for the footer
  final EdgeInsetsGeometry footerPadding;

  /// Whether to show a divider below the header
  final bool headerDivider;

  /// Whether to show a divider above the footer
  final bool footerDivider;

  @override
  Widget build(BuildContext context) {
    return BSCard(
      elevation: elevation,
      borderRadius: borderRadius,
      margin: margin,
      color: color,
      border: border,
      onTap: onTap,
      clipBehavior: clipBehavior,
      width: width,
      height: height,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) ...[
            Padding(
              padding: headerPadding,
              child: header,
            ),
            if (headerDivider) const Divider(height: 1),
          ],
          Padding(
            padding: contentPadding,
            child: content,
          ),
          if (footer != null) ...[
            if (footerDivider) const Divider(height: 1),
            Padding(
              padding: footerPadding,
              child: footer,
            ),
          ],
        ],
      ),
    );
  }
}
