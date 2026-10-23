import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The Figma "SI Buddy / Confirmation dialog" as a full-screen overlay:
/// a dimmed scrim (Figma: color/overlay) with a centered white card
/// (radius 4, padding 24, gap 16) holding a 44px indicator chip, a
/// 24px bold title, muted message paragraphs, a 56px confirm button
/// and a 44px outlined Cancel button.
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    required this.iconAsset,
    required this.indicatorColor,
    required this.iconColor,
    required this.title,
    required this.messageParagraphs,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.confirmColor = AppColors.primary,
    this.emphasizedParagraphs = const {},
    super.key,
  });

  final String iconAsset;

  /// Background of the 44×44 indicator chip.
  final Color indicatorColor;

  /// Tint for the indicator icon.
  final Color iconColor;

  final String title;
  final List<String> messageParagraphs;
  final String confirmLabel;
  final Color confirmColor;

  /// Indexes into [messageParagraphs] rendered as semibold danger
  /// text instead of regular muted text (e.g. "This cannot be undone.").
  final Set<int> emphasizedParagraphs;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Figma: color/overlay (rgba(23, 32, 51, 0.42))
      backgroundColor: const Color(0x6B172033),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconAsset,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: AppTextStyles.display.copyWith(letterSpacing: -0.48),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < messageParagraphs.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Text(
                    messageParagraphs[i],
                    style: emphasizedParagraphs.contains(i)
                        ? const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 18 / 13,
                            color: AppColors.danger,
                          )
                        : const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 20 / 13,
                            color: AppColors.muted,
                          ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(confirmLabel),
                        const SizedBox(width: 12),
                        SvgPicture.asset(
                          'assets/icons/figma/arrow_right.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
