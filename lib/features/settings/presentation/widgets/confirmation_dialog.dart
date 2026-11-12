import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Shows the Figma "SI Buddy / Confirmation dialog" over the current
/// screen and returns whether the user confirmed. Cancel, the system
/// back button and tapping outside all return false.
///
/// The dialog is a centered white card (radius 4, padding 24) with a
/// 44px indicator chip, a 24px bold title, muted message paragraphs,
/// a 56px confirm button and a 44px outlined Cancel button, over the
/// Figma scrim (rgba(23, 32, 51, 0.42)). Callers run their action
/// after awaiting the result — the dialog itself only answers.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String iconAsset,
  required Color indicatorColor,
  required Color iconColor,
  required String title,
  required List<String> messageParagraphs,
  required String confirmLabel,
  Color confirmColor = AppColors.primary,
  Set<int> emphasizedParagraphs = const {},
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x6B172033),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConfirmationDialog(
        iconAsset: iconAsset,
        indicatorColor: indicatorColor,
        iconColor: iconColor,
        title: title,
        messageParagraphs: messageParagraphs,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        emphasizedParagraphs: emphasizedParagraphs,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    ),
  );
  return confirmed ?? false;
}

/// The Figma "SI Buddy / Confirmation dialog" card: a 44px indicator
/// chip, a 24px bold title, muted message paragraphs, a 56px confirm
/// button and a 44px outlined Cancel button. Shown through
/// [showConfirmationDialog]; it carries no scrim or navigation of
/// its own.
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.appCard,
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
            style: AppTextStyles.display(
              context,
            ).copyWith(letterSpacing: -0.48),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < messageParagraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Text(
              messageParagraphs[i],
              style: emphasizedParagraphs.contains(i)
                  ? TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 18 / 13,
                      color: context.appDanger,
                    )
                  : TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 20 / 13,
                      color: context.appMuted,
                    ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(backgroundColor: confirmColor),
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
                side: BorderSide(color: context.appBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.body(context).copyWith(
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: context.appPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
