import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Status intro shared by the processing, success, failure and restore
/// frames: a 56px icon chip, the 24px headline and the supporting line.
class SubscriptionStatusHeader extends StatelessWidget {
  const SubscriptionStatusHeader({
    required this.iconAsset,
    required this.iconColor,
    required this.chipColor,
    required this.title,
    required this.body,
    super.key,
  });

  final String iconAsset;
  final Color iconColor;
  final Color chipColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: SvgPicture.asset(
            iconAsset,
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 12),
        Text(title, style: AppTextStyles.display),
        const SizedBox(height: 12),
        Text(
          body,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 20 / 13,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}
