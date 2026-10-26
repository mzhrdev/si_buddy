import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Centered shield-check reassurance line shown at the bottom of the
/// document flow screens, e.g. "Nothing is uploaded. No internet needed."
class PrivacyReassurance extends StatelessWidget {
  const PrivacyReassurance({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/figma/shield_check.svg',
          width: 13,
          height: 13,
          colorFilter: const ColorFilter.mode(
            AppColors.navInactive,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }
}
