import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/generation_selections.dart';
import '../widgets/generation_source_card.dart';

/// Local generation processing, implemented from the Figma frame
/// "SI Buddy · Local generation processing" (5:596).
///
/// Static progress state from the design: 40%, with the three
/// generation stages (complete / active / upcoming) and the preserved
/// selections from setup.
class LocalGenerationProcessingScreen extends StatelessWidget {
  const LocalGenerationProcessingScreen({super.key});

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
                    Text(
                      'Creating your flashcards',
                      style: AppTextStyles.display.copyWith(
                        letterSpacing: -0.48,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The local AI is turning your reviewed text into study material.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.muted,
                        height: 22 / 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Generating cards',
                          style: AppTextStyles.link.copyWith(height: 16 / 12),
                        ),
                        Text(
                          '40%',
                          style: AppTextStyles.link.copyWith(height: 16 / 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const LinearProgressIndicator(
                        value: 0.4,
                        minHeight: 6,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This may take a minute. Keep SI Buddy open.',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                        height: 18 / 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _GenerationStages(),
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
                  Text(
                    'Model installed · Running on this device',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      height: 18 / 12,
                      color: AppColors.successText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // TODO(backend): cancel the generation job.
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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

/// The three-stage generation list inside its bordered card:
/// extraction complete, local AI generation in progress, then
/// check and save.
class _GenerationStages extends StatelessWidget {
  const _GenerationStages();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _StageRow(
            indicator: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SvgPicture.asset(
                'assets/icons/figma/check.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            title: 'Text extraction complete',
            subtitle: 'Reviewed source text is ready',
          ),
          const SizedBox(height: 20),
          _StageRow(
            indicator: SvgPicture.asset(
              'assets/icons/figma/stage_active.svg',
              width: 28,
              height: 28,
            ),
            title: 'Local AI generation',
            titleColor: AppColors.primary,
            subtitle: 'Building cards about cell structures',
          ),
          const SizedBox(height: 20),
          _StageRow(
            indicator: SvgPicture.asset(
              'assets/icons/figma/stage_upcoming.svg',
              width: 28,
              height: 28,
            ),
            title: 'Check and save',
            subtitle: 'Starts after generation finishes',
          ),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.indicator,
    required this.title,
    required this.subtitle,
    this.titleColor,
  });

  final Widget indicator;
  final String title;
  final String subtitle;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        indicator,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.itemTitle.copyWith(color: titleColor),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  height: 18 / 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
