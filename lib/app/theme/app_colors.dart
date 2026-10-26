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
}
