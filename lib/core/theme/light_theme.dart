import 'package:flutter/material.dart';
import 'app_theme.dart';

class LightTheme {
  LightTheme._();

  static const Color _border = Color(0xFFE4E0D2);
  static const Color _borderDisabled = Color(0xFFEDEADF);
  static const Color _divider = Color(0xFFE4E0D2);
  static const Color _progressTrack = Color(0xFFE3E8EE);

  // Bottom nav (حسب التصميم: خلفية كريمي + تاب مختار سيان/بنفسجي)
  static const Color _navBackground = Color(0xFFFFFCF4);
  static const Color _navUnselected = Color(0xFF5F6B7A);

  static ThemeData get theme {
    final colorScheme = ColorScheme.light(
      primary: AppTheme.primary,
      onPrimary: Colors.white,
      secondary: AppTheme.mint,
      onSecondary: AppTheme.navy,
      tertiary: AppTheme.cyan,
      onTertiary: AppTheme.navy,
      error: AppTheme.destructive,
      onError: Colors.white,
      surface: AppTheme.lightSurface,
      onSurface: AppTheme.lightTextPrimary,
      onSurfaceVariant: AppTheme.lightTextSecondary,
      outline: _border,
      outlineVariant: _borderDisabled,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTheme.background,
      fontFamily: AppTheme.fontFamily,

      textTheme: AppTheme.textTheme.apply(
        bodyColor: AppTheme.lightTextPrimary,
        displayColor: AppTheme.lightTextPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: AppTheme.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: _border, width: 1),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.disabled,
          disabledForegroundColor: AppTheme.lightTextSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
          foregroundColor: AppTheme.primary,
          side: const BorderSide(color: AppTheme.primary, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primary,
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: AppTheme.lightTextSecondary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppTheme.lightTextSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppTheme.primary,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(color: AppTheme.destructive, fontSize: 12),
        prefixIconColor: AppTheme.lightTextSecondary,
        suffixIconColor: AppTheme.lightTextSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.cyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.destructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.destructive, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: _borderDisabled),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: AppTheme.cyan, width: 1.5),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTheme.cyan,
        linearTrackColor: _progressTrack,
        circularTrackColor: _progressTrack,
        linearMinHeight: 6,
      ),

      dividerTheme: const DividerThemeData(
        color: _divider,
        thickness: 1,
        space: 1,
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.primary;
            }
            return AppTheme.lightSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return AppTheme.lightTextSecondary;
          }),
          side: const WidgetStatePropertyAll(BorderSide(color: _border)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppTheme.lightSurface,
        side: const BorderSide(color: _border),
        labelStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTextPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: const StadiumBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTheme.primaryDark,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: AppTheme.fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTheme.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppTheme.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: _border),
        ),
      ),

      // ========================================================
      // Bottom Navigation: أيقونة المختار cyan + label بنفسجي عريض
      // ========================================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _navBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppTheme.cyan, size: 24);
          }
          return const IconThemeData(color: _navUnselected, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: _navUnselected,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          );
        }),
      ),
    );
  }
}
