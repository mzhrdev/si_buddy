import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles for the minimalist Light Mode system.
/// Typeface: Inter (bundled in assets/fonts, weights 400–800).
/// Sizes/weights/line-heights are taken from the Figma frames;
/// hierarchy comes from size, weight and tight tracking, not color.
///
/// Each style is a static method taking the [BuildContext] because
/// the text color follows the theme tokens:
/// `AppTextStyles.body(context)`. The sizes and weights never
/// change — only the token values do. The `button` style stays white:
/// it labels filled primary buttons, whose fill is ink black.
abstract final class AppTextStyles {
  static const _family = 'Inter';

  /// Screen headline, e.g. "Let's make it stick." (24, Bold, lh 30)
  static TextStyle display(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    letterSpacing: -0.5,
    color: context.appText,
  );

  /// Large metric values, e.g. "24", "15 min" (24, Bold, lh 30)
  static TextStyle headline(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    letterSpacing: -0.5,
    color: context.appText,
  );

  /// Screen titles in the app header (20, SemiBold, lh 26)
  static TextStyle screenTitle(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 26 / 20,
    letterSpacing: -0.25,
    color: context.appText,
  );

  /// Section titles, e.g. "Recent documents" (16, SemiBold, lh 22)
  static TextStyle title(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: context.appText,
  );

  /// List item titles (13, SemiBold, lh 18)
  static TextStyle itemTitle(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    color: context.appText,
  );

  /// Default body text (14, Regular)
  static TextStyle body(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: context.appText,
  );

  /// Greeting line above the headline (12, Regular, muted, lh 18)
  static TextStyle greeting(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 18 / 12,
    color: context.appMuted,
  );

  /// Quick-action tile labels (11, SemiBold, lh 16)
  static TextStyle tileLabel(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: context.appText,
  );

  /// Supporting text (13, Regular, muted)
  static TextStyle muted(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: context.appMuted,
  );

  /// Small metadata (11, Regular, muted, lh 16),
  /// e.g. "PDF · 12 pages · Today", "Cards reviewed"
  static TextStyle caption(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 16 / 11,
    color: context.appMuted,
  );

  /// Small emphasized metadata (11, SemiBold, secondary),
  /// e.g. "3-day streak", "15 / 20 min"
  static TextStyle captionStrong(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: context.appTextSecondary,
  );

  /// Accent metadata (11, SemiBold, primary), e.g. "20 cards · 8 due"
  static TextStyle captionAccent(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: context.appPrimary,
  );

  /// Status label (11, SemiBold, success), e.g. "AI Service Ready"
  static TextStyle successLabel(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    color: context.appSuccessText,
  );

  /// Text links (12, SemiBold, primary), e.g. "See all"
  static TextStyle link(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: context.appPrimary,
  );

  /// File format badge, e.g. "PDF" (10, Bold, secondary, lh 14)
  static TextStyle badge(BuildContext context) => TextStyle(
    fontFamily: _family,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 14 / 10,
    color: context.appTextSecondary,
  );

  /// Bottom navigation labels (11; SemiBold when active, Regular when not)
  static TextStyle navLabel(BuildContext context) => const TextStyle(
    fontFamily: _family,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
  );

  /// Primary button label (16, SemiBold, white, lh 22)
  static TextStyle button(BuildContext context) => const TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: AppColors.white,
  );
}
