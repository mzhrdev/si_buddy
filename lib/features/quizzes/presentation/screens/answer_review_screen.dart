import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../ai_generation/domain/generation_models.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';
import '../widgets/quiz_bottom_bar.dart';
import '../widgets/quiz_progress.dart';

/// Answer review, implemented from the Figma frame
/// "SI Buddy · Answer Review" (5:6297): the reviewed question with
/// the user's answer, the correct answer, an explanation and the
/// source reference. Previous / Next step through the review
/// locally.
///
/// The content comes from this session's quiz and answers. Without
/// a quiz it shows an honest empty state — never the design's
/// sample question and answers.
class AnswerReviewScreen extends ConsumerWidget {
  const AnswerReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final questions = result?.questions ?? const [];
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Answer review', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'Nothing to review yet',
                  message:
                      'Take a generated quiz to review your answers here.',
                  actionLabel: 'Generate a quiz',
                  onAction: () => context.push(AppRoutes.quizSetup),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final reviewIndex = ref
        .watch(reviewIndexProvider)
        .clamp(0, questions.length - 1);
    final question = questions[reviewIndex];
    final correctCount = questions
        .where((q) =>
            q.correctIndex != null && answers[q.prompt] == q.correctIndex)
        .length;
    final incorrectCount = questions.length - correctCount;
    String marker(int i) => String.fromCharCode('A'.codeUnitAt(0) + i);
    String yourAnswerText() {
      if (question.type == QuizQuestionType.shortAnswer) {
        final text = shortAnswers[question.prompt]?.trim() ?? '';
        return text.isEmpty ? 'No answer given' : text;
      }
      final chosen = answers[question.prompt];
      if (chosen == null) return 'No answer given';
      return '${marker(chosen)} · ${question.options[chosen]}';
    }
    String correctAnswerText() {
      if (question.type == QuizQuestionType.shortAnswer) {
        return question.expectedAnswer ?? 'No expected answer recorded';
      }
      if (question.correctIndex == null) return 'Not recorded';
      return '${marker(question.correctIndex!)} · ${question.options[question.correctIndex!]}';
    }
    final isCorrect = question.correctIndex != null &&
        answers[question.prompt] == question.correctIndex;
    final isAnswered = question.type == QuizQuestionType.shortAnswer
        ? (shortAnswers[question.prompt]?.trim().isNotEmpty ?? false)
        : answers.containsKey(question.prompt);
    final statusLabel = question.type == QuizQuestionType.shortAnswer
        ? (isAnswered ? 'Answered · not auto-scored' : 'Unanswered')
        : (isCorrect ? 'Correct' : 'Incorrect');
    final statusColor =
        isCorrect ? context.appSuccessText : context.appDanger;
    final sourceName = job.source?.document.originalFileName;
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Answer review', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QuizIdentity(
                      title: generatedMaterialTitle(
                        config: config,
                        documentName: sourceName,
                      ),
                      meta:
                          '$correctCount correct · $incorrectCount incorrect',
                    ),
                    const SizedBox(height: 16),
                    QuizProgressBar(
                      leftLabel:
                          'Question ${reviewIndex + 1} of ${questions.length}',
                      rightLabel: statusLabel,
                      rightLabelColor: statusColor,
                      fraction: (reviewIndex + 1) / questions.length,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${generatedMaterialTitle(config: config, documentName: sourceName)} · ${question.type.label}',
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      question.prompt,
                      style: AppTextStyles.screenTitle(context),
                    ),
                    const SizedBox(height: 14),
                    _AnswerCard(
                      background: isCorrect
                          ? context.appSuccessSurface
                          : context.appDangerSurface,
                      iconAsset: isCorrect
                          ? 'assets/icons/figma/check_circle_2.svg'
                          : 'assets/icons/figma/circle_x.svg',
                      iconColor: isCorrect ? context.appSuccess : context.appDanger,
                      label: 'Your answer',
                      labelColor:
                          isCorrect ? context.appSuccessText : context.appDanger,
                      value: yourAnswerText(),
                    ),
                    const SizedBox(height: 14),
                    _AnswerCard(
                      background: context.appSuccessSurface,
                      iconAsset: 'assets/icons/figma/check_circle_2.svg',
                      iconColor: context.appSuccess,
                      label: 'Correct answer',
                      labelColor: context.appSuccessText,
                      value: correctAnswerText(),
                    ),
                    if (question.explanation != null &&
                        question.explanation!.isNotEmpty) ...[
                      const SizedBox(height: 14),
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
                              'Why this is correct',
                              style: AppTextStyles.body(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              question.explanation!,
                              style: AppTextStyles.muted(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (sourceName != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.appBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma/file_text.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                context.appPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Source',
                                    style: AppTextStyles.caption(context),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sourceName,
                                    style: AppTextStyles.body(context).copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: context.appPrimary,
                                    ),
                                  ),
                                ],
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
            QuizBottomBar(
              leftLabel: 'Previous',
              rightLabel: 'Next',
              linkLabel: 'Back to Results',
              onLeft: () {
                if (reviewIndex > 0) {
                  ref.read(reviewIndexProvider.notifier).previous();
                } else {
                  context.pop();
                }
              },
              onRight: () {
                ref.read(reviewIndexProvider.notifier).next(questions.length);
              },
              onLink: () => context.push(AppRoutes.results),
            ),
          ],
        ),
      ),
    );
  }
}

/// Coloured answer comparison card: status icon beside a small
/// label and the answer text.
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.background,
    required this.iconAsset,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    required this.value,
  });

  final Color background;
  final String iconAsset;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption(context).copyWith(color: labelColor),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
