import 'package:flutter/material.dart';

// Enhanced UI constants
class UiConstants {
  // Screen breakpoints
  static const webScreenHeight = 600;
  static const tabletBreakpoint = 768;
  static const desktopBreakpoint = 1200;

  // Spacing - Height
  static const SizedBox kHeight4 = SizedBox(height: 4);
  static const SizedBox kHeight8 = SizedBox(height: 8);
  static const SizedBox kHeight = SizedBox(height: 10);
  static const SizedBox kHeight12 = SizedBox(height: 12);
  static const SizedBox kHeight16 = SizedBox(height: 16);
  static const SizedBox kHeight20 = SizedBox(height: 20);
  static const SizedBox kHeight24 = SizedBox(height: 24);
  static const SizedBox kHeight30 = SizedBox(height: 30);
  static const SizedBox kHeight40 = SizedBox(height: 40);
  static const SizedBox kHeight50 = SizedBox(height: 50);

  // Spacing - Width
  static const SizedBox kWidth4 = SizedBox(width: 4);
  static const SizedBox kWidth8 = SizedBox(width: 8);
  static const SizedBox kWidth = SizedBox(width: 10);
  static const SizedBox kWidth12 = SizedBox(width: 12);
  static const SizedBox kWidth16 = SizedBox(width: 16);
  static const SizedBox kWidth20 = SizedBox(width: 20);
  static const SizedBox kWidth24 = SizedBox(width: 24);
  static const SizedBox kWidth30 = SizedBox(width: 30);
  static const SizedBox kWidth40 = SizedBox(width: 40);

  // Padding
  static const EdgeInsets paddingAll4 = EdgeInsets.all(4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(24);

  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: 8);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: 24);

  static const EdgeInsets paddingH16V8 =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets paddingH24V16 =
      EdgeInsets.symmetric(horizontal: 24, vertical: 16);

  // Border radius
  static const double borderRadiusSmall = 8;
  static const double borderRadiusMedium = 12;
  static const double borderRadiusLarge = 16;
  static const double borderRadiusXLarge = 24;
  static const double borderRadiusCircular = 100;

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animXSlow = Duration(milliseconds: 800);

  // Animation curves
  static const Curve animCurveSmooth = Curves.easeInOut;
  static const Curve animCurveEmphasized = Curves.easeOutBack;
  static const Curve animCurveBounce = Curves.elasticOut;

  // Elevation
  static const double elevationNone = 0;
  static const double elevationXSmall = 1;
  static const double elevationSmall = 2;
  static const double elevationMedium = 4;
  static const double elevationLarge = 8;
  static const double elevationXLarge = 16;
}
