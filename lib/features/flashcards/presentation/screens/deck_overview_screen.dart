import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';
import '../widgets/source_document_card.dart';

/// Deck overview, implemented from the Figma frame
/// "SI Buddy · Deck Overview" (5:2486).
///
/// When a flashcards generation has completed this session, the
/// title, language and card count come from that result and its
/// config; opened without one it keeps the design's sample deck.
class DeckOverviewScreen extends ConsumerWidget {
  const DeckOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final cards = result?.flashcards ?? const [];
    final hasRealDeck = cards.isNotEmpty;
    final cardCount = hasRealDeck ? cards.length : 20;
    final title = hasRealDeck ? config.topic : 'Cell structures';
    final language = hasRealDeck ? config.language : 'English';
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Flashcards', onBack: () => context.pop()),
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
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: Text(
                                    'Biology',
                                    style: AppTextStyles.tileLabel.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$cardCount flashcards · $language',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12,
                                    height: 18 / 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              style: AppTextStyles.display.copyWith(
                                fontSize: 28,
                                height: 34 / 28,
                                letterSpacing: -0.56,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Your generated deck is ready. Build confidence, one card at a time.',
                              style: AppTextStyles.muted.copyWith(
                                height: 20 / 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const SourceDocumentCard(),
                            const SizedBox(height: 24),
                            _StudyProgressCard(totalCards: cardCount),
                            const SizedBox(height: 24),
                            Text(
                              'A little recall goes a long way',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Think of your answer, reveal the card, then rate it Easy, Medium, or Hard to track your learning.',
                              style: AppTextStyles.muted.copyWith(
                                height: 20 / 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 48,
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => context.push(AppRoutes.editor),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/figma/pencil.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Edit cards',
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 20 / 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/figma/check_circle_2.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saved on this device · Available offline',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        ref.read(studyCardIndexProvider.notifier).reset();
                        context.push(AppRoutes.cardFront);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Start Studying'),
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

/// The "Your progress" card: reviewed count, an empty progress track
/// and the Mastered / Learning / New cards metrics.
class _StudyProgressCard extends StatelessWidget {
  const _StudyProgressCard({required this.totalCards});

  final int totalCards;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your progress',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ),
              Text(
                '0 / $totalCards reviewed',
                style: AppTextStyles.muted.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
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
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: _ProgressMetric(value: '0', label: 'Mastered'),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _ProgressMetric(value: '0', label: 'Learning'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressMetric(
                  value: '$totalCards',
                  label: 'New cards',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.headline.copyWith(letterSpacing: -0.48),
        ),
        const SizedBox(height: 3),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
