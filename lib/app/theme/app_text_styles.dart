import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles from the SI Buddy Figma design system.
/// Typeface: Inter (bundled in assets/fonts, weights 400–800).
/// Sizes/weights/line-heights are taken from the Figma frames.
abstract final class AppTextStyles {
  static const _family = 'Inter';

  /// Screen headline, e.g. "Let's make it stick." (24, Bold, lh 30)
  static const display = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    color: AppColors.text,
  );

  /// Large metric values, e.g. "24", "15 min" (24, Bold, lh 30)
  static const headline = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    color: AppColors.text,
  );

  /// Screen titles in the app header (20, SemiBold, lh 26)
  static const screenTitle = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 26 / 20,
    color: AppColors.text,
  );

  /// Section titles, e.g. "Recent documents" (16, SemiBold, lh 22)
  static const title = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: AppColors.text,
  );

  /// List item titles (13, SemiBold, lh 18)
  static const itemTitle = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    color: AppColors.text,
  );

  /// Default body text (14, Regular)
  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  /// Greeting line above the headline (12, Regular, muted, lh 18)
  static const greeting = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
    color: AppColors.muted,
  );

  /// Quick-action tile labels (11, SemiBold, lh 16)
  static const tileLabel = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: AppColors.text,
  );

  /// Supporting text (13, Regular, muted)
  static const muted = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  /// Small metadata (11, Regular, muted, lh 16),
  /// e.g. "PDF · 12 pages · Today", "Cards reviewed"
  static const caption = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    color: AppColors.muted,
  );

  /// Small emphasized metadata (11, SemiBold, secondary),
  /// e.g. "3-day streak", "15 / 20 min"
  static const captionStrong = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: AppColors.textSecondary,
  );

  /// Accent metadata (11, SemiBold, primary), e.g. "20 cards · 8 due"
  static const captionAccent = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: AppColors.primary,
  );

  /// Status label (11, SemiBold, success), e.g. "AI Ready Offline"
  static const successLabel = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: AppColors.successText,
  );

  /// Text links (12, SemiBold, primary), e.g. "See all"
  static const link = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: AppColors.primary,
  );

  /// File format badge, e.g. "PDF" (10, Bold, secondary, lh 14)
  static const badge = TextStyle(
    fontFamily: _family,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 14 / 10,
    color: AppColors.textSecondary,
  );

  /// Bottom navigation labels (11; SemiBold when active, Regular when not)
  static const navLabel = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
  );

  /// Primary button label (16, SemiBold, white, lh 22)
  static const button = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: AppColors.white,
  );
}
