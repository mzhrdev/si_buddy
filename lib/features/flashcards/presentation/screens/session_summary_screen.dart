import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';

/// Session summary, implemented from the Figma frame
/// "SI Buddy · Session Summary" (5:2761).
///
/// The counts come from this session's ratings on the generated
/// deck. Without a deck it shows an honest empty state — never the
/// design's sample numbers.
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final ratings = ref.watch(cardRatingsProvider);
    final cards = result?.flashcards ?? const [];
    if (cards.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Session summary', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.style_outlined,
                  title: 'No study session yet',
                  message:
                      'Study a generated deck to see your session summary here.',
                  actionLabel: 'Generate flashcards',
                  onAction: () => context.push(AppRoutes.generationSetup),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final total = cards.length;
    final mastered = ratings.values.where((r) => r == 'Easy').length;
    final learning = ratings.values.where((r) => r == 'Medium').length;
    final difficult = ratings.values.where((r) => r == 'Hard').length;
    final reviewed = ratings.length;
    final toReview = learning + difficult;
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
                                  color: context.appSurface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  'assets/icons/figma/check_primary.svg',
                                  width: 26,
                                  height: 26,
                                  colorFilter: ColorFilter.mode(
                                    context.appPrimary,
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
                                style: AppTextStyles.display(context).copyWith(
                                  letterSpacing: -0.48,
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                '${generatedMaterialTitle(config: config, documentName: job.source?.document.originalFileName)} · $total flashcards',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.muted(context).copyWith(
                                  height: 20 / 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _SessionTotalsCard(reviewed: reviewed, total: total),
                            const SizedBox(height: 22),
                            _RatingRow(
                              iconAsset:
                                  'assets/icons/figma/check_circle_2.svg',
                              title: 'Mastered',
                              subtitle: 'Rated Easy',
                              value: '$mastered',
                            ),
                            const SizedBox(height: 18),
                            _RatingRow(
                              iconAsset: 'assets/icons/figma/refresh_cw.svg',
                              title: 'Learning',
                              subtitle: 'Rated Medium',
                              value: '$learning',
                            ),
                            const SizedBox(height: 18),
                            _RatingRow(
                              iconAsset: 'assets/icons/figma/flag.svg',
                              title: 'Difficult',
                              subtitle: 'Rated Hard',
                              value: '$difficult',
                            ),
                            if (toReview > 0) ...[
                              const SizedBox(height: 22),
                              Container(
                                decoration: BoxDecoration(
                                  color: context.appCard,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Keep the momentum',
                                      style: AppTextStyles.muted(context).copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: context.appText,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Review the $toReview learning and difficult cards again to make them stick.',
                                      style: AppTextStyles.body(context).copyWith(
                                        fontSize: 12,
                                        height: 18 / 12,
                                        color: context.appMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            colorFilter: ColorFilter.mode(
                              context.appCard,
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

/// The totals card: cards reviewed, duration, a progress track and
/// the "All cards reviewed this session" note. Duration is not
/// tracked yet, so it says so honestly instead of a sample time.
class _SessionTotalsCard extends StatelessWidget {
  const _SessionTotalsCard({required this.reviewed, required this.total});

  final int reviewed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Total(
                  value: '$reviewed / $total',
                  label: 'Cards reviewed',
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: _Total(value: 'Not tracked', label: 'Duration'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: total == 0 ? 0 : (reviewed / total).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: context.appPrimary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            reviewed >= total
                ? 'All cards reviewed this session'
                : 'Ratings are tracked this session only.',
            style: AppTextStyles.caption(context).copyWith(color: context.appPrimary),
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
          style: AppTextStyles.display(context).copyWith(
            fontSize: 28,
            height: 34 / 28,
            letterSpacing: -0.56,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 12,
            height: 18 / 12,
            color: context.appMuted,
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
            color: context.appSurface,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconAsset,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              context.appPrimary,
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
                style: AppTextStyles.body(context).copyWith(
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption(context)),
            ],
          ),
        ),
        Text(
          value,
          style: AppTextStyles.headline(context).copyWith(letterSpacing: -0.48),
        ),
      ],
    );
  }
}
