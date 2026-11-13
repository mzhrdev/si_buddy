import 'dart:async';

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
import '../../../ai_generation/presentation/widgets/generation_source_card.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../widgets/source_document_card.dart';

/// Deck overview, implemented from the Figma frame
/// "SI Buddy · Deck Overview" (5:2486).
///
/// When a flashcards generation has completed this session, the
/// title, language and card count come from that result and its
/// config, and the progress metrics from this session's ratings.
/// Opened without one it shows an honest empty state — never the
/// design's sample deck.
///
/// Viewing the deck starts a study session (Phase 5) and leaving
/// it ends the session with its real duration, so the statistics'
/// study time is genuine. The tracker ignores the call when a
/// session for this deck is already open (the `loadDeck` path), and
/// deletes the session when the visit never became real studying.
class DeckOverviewScreen extends ConsumerStatefulWidget {
  const DeckOverviewScreen({super.key});

  @override
  ConsumerState<DeckOverviewScreen> createState() => _DeckOverviewScreenState();
}

class _DeckOverviewScreenState extends ConsumerState<DeckOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deckId = ref.read(generationJobProvider).deckId;
      if (deckId == null) return;
      unawaited(
        ref
            .read(studySessionTrackerProvider.notifier)
            .start(deckId: deckId, type: 'flashcards'),
      );
    });
  }

  @override
  void dispose() {
    unawaited(ref.read(studySessionTrackerProvider.notifier).end());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              AppHeader(title: 'Flashcards', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.style_outlined,
                  title: 'No flashcards yet',
                  message:
                      'Generate flashcards from a document to study them here.',
                  actionLabel: 'Generate flashcards',
                  onAction: () => context.pushReplacement(AppRoutes.generationSetup),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final source = job.source;
    final subject = ref.watch(extractionProvider).subject;
    final title = generatedMaterialTitle(
      config: config,
      documentName: source?.document.originalFileName,
    );
    final language = config.language;
    final reviewed = ratings.length;
    final mastered = ratings.values.where((r) => r == 'Easy').length;
    final learning = ratings.values
        .where((r) => r == 'Medium' || r == 'Hard')
        .length;
    final newCards = cards.length - reviewed;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Flashcards', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (subject != null && subject.isNotEmpty) ...[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: context.appChip,
                                      border: Border.all(
                                        color: context.appBorder,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    child: Text(
                                      subject,
                                      style: AppTextStyles.tileLabel(context).copyWith(
                                        color: context.appTextSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  '${cards.length} flashcards · $language',
                                  style: AppTextStyles.body(context).copyWith(
                                    fontSize: 12,
                                    height: 18 / 12,
                                    color: context.appMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              style: AppTextStyles.display(context).copyWith(
                                fontSize: 28,
                                height: 34 / 28,
                                letterSpacing: -0.56,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Your generated deck is ready. Build confidence, one card at a time.',
                              style: AppTextStyles.muted(context).copyWith(
                                height: 20 / 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SourceDocumentCard(
                              title: source?.document.originalFileName,
                              subtitle: source == null
                                  ? null
                                  : generationSourceSubtitle(
                                      document: source.document,
                                      subject: subject,
                                    ),
                              formatLabel: source?.document.format.label,
                            ),
                            const SizedBox(height: 24),
                            _StudyProgressCard(
                              totalCards: cards.length,
                              reviewed: reviewed,
                              mastered: mastered,
                              learning: learning,
                              newCards: newCards,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'A little recall goes a long way',
                              style: AppTextStyles.body(context).copyWith(
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Think of your answer, reveal the card, then rate it Easy, Medium, or Hard to track your learning.',
                              style: AppTextStyles.muted(context).copyWith(
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
                                  side: BorderSide(
                                    color: context.appBorder,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svgs/figma/pencil.svg',
                                      width: 16,
                                      height: 16,
                                      colorFilter: ColorFilter.mode(
                                        context.appPrimary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Edit cards',
                                      style: AppTextStyles.body(context).copyWith(
                                        fontWeight: FontWeight.w600,
                                        height: 20 / 14,
                                        color: context.appPrimary,
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
                          'assets/svgs/figma/check_circle_2.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            context.appPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saved on this device · Available offline',
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: context.appPrimary,
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

/// The "Your progress" card: reviewed count, the progress track
/// and the Mastered / Learning / New cards metrics — all from this
/// session's ratings (0s until cards are rated).
class _StudyProgressCard extends StatelessWidget {
  const _StudyProgressCard({
    required this.totalCards,
    required this.reviewed,
    required this.mastered,
    required this.learning,
    required this.newCards,
  });

  final int totalCards;
  final int reviewed;
  final int mastered;
  final int learning;
  final int newCards;

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
                child: Text(
                  'Your progress',
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ),
              Text(
                '$reviewed / $totalCards reviewed',
                style: AppTextStyles.muted(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.appPrimary,
                ),
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
              widthFactor: totalCards == 0
                  ? 0
                  : (reviewed / totalCards).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: context.appPrimary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ProgressMetric(value: '$mastered', label: 'Mastered'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressMetric(value: '$learning', label: 'Learning'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProgressMetric(value: '$newCards', label: 'New cards'),
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
          style: AppTextStyles.headline(context).copyWith(letterSpacing: -0.48),
        ),
        const SizedBox(height: 3),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}
