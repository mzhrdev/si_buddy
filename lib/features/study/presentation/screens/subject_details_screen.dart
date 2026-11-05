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
import '../widgets/study_material_row.dart';
import '../widgets/study_progress_track.dart';

/// Subject Details, implemented from the Figma frame
/// "SI Buddy · Subject Details" (5:11584): subject identity, the
/// flashcard mastery card, study shortcuts, and the subject's
/// materials.
///
/// The materials are this session's generated deck and quiz, with
/// mastery from this session's ratings. Without any, the materials
/// section shows an honest empty state — never the design's sample
/// rows.
class SubjectDetailsScreen extends ConsumerWidget {
  const SubjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final ratings = ref.watch(cardRatingsProvider);
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final subject = ref.watch(extractionProvider).subject;
    final cards = result?.flashcards ?? const [];
    final questions = result?.questions ?? const [];
    final title = generatedMaterialTitle(
      config: config,
      documentName: job.source?.document.originalFileName,
    );
    final mastered = ratings.values.where((r) => r == 'Easy').length;
    final learning = ratings.values.where((r) => r == 'Medium').length;
    final difficult = ratings.values.where((r) => r == 'Hard').length;
    final reviewed = ratings.length;
    final toReview = cards.length - mastered;
    final answered = questions
        .where(
          (q) =>
              answers.containsKey(q.prompt) ||
              (shortAnswers[q.prompt]?.trim().isNotEmpty ?? false),
        )
        .length;
    final correct = questions
        .where((q) =>
            q.correctIndex != null && answers[q.prompt] == q.correctIndex)
        .length;
    final itemCount = (cards.isNotEmpty ? 1 : 0) + (questions.isNotEmpty ? 1 : 0);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Subject details', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                children: [
                  Text(
                    subject ?? 'All subjects',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 34 / 28,
                      letterSpacing: -0.56,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$itemCount study material${itemCount == 1 ? '' : 's'}',
                    style: AppTextStyles.greeting,
                  ),
                  const SizedBox(height: 16),
                  _MasteryCard(
                    total: cards.length,
                    mastered: mastered,
                    learning: learning,
                    difficult: difficult,
                    reviewed: reviewed,
                    title: title,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.push(AppRoutes.deck),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('Study deck'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.push(AppRoutes.cardFront),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(
                            toReview > 0
                                ? 'Review $toReview cards'
                                : 'Review cards',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your materials',
                          style: AppTextStyles.title,
                        ),
                      ),
                      Text('$itemCount items', style: AppTextStyles.link),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (cards.isNotEmpty)
                    StudyMaterialRow(
                      iconAsset: 'assets/icons/figma/layers.svg',
                      typeLabel: 'DECK',
                      title: title,
                      meta:
                          '${cards.length} cards · $mastered mastered · $difficult difficult',
                      verticalPadding: 7,
                      onTap: () => context.push(AppRoutes.deck),
                    ),
                  if (questions.isNotEmpty)
                    StudyMaterialRow(
                      iconAsset: 'assets/icons/figma/list_checks.svg',
                      typeLabel: 'QUIZ',
                      title: title,
                      meta: answered > 0
                          ? '${questions.length} questions · Latest score $correct/${questions.length}'
                          : '${questions.length} questions · Not taken yet',
                      verticalPadding: 7,
                      onTap: () => context.push(AppRoutes.history),
                    ),
                  if (itemCount == 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: EmptyState(
                        icon: Icons.school_outlined,
                        title: 'No study materials yet',
                        message:
                            'Generate flashcards or a quiz from a document to see them here.',
                      ),
                    ),
                  if (itemCount > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/figma/circle_check.svg',
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
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White bordered card with the flashcard mastery progress: heading,
/// progress track, the mastered/learning/difficult breakdown, and a
/// footnote about this session's reviews — all from this session's
/// ratings.
class _MasteryCard extends StatelessWidget {
  const _MasteryCard({
    required this.total,
    required this.mastered,
    required this.learning,
    required this.difficult,
    required this.reviewed,
    required this.title,
  });

  final int total;
  final int mastered;
  final int learning;
  final int difficult;
  final int reviewed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Flashcard mastery',
                  style: AppTextStyles.itemTitle,
                ),
              ),
              Text('$mastered / $total mastered', style: AppTextStyles.link),
            ],
          ),
          const SizedBox(height: 10),
          StudyProgressTrack(
            fraction: total == 0 ? 0 : mastered / total,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MasteryMetric(value: '$mastered', label: 'Mastered'),
              ),
              Expanded(
                child: _MasteryMetric(value: '$learning', label: 'Learning'),
              ),
              Expanded(
                child: _MasteryMetric(value: '$difficult', label: 'Difficult'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            total == 0
                ? 'No deck generated yet'
                : '$title · $reviewed/$total reviewed this session',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// One metric in the mastery breakdown: a large value over a muted
/// caption label.
class _MasteryMetric extends StatelessWidget {
  const _MasteryMetric({required this.value, required this.label});

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
        const SizedBox(height: 1),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
