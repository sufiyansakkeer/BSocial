import 'package:flutter/material.dart';

/// Modern app color palette
class AppColors {
  /// Primary colors
  static const primaryColor = Color(0xFF3D5AFE); // Vibrant blue
  static const primaryVariant = Color(0xFF0031CA); // Darker blue
  static const primaryLight = Color(0xFF8187FF); // Lighter blue

  /// Primary color (alias for chat feature)
  static const primary = primaryColor;

  /// Primary dark color (alias for chat feature)
  static const primaryDark = primaryVariant;

  /// Secondary colors
  static const secondaryColor = Color(0xFF00BFA5); // Teal accent
  static const secondaryVariant = Color(0xFF008E76); // Darker teal
  static const secondaryLight = Color(0xFF5DF2D6); // Lighter teal

  /// Secondary color (alias for chat feature)
  static const secondary = secondaryColor;

  /// Secondary dark color (alias for chat feature)
  static const secondaryDark = secondaryVariant;

  /// Background colors
  static const backgroundLight = Color(0xFFF8F9FA); // Light background
  static const backgroundDark = Color(0xFF121212); // Dark background
  static const surfaceLight = Colors.white; // Light surface
  static const surfaceDark = Color(0xFF1E1E1E); // Dark surface

  /// Accent colors
  static const accentPink = Color(0xFFFF4081); // Pink accent
  static const accentPurple = Color(0xFF9C27B0); // Purple accent
  static const accentOrange = Color(0xFFFF9800); // Orange accent

  /// Text colors
  static const textDark = Color(0xFF212121); // Dark text
  static const textLight = Colors.white; // Light text
  static const textMuted = Color(0xFF757575); // Muted text

  /// Status colors
  static const error = Color(0xFFB00020); // Error color
  static const success = Color(0xFF4CAF50); // Success color
  static const warning = Color(0xFFFFC107); // Warning color
  static const info = primaryColor; // Info color

  /// Legacy colors (for backward compatibility)
  static const mobileBackgroundColor = backgroundDark;
  static const webBackgroundColor = backgroundDark;
  static const mobileSearchColor = Color(0xFF262626);
  static const blueColor = primaryColor;
}
