import 'package:flutter/material.dart';

/// Color tokens from the SI Buddy Figma design system ("Swiss Blue").
abstract final class AppColors {
  static const primary = Color(0xFF2457C5);
  static const background = Color(0xFFF8FAFC);

  /// Figma: surface-selected (progress card, active nav pill).
  static const surface = Color(0xFFDCE7FA);

  /// Figma: surface-subtle (tiles, rows).
  static const surfaceSubtle = Color(0xFFF1F5F9);

  /// Figma: chip/badge background (file format labels).
  static const chip = Color(0xFFE2E8F0);

  static const text = Color(0xFF172033);

  /// Figma: text-secondary.
  static const textSecondary = Color(0xFF40516B);

  static const muted = Color(0xFF52627B);

  /// Inactive navigation/icon gray (Figma icon stroke).
  static const navInactive = Color(0xFF64748B);

  /// Figma: color/border.
  static const border = Color(0xFFCBD5E1);

  static const success = Color(0xFF16A34A);

  /// Figma: danger-text (destructive actions, errors).
  static const danger = Color(0xFFB4233A);

  /// Figma: danger-surface (destructive icon chips, error banners).
  static const dangerSurface = Color(0xFFFFF1F2);

  /// Figma: warning-surface (warning icon chips, banners).
  static const warningSurface = Color(0xFFFFF4E5);

  /// Figma: warning-text (warning labels on warning-surface).
  static const warningText = Color(0xFF8C4A05);

  /// Figma: success-surface (correct-answer and success banners).
  static const successSurface = Color(0xFFEDF8F0);

  /// Figma: accent-muted (soft blue accents, dialog indicators).
  static const accentMuted = Color(0xFF9AB5E8);

  /// Figma: success-text (e.g. "AI Ready Offline").
  static const successText = Color(0xFF116B32);

  static const white = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Dark appearance: the same tokens on slate surfaces with light text.
  // Filled buttons keep the light [primary]/[danger] fills (white text
  // on them still has good contrast); only text, icon and link uses of
  // primary/danger/success switch to the lighter dark variants below.
  // ---------------------------------------------------------------------------

  static const darkBackground = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
  static const darkSurface = Color(0xFF1E3A5F);
  static const darkSurfaceSubtle = Color(0xFF1E293B);
  static const darkChip = Color(0xFF334155);
  static const darkText = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkMuted = Color(0xFF94A3B8);
  static const darkNavInactive = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF334155);
  static const darkPrimary = Color(0xFF7AA5F0);
  static const darkDanger = Color(0xFFF87171);
  static const darkDangerSurface = Color(0xFF3F1D24);
  static const darkWarningSurface = Color(0xFF3A2A12);
  static const darkWarningText = Color(0xFFFBBF24);
  static const darkSuccess = Color(0xFF4ADE80);
  static const darkSuccessSurface = Color(0xFF12291A);
  static const darkSuccessText = Color(0xFF4ADE80);
  static const darkAccentMuted = Color(0xFF7AA5F0);
}

/// Theme-aware color tokens: `context.appBackground` is the light
/// token in Light appearance and the dark token in Dark appearance
/// (System follows the device). Screens must use these instead of
/// the raw [AppColors] constants, or Dark renders the light colors.
///
/// `white` is deliberately NOT resolved here: it is foreground on
/// colored fills (button labels, icons on primary/danger chips) and
/// stays white in both appearances. Card/container backgrounds that
/// were `AppColors.white` use [appCard] instead.
extension AppThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;
  Color get appCard => isDarkMode ? AppColors.darkCard : AppColors.white;
  Color get appSurface =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;
  Color get appSurfaceSubtle =>
      isDarkMode ? AppColors.darkSurfaceSubtle : AppColors.surfaceSubtle;
  Color get appChip => isDarkMode ? AppColors.darkChip : AppColors.chip;
  Color get appText => isDarkMode ? AppColors.darkText : AppColors.text;
  Color get appTextSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get appMuted => isDarkMode ? AppColors.darkMuted : AppColors.muted;
  Color get appNavInactive =>
      isDarkMode ? AppColors.darkNavInactive : AppColors.navInactive;
  Color get appBorder => isDarkMode ? AppColors.darkBorder : AppColors.border;
  Color get appPrimary =>
      isDarkMode ? AppColors.darkPrimary : AppColors.primary;
  Color get appDanger => isDarkMode ? AppColors.darkDanger : AppColors.danger;
  Color get appDangerSurface =>
      isDarkMode ? AppColors.darkDangerSurface : AppColors.dangerSurface;
  Color get appWarningSurface =>
      isDarkMode ? AppColors.darkWarningSurface : AppColors.warningSurface;
  Color get appWarningText =>
      isDarkMode ? AppColors.darkWarningText : AppColors.warningText;
  Color get appSuccess =>
      isDarkMode ? AppColors.darkSuccess : AppColors.success;
  Color get appSuccessSurface =>
      isDarkMode ? AppColors.darkSuccessSurface : AppColors.successSurface;
  Color get appSuccessText =>
      isDarkMode ? AppColors.darkSuccessText : AppColors.successText;
  Color get appAccentMuted =>
      isDarkMode ? AppColors.darkAccentMuted : AppColors.accentMuted;
}
