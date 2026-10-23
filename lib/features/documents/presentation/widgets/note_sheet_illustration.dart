import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';

/// The 224×160 illustration shared by the empty-library and
/// search-no-results frames: a tilted note sheet with a file-text icon
/// and two text lines, accent dots, and a 64px surface badge carrying
/// [badgeIconAsset] (folder-plus / search-x).
class NoteSheetIllustration extends StatelessWidget {
  const NoteSheetIllustration({required this.badgeIconAsset, super.key});

  final String badgeIconAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 224,
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 22,
            top: 38,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 198,
            top: 108,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 60,
            top: 24,
            child: Transform.rotate(
              angle: -0.1745, // Figma: -10°
              child: Container(
                width: 76,
                height: 96,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma/file_text.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      width: 28,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 118,
            top: 72,
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.white, width: 5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SvgPicture.asset(
                badgeIconAsset,
                width: 29,
                height: 29,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
