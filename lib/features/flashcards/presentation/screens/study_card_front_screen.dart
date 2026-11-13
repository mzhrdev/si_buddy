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

/// Study card front (question face), implemented from the Figma frame
/// "SI Buddy · Study Card Front" (5:2558).
///
/// With a generated deck this session, the question and counter come
/// from the current card; otherwise an honest empty state shows —
/// never the design's sample card.
class StudyCardFrontScreen extends ConsumerStatefulWidget {
  const StudyCardFrontScreen({super.key});

  @override
  ConsumerState<StudyCardFrontScreen> createState() =>
      _StudyCardFrontScreenState();
}

class _StudyCardFrontScreenState extends ConsumerState<StudyCardFrontScreen> {
  bool _shuffleOn = false;
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(lastGenerationResultProvider)?.flashcards ?? const [];
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
                  onAction: () => context.pushReplacement(AppRoutes.generationSetup),
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
    final question = cards[index].front;
    final counter = '${index + 1} / ${cards.length}';
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Study flashcards', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    StudySessionHeader(
                      title: generatedMaterialTitle(
                        config: config,
                        documentName:
                            job.source?.document.originalFileName,
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
                    const SizedBox(height: 16),
                    Expanded(
                      child: _QuestionCard(
                        question: question,
                        counter: counter,
                        onTap: _showAnswer,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StudyCardNavigation(
                      onPrevious: () => ref
                          .read(studyCardIndexProvider.notifier)
                          .previous(),
                      onNext: () => ref
                          .read(studyCardIndexProvider.notifier)
                          .next(cards.length),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        'Reveal the answer before rating this card.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 12,
                          height: 18 / 12,
                          color: context.appMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    FilledButton(
                      onPressed: _showAnswer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Show Answer'),
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

  void _showAnswer() => context.push(AppRoutes.cardBack);
}

/// The white question card: "QUESTION · 04 / 20", the question text and
/// the "Tap card to reveal" hint.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.counter,
    required this.onTap,
  });

  final String question;
  final String counter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: context.appBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'QUESTION',
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
              SizedBox(
                width: double.infinity,
                child: Text(
                  question,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.display(context).copyWith(letterSpacing: -0.48),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/figma/rotate_3d.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      context.appPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap card to reveal',
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 12,
                      height: 18 / 12,
                      color: context.appPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
