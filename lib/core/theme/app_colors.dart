import 'package:flutter/material.dart';

// Modern app color palette
class AppColors {
  // Primary colors
  static const primaryColor = Color(0xFF3D5AFE); // Vibrant blue
  static const primaryVariant = Color(0xFF0031CA); // Darker blue
  static const primaryLight = Color(0xFF8187FF); // Lighter blue

  // Secondary colors
  static const secondaryColor = Color(0xFF00BFA5); // Teal accent
  static const secondaryVariant = Color(0xFF008E76); // Darker teal
  static const secondaryLight = Color(0xFF5DF2D6); // Lighter teal

  // Background colors
  static const backgroundLight = Color(0xFFF8F9FA); // Light background
  static const backgroundDark = Color(0xFF121212); // Dark background
  static const surfaceLight = Colors.white; // Light surface
  static const surfaceDark = Color(0xFF1E1E1E); // Dark surface

  // Accent colors
  static const accentPink = Color(0xFFFF4081); // Pink accent
  static const accentPurple = Color(0xFF9C27B0); // Purple accent
  static const accentOrange = Color(0xFFFF9800); // Orange accent

  // Text colors
  static const textDark = Color(0xFF212121); // Dark text
  static const textLight = Colors.white; // Light text
  static const textMuted = Color(0xFF757575); // Muted text

  // Legacy colors (for backward compatibility)
  static const mobileBackgroundColor = backgroundDark;
  static const webBackgroundColor = backgroundDark;
  static const mobileSearchColor = Color(0xFF262626);
  static const blueColor = primaryColor;
}
