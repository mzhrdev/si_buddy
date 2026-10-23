import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';

/// Session summary, implemented from the Figma frame
/// "SI Buddy · Session Summary" (5:2761).
class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Session summary', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/icons/figma/check_primary.svg',
                                  width: 26,
                                  height: 26,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Nice work, study buddy.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.display.copyWith(
                                  letterSpacing: -0.48,
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Cell structures · 20 flashcards',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.muted.copyWith(
                                  height: 20 / 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            const _SessionTotalsCard(),
                            const SizedBox(height: 22),
                            const _RatingRow(
                              iconAsset:
                                  'assets/icons/figma/check_circle_2.svg',
                              title: 'Mastered',
                              subtitle: 'Rated Easy',
                              value: '12',
                            ),
                            const SizedBox(height: 18),
                            const _RatingRow(
                              iconAsset: 'assets/icons/figma/refresh_cw.svg',
                              title: 'Learning',
                              subtitle: 'Rated Medium',
                              value: '5',
                            ),
                            const SizedBox(height: 18),
                            const _RatingRow(
                              iconAsset: 'assets/icons/figma/flag.svg',
                              title: 'Difficult',
                              subtitle: 'Rated Hard',
                              value: '3',
                            ),
                            const SizedBox(height: 22),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Keep the momentum',
                                    style: AppTextStyles.muted.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Review the 8 learning and difficult cards again to make them stick.',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12,
                                      height: 18 / 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context.push(AppRoutes.cardFront),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Study Again'),
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
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: const Text('Home'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The totals card: cards reviewed, duration, a full progress track
/// and the "All cards reviewed this session" note.
class _SessionTotalsCard extends StatelessWidget {
  const _SessionTotalsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: _Total(value: '20 / 20', label: 'Cards reviewed'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _Total(value: '6m 24s', label: 'Duration'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'All cards reviewed this session',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.display.copyWith(
            fontSize: 28,
            height: 34 / 28,
            letterSpacing: -0.56,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 12,
            height: 18 / 12,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

/// One rating-breakdown row: icon chip, title/subtitle and the count.
class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconAsset,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.headline.copyWith(letterSpacing: -0.48),
        ),
      ],
    );
  }
}
