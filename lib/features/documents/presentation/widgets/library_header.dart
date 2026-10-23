import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The library tab header: "Your library" (24 bold) with a document-count
/// subtitle on the left, and either the 36px import action (surface
/// background, plus icon) or — in the empty state — the brand mark on the
/// right.
class LibraryHeader extends StatelessWidget {
  const LibraryHeader({required this.subtitle, this.onImport, super.key});

  final String subtitle;

  /// When null, the brand mark is shown instead of the import action.
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your library',
                    style: AppTextStyles.display.copyWith(letterSpacing: -0.48),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (onImport != null)
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: onImport,
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/figma/plus.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              SvgPicture.asset(
                'assets/icons/figma/brand_mark.svg',
                width: 32,
                height: 32,
              ),
          ],
        ),
      ),
    );
  }
}
