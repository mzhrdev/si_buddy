import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Label style for settings rows and section titles (14, SemiBold, lh 20).
TextStyle _labelStyle(BuildContext context) => TextStyle(
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 20 / 14,
  color: context.appText,
);

/// A settings section: a 14px semibold title above its rows (gap 8),
/// as used across the Settings screens in Figma.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _labelStyle(context)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

/// White card (radius 4, padding 12 horizontal / 4 vertical, 1px
/// hairline border) that groups settings rows, as in the Figma
/// settings frames.
class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(children: children),
    );
  }
}

/// One settings row from the Figma "SI Buddy / Settings row" components:
/// a 32px surface-subtle icon chip, a semibold label with optional
/// supporting text (11 muted), an optional trailing value (12 muted),
/// and a 16px chevron. Minimum height 48.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.iconAsset,
    required this.label,
    this.supportingText,
    this.trailingValue,
    this.onTap,
    this.showDivider = false,
    this.iconColor,
    super.key,
  });

  final String iconAsset;
  final String label;
  final String? supportingText;
  final String? trailingValue;
  final VoidCallback? onTap;

  /// Draws the bottom border used by rows inside cards.
  final bool showDivider;

  /// Tint for the row icon (Figma icon stroke color).
  /// Null reads as the secondary text color.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(bottom: BorderSide(color: context.appBorder)),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.appSurfaceSubtle,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: SvgPicture.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    iconColor ?? context.appTextSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: _labelStyle(context)),
                  if (supportingText != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      supportingText!,
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingValue != null) ...[
              Text(trailingValue!, style: AppTextStyles.greeting(context)),
              const SizedBox(width: 4),
            ],
            SvgPicture.asset(
              'assets/svgs/figma/chevron_right.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                context.appNavInactive,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
