import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const primary = AppColors.primary;
  static const surface = AppColors.surface;
  static const border = AppColors.border;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: primary, surface: AppColors.background),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.55),
          bodyMedium: TextStyle(color: AppColors.text, fontSize: 14),
          labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w800),
          displaySmall: TextStyle(color: AppColors.text, fontSize: 28, fontWeight: FontWeight.w800),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );
}
