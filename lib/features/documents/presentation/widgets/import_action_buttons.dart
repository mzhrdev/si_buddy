import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Primary action for the import flow: the themed 56px [FilledButton]
/// with the design's forward-arrow icon after the label.
class ImportPrimaryButton extends StatelessWidget {
  const ImportPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
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
    );
  }
}

/// Secondary action for the import flow: a 48px outlined button with a
/// 14px semibold primary label (Figma "Secondary action").
class ImportSecondaryButton extends StatelessWidget {
  const ImportSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
        ),
        foregroundColor: AppColors.primary,
      ),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
