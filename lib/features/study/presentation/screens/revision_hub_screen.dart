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
import '../../../documents/presentation/providers/documents_providers.dart';
import '../widgets/study_destinations_bar.dart';

/// Revision Hub, implemented from the Figma frame
/// "SI Buddy · Revision Hub" (5:11704): the saved review collections
/// (bookmarks, difficult cards, incorrect answers), each with a
/// representative item and a review action.
///
/// Only collections with real session data appear: cards rated Hard
/// this session, and questions answered incorrectly (or left
/// unanswered) this session. Bookmarks are not tracked yet, so that
/// category is hidden until bookmarking lands. With nothing to
/// revise, the screen says so honestly.
class RevisionHubScreen extends ConsumerWidget {
  const RevisionHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastGenerationResultProvider);
    final ratings = ref.watch(cardRatingsProvider);
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final subject = ref.watch(extractionProvider).subject;
    final cards = result?.flashcards ?? const [];
    final questions = result?.questions ?? const [];
    final difficultIndexes = ratings.entries
        .where((e) => e.value == 'Hard' && e.key < cards.length)
        .map((e) => e.key)
        .toList();
    final incorrect = questions
        .where(
          (q) =>
              q.correctIndex != null &&
              answers.containsKey(q.prompt) &&
              answers[q.prompt] != q.correctIndex,
        )
        .toList();
    final unanswered = questions
        .where(
          (q) =>
              !answers.containsKey(q.prompt) &&
              (shortAnswers[q.prompt]?.trim().isNotEmpty ?? false) == false,
        )
        .toList();
    final incorrectCount = incorrect.length + unanswered.length;
    final correct = questions
        .where((q) =>
            q.correctIndex != null && answers[q.prompt] == q.correctIndex)
        .length;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Revision hub'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                children: [
                  const StudyDestinationsBar(currentIndex: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Focus on what needs practice.',
                    style: AppTextStyles.display.copyWith(letterSpacing: -0.48),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject == null
                        ? 'Your saved review collections'
                        : '$subject · Your saved review collections',
                    style: AppTextStyles.greeting,
                  ),
                  const SizedBox(height: 16),
                  if (difficultIndexes.isNotEmpty) ...[
                    _RevisionCategory(
                      iconAsset: 'assets/icons/figma/flag.svg',
                      title: 'Difficult cards',
                      count: '${difficultIndexes.length} cards',
                      materialTitle: cards[difficultIndexes.first].front,
                      materialMeta: 'Rated Hard this session',
                      actionLabel: 'Review difficult cards',
                      onAction: () {
                        ref
                            .read(studyCardIndexProvider.notifier)
                            .set(difficultIndexes.first);
                        context.push(AppRoutes.cardFront);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (incorrectCount > 0) ...[
                    _RevisionCategory(
                      iconAsset: 'assets/icons/figma/circle_x.svg',
                      title: 'Incorrect answers',
                      count: '$incorrectCount questions',
                      materialTitle: (incorrect.isNotEmpty
                              ? incorrect.first
                              : unanswered.first)
                          .prompt,
                      materialMeta:
                          'Latest quiz: $correct/${questions.length} correct',
                      note: unanswered.isNotEmpty
                          ? 'Includes ${unanswered.length} unanswered question${unanswered.length == 1 ? '' : 's'}.'
                          : null,
                      actionLabel: 'Review incorrect answers',
                      onAction: () => context.push(AppRoutes.review),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (difficultIndexes.isEmpty && incorrectCount == 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: EmptyState(
                        icon: Icons.refresh_outlined,
                        title: 'Nothing to revise yet',
                        message:
                            'Cards you rate Hard and questions you answer incorrectly will appear here for review.',
                      ),
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

/// One revision category card: icon + title + count heading, a
/// representative material, an optional bold note, and a full-width
/// primary review button.
class _RevisionCategory extends StatelessWidget {
  const _RevisionCategory({
    required this.iconAsset,
    required this.title,
    required this.count,
    required this.materialTitle,
    required this.materialMeta,
    required this.actionLabel,
    required this.onAction,
    this.note,
  });

  final String iconAsset;
  final String title;
  final String count;
  final String materialTitle;
  final String materialMeta;
  final String? note;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ),
              Text(count, style: AppTextStyles.captionAccent),
            ],
          ),
          const SizedBox(height: 10),
          Text(materialTitle, style: AppTextStyles.itemTitle),
          const SizedBox(height: 3),
          Text(materialMeta, style: AppTextStyles.caption),
          if (note != null) ...[
            const SizedBox(height: 3),
            Text(
              note!,
              style: AppTextStyles.badge.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
