import 'package:flutter/material.dart';
import '../utils/ui_constants.dart';
import 'app_colors.dart';

/// Comprehensive design system for BSocial
class DesignSystem {
  // Private constructor to prevent instantiation
  DesignSystem._();

  /// Typography styles
  static final typography = BSTypography();
  
  /// Elevation levels
  static const double elevationLevel0 = 0;
  static const double elevationLevel1 = 1;
  static const double elevationLevel2 = 3;
  static const double elevationLevel3 = 6;
  static const double elevationLevel4 = 8;
  static const double elevationLevel5 = 12;
  
  /// Shadow styles
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(13), // 0.05 opacity
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(20), // 0.08 opacity
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get emphasizedShadow => [
    BoxShadow(
      color: Colors.black.withAlpha(31), // 0.12 opacity
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  /// Button styles
  static ButtonStyle primaryButton(BuildContext context) => 
      ElevatedButton.styleFrom(
        elevation: elevationLevel1,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
        ),
        textStyle: typography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle secondaryButton(BuildContext context) => 
      ElevatedButton.styleFrom(
        elevation: elevationLevel0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
        ),
        textStyle: typography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle outlinedButton(BuildContext context) => 
      OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
        ),
        textStyle: typography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );

  static ButtonStyle textButton(BuildContext context) => 
      TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UiConstants.borderRadiusSmall),
        ),
        textStyle: typography.labelLarge,
      );

  static ButtonStyle iconButton(BuildContext context) => 
      IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Colors.transparent,
        shape: const CircleBorder(),
      );
}

/// Typography styles for the design system
class BSTypography {
  // Display styles
  final TextStyle displayLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
    color: AppColors.textDark, // Default color for light mode
  );

  final TextStyle displayMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.textDark,
  );

  final TextStyle displaySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    color: AppColors.textDark,
  );

  // Headline styles
  final TextStyle headlineLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    color: AppColors.textDark,
  );

  final TextStyle headlineMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: AppColors.textDark,
  );

  final TextStyle headlineSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.textDark,
  );

  // Title styles
  final TextStyle titleLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
    color: AppColors.textDark,
  );

  final TextStyle titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.textDark,
  );

  final TextStyle titleSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textDark,
  );

  // Body styles
  final TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.textDark,
  );

  final TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.textDark,
  );

  final TextStyle bodySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.textDark,
  );

  // Label styles
  final TextStyle labelLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.textDark,
  );

  final TextStyle labelMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.textDark,
  );

  final TextStyle labelSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.textDark,
  );
}
