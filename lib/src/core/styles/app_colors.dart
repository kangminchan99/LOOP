import 'package:flutter/material.dart';

class AppColors extends Color {
  AppColors(super.value);

  /// Light
  static const Color scaffoldBackgroundColor = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F2F6);

  /// Brand
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFEDE9FE);
  static const Color primaryDark = Color(0xFF5B21B6);

  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryLight = Color(0xFFFCE7F3);

  /// Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  /// Line
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF0F1F3);

  /// Dark
  static const Color darkScaffoldBackgroundColor = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF181C23);
  static const Color darkSurfaceVariant = Color(0xFF232833);

  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFB6BDC9);
  static const Color darkTextHint = Color(0xFF8A94A6);

  static const Color darkBorder = Color(0xFF313846);
  static const Color darkDivider = Color(0xFF232833);

  /// Base
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// State
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  /// Gradient
  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED),
    Color(0xFFD946EF),
    Color(0xFFF472B6),
  ];
}
