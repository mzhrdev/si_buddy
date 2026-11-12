import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The app themes. [light] is the Figma "Swiss Blue" system; [dark]
/// keeps the same type scale on slate surfaces with light text.
/// Filled buttons keep the cobalt fill and white label in both —
/// the fill is the brand color, not a surface.
///
/// Note: these are static [ThemeData] values, so they use the raw
/// [AppColors] constants (light) and `dark*` constants (dark)
/// directly. Screens use the theme-aware `context.app…` getters and
/// `AppTextStyles.…(context)` instead, so they follow the appearance
/// the user picked.
abstract final class AppTheme {
  static const primary = AppColors.primary;
  static const surface = AppColors.surface;
  static const border = AppColors.border;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      surface: AppColors.background,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.55),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      ),
      labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: AppColors.text,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        color: AppColors.text,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        color: AppColors.text,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.white),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 22 / 16,
          color: AppColors.white,
        ),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: AppColors.darkBackground,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.darkMuted,
        fontSize: 14,
        height: 1.55,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkText,
      ),
      labelLarge: TextStyle(
        color: AppColors.darkPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: AppColors.darkText,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        color: AppColors.darkText,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        color: AppColors.darkText,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.darkCard),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 22 / 16,
          color: AppColors.white,
        ),
      ),
    ),
  );
}
