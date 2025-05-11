import 'package:flutter/material.dart';
import '../utils/ui_constants.dart';
import 'app_colors.dart';
import 'design_system.dart';

/// Modern app theme configuration with Material 3
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Common theme settings
  static ThemeData _baseTheme(ThemeData base) => base.copyWith(
        // Use Material 3 typography with custom text styles
        textTheme: TextTheme(
          displayLarge: DesignSystem.typography.displayLarge,
          displayMedium: DesignSystem.typography.displayMedium,
          displaySmall: DesignSystem.typography.displaySmall,
          headlineLarge: DesignSystem.typography.headlineLarge,
          headlineMedium: DesignSystem.typography.headlineMedium,
          headlineSmall: DesignSystem.typography.headlineSmall,
          titleLarge: DesignSystem.typography.titleLarge,
          titleMedium: DesignSystem.typography.titleMedium,
          titleSmall: DesignSystem.typography.titleSmall,
          bodyLarge: DesignSystem.typography.bodyLarge,
          bodyMedium: DesignSystem.typography.bodyMedium,
          bodySmall: DesignSystem.typography.bodySmall,
          labelLarge: DesignSystem.typography.labelLarge,
          labelMedium: DesignSystem.typography.labelMedium,
          labelSmall: DesignSystem.typography.labelSmall,
        ),

        // Button styles
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: DesignSystem.elevationLevel1,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(UiConstants.borderRadiusMedium),
            ),
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
            borderSide: BorderSide.none,
          ),
        ),

        // Card theme
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // App bar theme
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),

        // Bottom navigation bar theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 8,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        ),

        // Snackbar theme
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Dialog theme
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  // Light theme
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return _baseTheme(base).copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark, // Ensure text color is set
        error: Colors.red.shade700,
      ),
      textTheme: TextTheme(
        displayLarge: DesignSystem.typography.displayLarge
            .copyWith(color: AppColors.textDark),
        displayMedium: DesignSystem.typography.displayMedium
            .copyWith(color: AppColors.textDark),
        displaySmall: DesignSystem.typography.displaySmall
            .copyWith(color: AppColors.textDark),
        headlineLarge: DesignSystem.typography.headlineLarge
            .copyWith(color: AppColors.textDark),
        headlineMedium: DesignSystem.typography.headlineMedium
            .copyWith(color: AppColors.textDark),
        headlineSmall: DesignSystem.typography.headlineSmall
            .copyWith(color: AppColors.textDark),
        titleLarge: DesignSystem.typography.titleLarge
            .copyWith(color: AppColors.textDark),
        titleMedium: DesignSystem.typography.titleMedium
            .copyWith(color: AppColors.textDark),
        titleSmall: DesignSystem.typography.titleSmall
            .copyWith(color: AppColors.textDark),
        bodyLarge: DesignSystem.typography.bodyLarge
            .copyWith(color: AppColors.textDark),
        bodyMedium: DesignSystem.typography.bodyMedium
            .copyWith(color: AppColors.textDark),
        bodySmall: DesignSystem.typography.bodySmall
            .copyWith(color: AppColors.textDark),
        labelLarge: DesignSystem.typography.labelLarge
            .copyWith(color: AppColors.textDark),
        labelMedium: DesignSystem.typography.labelMedium
            .copyWith(color: AppColors.textDark),
        labelSmall: DesignSystem.typography.labelSmall
            .copyWith(color: AppColors.textDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        modalBackgroundColor: AppColors.surfaceLight,
      ),
      dividerColor: Colors.grey.shade300,
      iconTheme: const IconThemeData(
        color: AppColors.textDark,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return _baseTheme(base).copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        secondary: AppColors.secondaryColor,
        onSecondary: Colors.white,
        surface: AppColors.surfaceDark,
        error: Colors.red.shade300,
      ),
      textTheme: TextTheme(
        displayLarge: DesignSystem.typography.displayLarge
            .copyWith(color: AppColors.textLight),
        displayMedium: DesignSystem.typography.displayMedium
            .copyWith(color: AppColors.textLight),
        displaySmall: DesignSystem.typography.displaySmall
            .copyWith(color: AppColors.textLight),
        headlineLarge: DesignSystem.typography.headlineLarge
            .copyWith(color: AppColors.textLight),
        headlineMedium: DesignSystem.typography.headlineMedium
            .copyWith(color: AppColors.textLight),
        headlineSmall: DesignSystem.typography.headlineSmall
            .copyWith(color: AppColors.textLight),
        titleLarge: DesignSystem.typography.titleLarge
            .copyWith(color: AppColors.textLight),
        titleMedium: DesignSystem.typography.titleMedium
            .copyWith(color: AppColors.textLight),
        titleSmall: DesignSystem.typography.titleSmall
            .copyWith(color: AppColors.textLight),
        bodyLarge: DesignSystem.typography.bodyLarge
            .copyWith(color: AppColors.textLight),
        bodyMedium: DesignSystem.typography.bodyMedium
            .copyWith(color: AppColors.textLight),
        bodySmall: DesignSystem.typography.bodySmall
            .copyWith(color: AppColors.textLight),
        labelLarge: DesignSystem.typography.labelLarge
            .copyWith(color: AppColors.textLight),
        labelMedium: DesignSystem.typography.labelMedium
            .copyWith(color: AppColors.textLight),
        labelSmall: DesignSystem.typography.labelSmall
            .copyWith(color: AppColors.textLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        modalBackgroundColor: AppColors.surfaceDark,
      ),
      dividerColor: Colors.grey.shade800,
      iconTheme: const IconThemeData(
        color: AppColors.textLight,
      ),
    );
  }
}
