import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The pinned bottom action bar of the subscription frames: an optional
/// muted note, the primary button (label + forward arrow), an optional
/// 44px outlined secondary action, and an optional footer row (the
/// Free / Restore links on the Upgrade frame).
class SubscriptionActions extends StatelessWidget {
  const SubscriptionActions({
    this.note,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.footer,
    super.key,
  });

  final String? note;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (note != null) ...[
            Text(
              note!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 18 / 12,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (primaryLabel != null) ...[
            FilledButton(
              onPressed: onPrimary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(primaryLabel!),
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
            const SizedBox(height: 8),
          ],
          if (secondaryLabel != null)
            OutlinedButton(
              onPressed: onSecondary,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                secondaryLabel!,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ?footer,
        ],
      ),
    );
  }
}
