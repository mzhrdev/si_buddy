import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Square quick-action tile used in the Home dashboard's action row
/// (Generate Flashcards, Create Quiz, View Study Sets).
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    required this.iconAsset,
    required this.label,
    required this.onTap,
    super.key,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 82,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.text,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTextStyles.tileLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
