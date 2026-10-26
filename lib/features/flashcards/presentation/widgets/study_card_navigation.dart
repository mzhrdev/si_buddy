import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The Previous / Next row under the study card on both card faces.
class StudyCardNavigation extends StatelessWidget {
  const StudyCardNavigation({
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: _NavButton(
              iconAsset: 'assets/icons/figma/chevron_left.svg',
              label: 'Previous',
              onTap: onPrevious,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NavButton(
              iconAsset: 'assets/icons/figma/chevron_right.svg',
              label: 'Next',
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      iconAsset,
      width: 16,
      height: 16,
      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
    );
    final text = Text(
      label,
      style: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: AppColors.primary,
      ),
    );
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.zero,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [icon, const SizedBox(width: 8), text],
      ),
    );
  }
}
