import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// A study material row (deck, quiz, summary, saved questions) as used
/// in the Study Library and Subject Details screens: a surface type
/// tile with a primary icon, a primary type label, title, muted meta
/// line, an optional primary status line, and a trailing chevron.
class StudyMaterialRow extends StatelessWidget {
  const StudyMaterialRow({
    required this.iconAsset,
    required this.typeLabel,
    required this.title,
    required this.meta,
    this.status,
    this.verticalPadding = 10,
    this.onTap,
    super.key,
  });

  /// Lucide SVG asset for the type tile.
  final String iconAsset;

  /// Uppercase type label, e.g. "DECK".
  final String typeLabel;

  final String title;

  /// Muted supporting line, e.g. "20 cards · 12 mastered · 3 difficult".
  final String meta;

  /// Optional primary status line, e.g. "Reviewed today".
  final String? status;

  /// Vertical padding around the row (10 in the library, 7 in subject
  /// details).
  final double verticalPadding;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SvgPicture.asset(
                iconAsset,
                width: 19,
                height: 19,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel,
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(title, style: AppTextStyles.itemTitle),
                  const SizedBox(height: 2),
                  Text(meta, style: AppTextStyles.caption),
                  if (status != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      status!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            SvgPicture.asset(
              'assets/icons/figma/chevron_right.svg',
              width: 10,
              height: 10,
              colorFilter: const ColorFilter.mode(
                AppColors.navInactive,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
