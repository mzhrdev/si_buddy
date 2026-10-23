import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import 'generation_selections.dart';
import 'generation_source_card.dart';

/// Shared layout for the AI generation error frames (missing model,
/// insufficient text, low memory, generation failure): the source
/// document card, a danger indicator chip with the state message, a
/// white recovery-guidance card, the preserved selections, then the
/// primary/secondary recovery actions and the privacy reassurance
/// pinned to the bottom.
class GenerationErrorLayout extends StatelessWidget {
  const GenerationErrorLayout({
    required this.headline,
    required this.body,
    required this.guidance,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    super.key,
  });

  final String headline;
  final String body;
  final String guidance;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'AI generation', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const GenerationSourceCard(),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.dangerSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/figma/circle_alert.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            AppColors.danger,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      headline,
                      style: AppTextStyles.display.copyWith(
                        letterSpacing: -0.48,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.muted,
                        height: 22 / 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What you can do',
                            style: AppTextStyles.itemTitle,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            guidance,
                            style: AppTextStyles.muted.copyWith(
                              height: 20 / 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const GenerationSelections(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: onPrimary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(primaryLabel),
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
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma/shield_check.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.navInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your notes stay on your device.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
