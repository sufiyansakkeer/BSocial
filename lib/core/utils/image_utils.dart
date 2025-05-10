import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Image utility functions
class ImageUtils {
  /// Private constructor to prevent instantiation
  const ImageUtils._();

  /// Pick an image from the specified source
  static Future<dynamic> pickImage(ImageSource imageSource) async {
    final imagePicker = ImagePicker();
    final file = await imagePicker.pickImage(source: imageSource);

    if (file != null) {
      // Return file as Uint8List to be compatible with web
      return file.readAsBytes();
    }

    log('No image was picked', name: 'pickImage');
    return null;
  }

  /// Get a valid image provider from a URL or fallback to a placeholder
  static ImageProvider getImageProvider(String? url, {String? fallbackAsset}) {
    // Check if URL is valid
    if (url != null && url.isNotEmpty) {
      // Handle different URL schemes
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return NetworkImage(url);
      } else if (url.startsWith('file://')) {
        // Make sure the file path is valid (has more than just the scheme)
        if (url.length > 7) {
          try {
            return FileImage(File(Uri.parse(url).toFilePath()));
          } on FormatException catch (e) {
            log('Invalid file URL format: $url, error: $e',
                name: 'getImageProvider');
          } on IOException catch (e) {
            log('File system error: $url, error: $e', name: 'getImageProvider');
          } on Exception catch (e) {
            log('Invalid file URL: $url, error: $e', name: 'getImageProvider');
          }
        }
      } else if (url.startsWith('asset://')) {
        // Handle asset URLs
        final assetPath = url.replaceFirst('asset://', '');
        return AssetImage(assetPath);
      }
    }

    // Fallback to placeholder
    return AssetImage(fallbackAsset ?? 'assets/images/images.jpeg');
  }

  /// Check if a URL is valid for image loading
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    // Check for common image URL patterns
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return true;
    } else if (url.startsWith('file://')) {
      return url.length > 7; // More than just "file://"
    } else if (url.startsWith('asset://')) {
      return true;
    }

    return false;
  }

  /// Get a placeholder widget for when an image fails to load
  static Widget getPlaceholderImage({
    double? width,
    double? height,
    Color? color,
    IconData icon = Icons.person,
    double iconSize = 50,
  }) =>
      Container(
        width: width,
        height: height,
        color: color ?? Colors.grey[300],
        child: Icon(
          icon,
          size: iconSize,
          color: Colors.grey[600],
        ),
      );
}
