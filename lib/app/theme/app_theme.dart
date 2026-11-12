import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The app theme: a single Light Mode minimalist system (2026-11-12
/// restyle). Warm off-white canvas, flat white cards with 1px
/// hairline borders, zero elevation, ink-black primary actions.
///
/// Note: this is a static [ThemeData] value, so it uses the raw
/// [AppColors] constants directly. Screens use the theme-aware
/// `context.app…` getters and `AppTextStyles.…(context)` instead.
abstract final class AppTheme {
  static const primary = AppColors.primary;
  static const surface = AppColors.surface;
  static const border = AppColors.border;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      surface: AppColors.background,
      onSurface: AppColors.text,
      outline: AppColors.border,
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
        letterSpacing: -0.5,
        color: AppColors.text,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 30 / 24,
        letterSpacing: -0.5,
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
        side: BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.white),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.placeholder),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.border,
      ),
      thumbColor: const WidgetStatePropertyAll(AppColors.white),
    ),
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
