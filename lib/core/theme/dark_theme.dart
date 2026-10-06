import 'package:flutter/material.dart';
import 'app_theme.dart';

class DarkTheme {
  DarkTheme._();

  // ألوان خاصة بالديزاين (حدود وتراكات زرقاء خفيفة)
  static const Color _border = Color(0xFF223C63);
  static const Color _borderDisabled = Color(0xFF182A47);
  static const Color _divider = Color(0xFF1A3050);
  // التراك في التصميم فاتح (أبيض/رمادي) والـ fill سيان
  static const Color _progressTrack = Color(0xFFE3E8EE);

  static ThemeData get theme {
    final colorScheme = ColorScheme.dark(
      primary: AppTheme.primary,
      onPrimary: Colors.white,

      secondary: AppTheme.mint,
      onSecondary: AppTheme.navy,

      tertiary: AppTheme.cyan,
      onTertiary: AppTheme.navy,

      error: AppTheme.destructive,
      onError: Colors.white,

      surface: AppTheme.darkSurface,
      onSurface: AppTheme.darkTextPrimary,

      surfaceContainerLowest: AppTheme.darkBackground,
      surfaceContainerLow: AppTheme.darkSurface,
      surfaceContainer: AppTheme.darkSurface,
      surfaceContainerHigh: AppTheme.darkSurfaceVariant,
      surfaceContainerHighest: AppTheme.darkSurfaceVariant,
      onSurfaceVariant: AppTheme.darkTextSecondary,

      outline: _border,
      outlineVariant: _borderDisabled,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTheme.darkBackground,
      fontFamily: AppTheme.fontFamily,

      textTheme: AppTheme.textTheme.apply(
        bodyColor: AppTheme.darkTextPrimary,
        displayColor: AppTheme.darkTextPrimary,
      ),

      // ========================================================
      // App Bar
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.darkBackground,
        foregroundColor: AppTheme.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      // ========================================================
      // Cards
      // ========================================================
      cardTheme: CardThemeData(
        color: AppTheme.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: _border, width: 1),
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // ========================================================
      // Elevated Button (بنفسجي زي Continue / Confirm Dose / Add Patient)
      // ========================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white54,
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

      // ========================================================
      // Filled Button
      // ========================================================
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

      // ========================================================
      // Outlined Button
      // ========================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
          foregroundColor: AppTheme.mint,
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

      // ========================================================
      // Text Button
      // ========================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.cyan,
          textStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ========================================================
      // Input Fields (Default / Focus / Filled / Error)
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: AppTheme.darkTextSecondary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppTheme.darkTextSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(color: AppTheme.cyan, fontSize: 14),
        errorStyle: const TextStyle(color: AppTheme.destructive, fontSize: 12),
        prefixIconColor: AppTheme.darkTextSecondary,
        suffixIconColor: AppTheme.darkTextSecondary,
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

      // ========================================================
      // Checkbox
      // ========================================================
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

      // ========================================================
      // Progress Indicator (Today's progress / Mission progress)
      // ========================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTheme.cyan,
        linearTrackColor: _progressTrack,
        circularTrackColor: _progressTrack,
        linearMinHeight: 6,
      ),

      // ========================================================
      // Divider
      // ========================================================
      dividerTheme: const DividerThemeData(
        color: _divider,
        thickness: 1,
        space: 1,
      ),

      // ========================================================
      // Segmented Button (Today / Tomorrow / All)
      // ========================================================
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTheme.primary;
            }
            return AppTheme.darkSurface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return AppTheme.darkTextSecondary;
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

      // ========================================================
      // Chips / Badges (Upcoming, Due now, Taken, Missed)
      // ========================================================
      chipTheme: ChipThemeData(
        backgroundColor: AppTheme.darkSurface,
        side: const BorderSide(color: _border),
        labelStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.darkTextPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: const StadiumBorder(),
      ),

      // ========================================================
      // Date Picker (Calendar: اليوم المختار بنفسجي)
      // ========================================================
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppTheme.darkSurface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppTheme.darkSurface,
        headerForegroundColor: AppTheme.darkTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: _border),
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) {
            return AppTheme.darkTextSecondary.withValues(alpha: 0.4);
          }
          return AppTheme.darkTextPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return AppTheme.primary;
          return Colors.transparent;
        }),
        todayForegroundColor: const WidgetStatePropertyAll(AppTheme.cyan),
        todayBorder: const BorderSide(color: AppTheme.cyan),
      ),

      // ========================================================
      // Switch (Notifications settings)
      // ========================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppTheme.darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) return AppTheme.primary;
          return AppTheme.darkSurfaceVariant;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(_border),
      ),

      // ========================================================
      // List Tile (Notifications / Medication rows)
      // ========================================================
      listTileTheme: ListTileThemeData(
        tileColor: AppTheme.darkSurface,
        iconColor: AppTheme.cyan,
        textColor: AppTheme.darkTextPrimary,
        subtitleTextStyle: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 12,
          color: AppTheme.darkTextSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: _border),
        ),
      ),

      // ========================================================
      // Snack Bar
      // ========================================================
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

      // ========================================================
      // Bottom Sheet / Dialog
      // ========================================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTheme.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppTheme.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: _border),
        ),
      ),

      // ========================================================
      // Bottom Navigation (الأيقونة والنص المختارين cyan بدون pill)
      // ========================================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppTheme.darkBackground,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppTheme.cyan, size: 22);
          }
          return const IconThemeData(
            color: AppTheme.darkTextSecondary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: AppTheme.cyan,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            );
          }
          return const TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppTheme.darkTextSecondary,
            fontSize: 11,
          );
        }),
      ),
    );
  }
}
