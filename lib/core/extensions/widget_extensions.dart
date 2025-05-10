import 'dart:developer';
import 'package:flutter/material.dart';

import '../utils/image_utils.dart';

/// Extensions for widgets
extension ImageWidgetExtensions on Widget {
  /// Safely load an image with error handling and placeholder
  static Widget safeNetworkImage({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    String? fallbackAsset,
  }) {
    // If URL is empty or null, return placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder ??
          ImageUtils.getPlaceholderImage(
            width: width,
            height: height,
          );
    }

    // For network images
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return placeholder ??
              Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            ImageUtils.getPlaceholderImage(
              width: width,
              height: height,
            ),
      );
    }

    // For file or asset images, use ImageUtils
    try {
      return Image(
        image: ImageUtils.getImageProvider(
          imageUrl,
          fallbackAsset: fallbackAsset,
        ),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            ImageUtils.getPlaceholderImage(
              width: width,
              height: height,
            ),
      );
    } on Exception catch (e) {
      log(e.toString(), name: 'ImageWidgetExtensions');
      return errorWidget ??
          ImageUtils.getPlaceholderImage(
            width: width,
            height: height,
          );
    }
  }

  /// Create a circular avatar with safe image loading
  static Widget safeCircleAvatar({
    required String? imageUrl,
    double radius = 40,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: Icon(
          Icons.person,
          size: radius * 0.8,
          color: Colors.grey[600],
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[300],
      backgroundImage: ImageUtils.getImageProvider(imageUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Just catch the error, the CircleAvatar will show the child
      },
      child: imageUrl.isEmpty
          ? Icon(
              Icons.person,
              size: radius * 0.8,
              color: Colors.grey[600],
            )
          : null,
    );
  }
}
