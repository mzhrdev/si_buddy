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
      backgroundColor: context.appBackground,
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
                          color: context.appDangerSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SvgPicture.asset(
                          'assets/svgs/figma/circle_alert.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            context.appDanger,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      headline,
                      style: AppTextStyles.display(context).copyWith(
                        letterSpacing: -0.48,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: AppTextStyles.body(context).copyWith(
                        color: context.appMuted,
                        height: 22 / 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.appCard,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What you can do',
                            style: AppTextStyles.itemTitle(context),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            guidance,
                            style: AppTextStyles.muted(context).copyWith(
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
                          'assets/svgs/figma/arrow_right.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            context.appCard,
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
                      side: BorderSide(color: context.appBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: context.appPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/figma/shield_check.svg',
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          context.appNavInactive,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your notes stay on your device.',
                        style: AppTextStyles.caption(context),
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
