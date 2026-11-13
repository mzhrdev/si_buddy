import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/layout/responsive_spacing.dart';

/// The library tab header: "Your library" (24 bold) with a document-count
/// subtitle on the left, and the 36px import action (surface
/// background, plus icon) on the right. Without an import action
/// nothing is shown on the right — no decorative brand mark.
class LibraryHeader extends StatelessWidget {
  const LibraryHeader({required this.subtitle, this.onImport, super.key});

  final String subtitle;

  /// When null, no action is shown on the right.
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.horizontal(context),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your library',
                    style: AppTextStyles.display(
                      context,
                    ).copyWith(letterSpacing: -0.48),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.caption(context)),
                ],
              ),
            ),
            if (onImport != null)
              Material(
                color: context.appSurface,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: onImport,
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgs/figma/plus.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          context.appPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
