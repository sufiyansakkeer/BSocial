import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/animation_utils.dart';

/// Avatar sizes for BSocial
enum BSAvatarSize {
  /// Extra small avatar (24px)
  xs(24),

  /// Small avatar (32px)
  sm(32),

  /// Medium avatar (40px)
  md(40),

  /// Large avatar (56px)
  lg(56),

  /// Extra large avatar (72px)
  xl(72),

  /// Extra extra large avatar (96px)
  xxl(96);

  /// The size of the avatar in pixels
  final double size;

  /// Constructor
  const BSAvatarSize(this.size);
}

/// A customizable avatar component for BSocial
class BSAvatar extends StatelessWidget {
  /// Creates a BSocial avatar
  const BSAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = BSAvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
    this.isOnline = false,
    this.onlineIndicatorColor,
    this.onlineIndicatorSize,
    this.onlineIndicatorBorderColor,
    this.onlineIndicatorBorderWidth = 2,
    this.showAnimation = false,
    this.placeholderIcon,
    this.errorIcon,
  });

  /// The URL of the avatar image
  final String? imageUrl;

  /// The initials to display when no image is available
  final String? initials;

  /// The size of the avatar
  final BSAvatarSize size;

  /// The background color of the avatar
  final Color? backgroundColor;

  /// The foreground color of the avatar (for initials)
  final Color? foregroundColor;

  /// The border color of the avatar
  final Color? borderColor;

  /// The border width of the avatar
  final double borderWidth;

  /// Callback when the avatar is tapped
  final VoidCallback? onTap;

  /// Whether to show an online indicator
  final bool isOnline;

  /// The color of the online indicator
  final Color? onlineIndicatorColor;

  /// The size of the online indicator
  final double? onlineIndicatorSize;

  /// The border color of the online indicator
  final Color? onlineIndicatorBorderColor;

  /// The border width of the online indicator
  final double onlineIndicatorBorderWidth;

  /// Whether to show a pulse animation
  final bool showAnimation;

  /// The icon to display when the image is loading
  final IconData? placeholderIcon;

  /// The icon to display when the image fails to load
  final IconData? errorIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? 
        (theme.brightness == Brightness.dark 
            ? Colors.grey.shade800 
            : Colors.grey.shade300);
    
    final effectiveForegroundColor = foregroundColor ?? 
        (theme.brightness == Brightness.dark 
            ? Colors.white 
            : Colors.black87);
    
    final effectiveBorderColor = borderColor;
    
    final effectiveOnlineIndicatorColor = onlineIndicatorColor ?? 
        AppColors.success;
    
    final effectiveOnlineIndicatorBorderColor = onlineIndicatorBorderColor ?? 
        (theme.brightness == Brightness.dark 
            ? AppColors.backgroundDark 
            : AppColors.backgroundLight);
    
    final effectiveOnlineIndicatorSize = onlineIndicatorSize ?? 
        (size.size * 0.3);

    final effectivePlaceholderIcon = placeholderIcon ?? Icons.person;
    final effectiveErrorIcon = errorIcon ?? Icons.error_outline;

    Widget avatar = _buildAvatarContent(
      context,
      effectiveBackgroundColor,
      effectiveForegroundColor,
      effectivePlaceholderIcon,
      effectiveErrorIcon,
    );

    // Add border if needed
    if (borderWidth > 0 && effectiveBorderColor != null) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    // Add online indicator if needed
    if (isOnline) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: effectiveOnlineIndicatorSize,
              height: effectiveOnlineIndicatorSize,
              decoration: BoxDecoration(
                color: effectiveOnlineIndicatorColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveOnlineIndicatorBorderColor,
                  width: onlineIndicatorBorderWidth,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Add animation if needed
    if (showAnimation) {
      avatar = AnimationUtils.pulse(
        child: avatar,
        minScale: 0.95,
        maxScale: 1.05,
        duration: const Duration(milliseconds: 2000),
      );
    }

    // Add tap functionality if needed
    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  /// Build the avatar content based on the available data
  Widget _buildAvatarContent(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
    IconData placeholderIcon,
    IconData errorIcon,
  ) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size.size,
          height: size.size,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: size.size,
            height: size.size,
            color: backgroundColor,
            child: Icon(
              placeholderIcon,
              size: size.size * 0.5,
              color: foregroundColor,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: size.size,
            height: size.size,
            color: backgroundColor,
            child: Icon(
              errorIcon,
              size: size.size * 0.5,
              color: foregroundColor,
            ),
          ),
        ),
      );
    } else if (initials != null && initials!.isNotEmpty) {
      return Container(
        width: size.size,
        height: size.size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials!.length > 2 ? initials!.substring(0, 2) : initials!,
            style: TextStyle(
              color: foregroundColor,
              fontSize: size.size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: size.size,
        height: size.size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          placeholderIcon,
          size: size.size * 0.5,
          color: foregroundColor,
        ),
      );
    }
  }
}
