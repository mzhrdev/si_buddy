import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// The 64px screen header used across the Figma designs.
///
/// Two forms:
/// - Tab roots (no [onBack]): brand mark + title on the left.
/// - Sub-screens ([onBack] given): back button on the left, title, and
///   the brand mark on the right.
class AppHeader extends StatelessWidget {
  const AppHeader({required this.title, this.onBack, this.trailing, super.key});

  final String title;

  /// When null, the header uses the tab-root (brand lockup) form.
  final VoidCallback? onBack;

  /// Optional widget shown at the right edge instead of the brand mark.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final brandMark = SvgPicture.asset(
      'assets/icons/figma/brand_mark.svg',
      width: 32,
      height: 32,
    );
    return SizedBox(
      height: 64,
      child: Padding(
        padding: EdgeInsets.only(left: onBack == null ? 24 : 8, right: 24),
        child: Row(
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, size: 22),
                color: AppColors.text,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 44,
                ),
                padding: EdgeInsets.zero,
              )
            else ...[
              brandMark,
              const SizedBox(width: 9),
            ],
            Expanded(child: Text(title, style: AppTextStyles.screenTitle)),
            if (trailing != null) trailing! else if (onBack != null) brandMark,
          ],
        ),
      ),
    );
  }
}
