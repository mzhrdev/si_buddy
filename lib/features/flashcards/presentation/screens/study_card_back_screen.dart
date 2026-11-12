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
import '../widgets/study_card_navigation.dart';
import '../widgets/study_session_header.dart';

/// Study card back (answer face), implemented from the Figma frame
/// "SI Buddy · Study Card Back" (5:2624).
///
/// With a generated deck this session, the answer comes from the
/// current card; otherwise an honest empty state shows — never the
/// design's sample card.
class StudyCardBackScreen extends ConsumerStatefulWidget {
  const StudyCardBackScreen({super.key});

  @override
  ConsumerState<StudyCardBackScreen> createState() =>
      _StudyCardBackScreenState();
}

class _StudyCardBackScreenState extends ConsumerState<StudyCardBackScreen> {
  bool _shuffleOn = false;
  bool _bookmarked = false;
  String? _rating;

  @override
  Widget build(BuildContext context) {
    final cards =
        ref.watch(lastGenerationResultProvider)?.flashcards ?? const [];
    if (cards.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Study flashcards', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.style_outlined,
                  title: 'No flashcards yet',
                  message:
                      'Generate flashcards from a document to study them here.',
                  actionLabel: 'Generate flashcards',
                  onAction: () => context.push(AppRoutes.generationSetup),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final reviewed = ref.watch(cardRatingsProvider).length;
    final index = ref.watch(studyCardIndexProvider).clamp(0, cards.length - 1);
    final card = cards[index];
    final counter = '${index + 1} / ${cards.length}';
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Study flashcards', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  children: [
                    StudySessionHeader(
                      title: generatedMaterialTitle(
                        config: config,
                        documentName: job.source?.document.originalFileName,
                      ),
                      subtitle:
                          '${config.language} · ${cards.length} flashcards',
                      index: index,
                      total: cards.length,
                      reviewed: reviewed,
                      shuffleOn: _shuffleOn,
                      bookmarked: _bookmarked,
                      onShuffleTap: () =>
                          setState(() => _shuffleOn = !_shuffleOn),
                      onBookmarkTap: () =>
                          setState(() => _bookmarked = !_bookmarked),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _AnswerCard(
                        question: card.front,
                        answer: card.back,
                        explanation: card.explanation ?? '',
                        counter: counter,
                        onShowQuestion: () => context.pop(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StudyCardNavigation(
                      onPrevious: () =>
                          ref.read(studyCardIndexProvider.notifier).previous(),
                      onNext: () => ref
                          .read(studyCardIndexProvider.notifier)
                          .next(cards.length),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        'How well did you know it? Choose a rating.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 12,
                          height: 18 / 12,
                          color: context.appMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          Expanded(
                            child: _RatingOption(
                              label: 'Easy',
                              sublabel: 'Mastered',
                              selected: _rating == 'Easy',
                              onTap: () => _selectRating('Easy'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _RatingOption(
                              label: 'Medium',
                              sublabel: 'Learning',
                              selected: _rating == 'Medium',
                              onTap: () => _selectRating('Medium'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _RatingOption(
                              label: 'Hard',
                              sublabel: 'Difficult',
                              selected: _rating == 'Hard',
                              onTap: () => _selectRating('Hard'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Once every card has a rating, the session has
                    // an end: the summary (counts, Study Again,
                    // Home). Before this, rating the last card left
                    // the user on the answer with nowhere to go —
                    // no save step is needed, the deck was saved
                    // when generation completed.
                    if (reviewed >= cards.length) ...[
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: () => context.push(AppRoutes.summary),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Finish session'),
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
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectRating(String rating) {
    final index = ref.read(studyCardIndexProvider);
    ref.read(cardRatingsProvider.notifier).rate(index, rating);
    // Persisted (Phase 5): the rating survives a restart and feeds
    // the statistics' cards-reviewed count. Best-effort inside the
    // notifier — the session rating above is already applied.
    unawaited(
      ref.read(generationJobProvider.notifier).recordCardReview(index, rating),
    );
    setState(() => _rating = rating);
  }
}

/// The white answer card: "ANSWER · 04 / 20", the question, the answer
/// with its explanation, the source line and "Show question".
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.question,
    required this.answer,
    required this.explanation,
    required this.counter,
    required this.onShowQuestion,
  });

  final String question;
  final String answer;
  final String explanation;
  final String counter;
  final VoidCallback onShowQuestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ANSWER',
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.appPrimary,
                  ),
                ),
              ),
              Text(counter, style: AppTextStyles.caption(context)),
            ],
          ),
          const Spacer(),
          Text(
            question,
            style: AppTextStyles.body(
              context,
            ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
          ),
          const SizedBox(height: 9),
          Text(
            answer,
            style: AppTextStyles.display(
              context,
            ).copyWith(fontSize: 28, height: 34 / 28, letterSpacing: -0.56),
          ),
          const SizedBox(height: 9),
          if (explanation.isNotEmpty)
            Text(
              explanation,
              style: AppTextStyles.muted(context).copyWith(height: 20 / 13),
            ),
          const Spacer(),
          Text(
            'Generated on this device',
            style: AppTextStyles.badge(
              context,
            ).copyWith(color: context.appMuted),
          ),
          const SizedBox(height: 9),
          InkWell(
            onTap: onShowQuestion,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/figma/rotate_ccw.svg',
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    context.appPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text('Show question', style: AppTextStyles.link(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One self-rating option (Easy / Medium / Hard) with its outcome label.
class _RatingOption extends StatelessWidget {
  const _RatingOption({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.appSurface : context.appBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: selected ? context.appPrimary : context.appBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.body(context).copyWith(
                fontWeight: FontWeight.w600,
                height: 20 / 14,
                color: context.appPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sublabel,
              style: AppTextStyles.badge(
                context,
              ).copyWith(color: context.appMuted),
            ),
          ],
        ),
      ),
    );
  }
}
