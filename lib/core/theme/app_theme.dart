import 'package:flutter/material.dart';
import 'app_colors.dart';

// App theme configuration
class AppTheme {
  // Light theme
  static ThemeData get lightTheme {
    return ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: AppColors.webBackgroundColor,
      primaryColor: AppColors.primaryColor,
      colorScheme: const ColorScheme.light().copyWith(
        primary: AppColors.blueColor,
        secondary: AppColors.secondaryColor,
      ),
    );
  }
  
  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: AppColors.mobileBackgroundColor,
      primaryColor: AppColors.primaryColor,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.blueColor,
        secondary: AppColors.secondaryColor,
      ),
    );
  }
}
