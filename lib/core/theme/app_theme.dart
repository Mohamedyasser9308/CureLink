import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // Brand Colors
  // ============================================================

  static const Color primary = Color(0xFF81459E);
  static const Color primaryDark = Color(0xFF573894);

  static const Color navy = Color(0xFF002D72);

  static const Color mint = Color(0xFFA0E5D9);
  static const Color cyan = Color(0xFF09CDCD);

  static const Color background = Color(0xFFF9F7EC);

  static const Color destructive = Color(0xFFD94F5C);

  static const Color disabled = Color(0xFFD7DDE2);

  // ============================================================
  // Light Mode
  // ============================================================

  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color lightTextPrimary = Color(0xFF1F1B24);
  static const Color lightTextSecondary = Color(0xFF66616B);

  // ============================================================
  // Dark Mode
  // ============================================================

  // درجات الكحلي حسب التصميم (بدل البنفسجي الغامق)
  static const Color darkBackground = Color(0xFF071A33);
  static const Color darkSurface = Color(0xFF0D2547);
  static const Color darkSurfaceVariant = Color(0xFF133158);

  static const Color darkTextPrimary = Color(0xFFF2F6FC);
  static const Color darkTextSecondary = Color(0xFF9FB0C9);

  // ============================================================
  // Shared Dimensions
  // ============================================================

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;

  static const double inputHeight = 56;
  static const double buttonHeight = 56;

  // ============================================================
  // Typography
  // ============================================================

  static const String fontFamily = 'Inter';

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
