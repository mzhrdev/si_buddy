import 'package:flutter/material.dart';

/// Color tokens for the minimalist Light Mode system (2026-11-12
/// restyle; replaces the Figma "Swiss Blue" system).
///
/// One accent only: ink black (#111111) for primary actions and
/// active states. No gradients, no multi-color badges, no shadows —
/// containers are defined by 1px hairline borders on flat white or
/// warm-gray surfaces over a warm off-white canvas.
///
/// Semantic colors are kept only where they carry meaning
/// (destructive actions, errors, correct answers); their tinted
/// surfaces are gone — meaning is carried by text and icon on the
/// flat warm-gray surface instead.
abstract final class AppColors {
  /// Primary accent: ink black. Filled primary buttons, links and
  /// active states. White text on it is 18.9:1.
  static const primary = Color(0xFF111111);

  /// Canvas: warm off-white. Never pure white across a screen.
  static const background = Color(0xFFFAFAFA);

  /// Selected surface (active nav pill, selected rows).
  static const surface = Color(0xFFF3F3F2);

  /// Subtle surface (tiles, rows).
  static const surfaceSubtle = Color(0xFFF3F3F2);

  /// Chip/badge background.
  static const chip = Color(0xFFF3F3F2);

  /// Primary text: deep charcoal.
  static const text = Color(0xFF111111);

  /// Secondary text: muted slate. 5.5:1 on #FAFAFA.
  static const textSecondary = Color(0xFF666666);

  /// Muted text. Deliberately the same #666666 as [textSecondary]:
  /// the brief's #999999 is 2.7:1 on #FAFAFA and unreadable at
  /// 11–13px, so it is used only for input placeholders (see
  /// [placeholder]).
  static const muted = Color(0xFF666666);

  /// Placeholder / hint text in inputs. Never body text.
  static const placeholder = Color(0xFF999999);

  /// Inactive navigation/icon gray.
  static const navInactive = Color(0xFF666666);

  /// Hairline borders: 1px, no shadows.
  static const border = Color(0xFFE5E5E5);

  static const success = Color(0xFF16A34A);

  /// Destructive actions and errors (muted dark red).
  static const danger = Color(0xFFB4233A);

  /// Formerly tinted surfaces — now the flat warm gray; see the
  /// file doc comment. Kept as aliases so call sites keep working.
  static const dangerSurface = Color(0xFFF3F3F2);
  static const warningSurface = Color(0xFFF3F3F2);
  static const successSurface = Color(0xFFF3F3F2);

  /// Warning text (warning labels on the flat surface).
  static const warningText = Color(0xFF8C4A05);

  /// Decorative accents (illustration shapes, inactive dots).
  static const accentMuted = Color(0xFFE5E5E5);

  /// Success text (e.g. "AI Ready Offline").
  static const successText = Color(0xFF116B32);

  static const white = Color(0xFFFFFFFF);
}

/// Theme-aware color tokens. The app is Light Mode only (the 2026-
/// 11-12 restyle removed Dark/System): these getters return the
/// light tokens directly. The getter names are unchanged, so every
/// call site keeps working.
///
/// `white` is deliberately NOT resolved here: it is foreground on
/// colored fills (button labels, icons on primary/danger chips) and
/// stays white. Card/container backgrounds that were `AppColors.white`
/// use [appCard] instead.
extension AppThemeColors on BuildContext {
  Color get appBackground => AppColors.background;
  Color get appCard => AppColors.white;
  Color get appSurface => AppColors.surface;
  Color get appSurfaceSubtle => AppColors.surfaceSubtle;
  Color get appChip => AppColors.chip;
  Color get appText => AppColors.text;
  Color get appTextSecondary => AppColors.textSecondary;
  Color get appMuted => AppColors.muted;
  Color get appPlaceholder => AppColors.placeholder;
  Color get appNavInactive => AppColors.navInactive;
  Color get appBorder => AppColors.border;
  Color get appPrimary => AppColors.primary;
  Color get appDanger => AppColors.danger;
  Color get appDangerSurface => AppColors.dangerSurface;
  Color get appWarningSurface => AppColors.warningSurface;
  Color get appWarningText => AppColors.warningText;
  Color get appSuccess => AppColors.success;
  Color get appSuccessSurface => AppColors.successSurface;
  Color get appSuccessText => AppColors.successText;
  Color get appAccentMuted => AppColors.accentMuted;
}
