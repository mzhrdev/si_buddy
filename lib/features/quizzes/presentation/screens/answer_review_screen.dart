import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../ai_generation/domain/generation_models.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';
import '../widgets/quiz_bottom_bar.dart';
import '../widgets/quiz_progress.dart';

/// Answer review, implemented from the Figma frame
/// "SI Buddy · Answer Review" (5:6297): the reviewed question with
/// the user's (incorrect) answer, the correct answer, an explanation
/// and the source reference. Previous / Next step through the review
/// locally (the content shown is the design's Question 3).
class AnswerReviewScreen extends ConsumerWidget {
  const AnswerReviewScreen({super.key});

  // Figma: success-surface
  static const _successSurface = AppColors.successSurface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final questions = result?.questions ?? const [];
    final hasRealResult = questions.isNotEmpty;
    final reviewIndex = hasRealResult
        ? ref.watch(reviewIndexProvider).clamp(0, questions.length - 1)
        : 0;
    final question = hasRealResult ? questions[reviewIndex] : null;
    final correctCount = questions
        .where((q) =>
            q.correctIndex != null && answers[q.prompt] == q.correctIndex)
        .length;
    final incorrectCount = questions.length - correctCount;
    String marker(int i) => String.fromCharCode('A'.codeUnitAt(0) + i);
    String yourAnswerText() {
      if (question == null) return 'B · A tissue';
      if (question.type == QuizQuestionType.shortAnswer) {
        final text = shortAnswers[question.prompt]?.trim() ?? '';
        return text.isEmpty ? 'No answer given' : text;
      }
      final chosen = answers[question.prompt];
      if (chosen == null) return 'No answer given';
      return '${marker(chosen)} · ${question.options[chosen]}';
    }
    String correctAnswerText() {
      if (question == null) return 'C · The cell';
      if (question.type == QuizQuestionType.shortAnswer) {
        return question.expectedAnswer ?? 'No expected answer recorded';
      }
      if (question.correctIndex == null) return 'Not recorded';
      return '${marker(question.correctIndex!)} · ${question.options[question.correctIndex!]}';
    }
    final isCorrect = question != null &&
        question.correctIndex != null &&
        answers[question.prompt] == question.correctIndex;
    final isAnswered = question != null &&
        (question.type == QuizQuestionType.shortAnswer
            ? (shortAnswers[question.prompt]?.trim().isNotEmpty ?? false)
            : answers.containsKey(question.prompt));
    final statusLabel = !hasRealResult
        ? 'Incorrect'
        : question!.type == QuizQuestionType.shortAnswer
            ? (isAnswered ? 'Answered · not auto-scored' : 'Unanswered')
            : (isCorrect ? 'Correct' : 'Incorrect');
    final statusColor = !hasRealResult || !isCorrect
        ? AppColors.danger
        : AppColors.successText;
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      title: hasRealResult ? config.topic : 'Cell structures',
                      meta: hasRealResult
                          ? '$correctCount correct · $incorrectCount incorrect'
                          : '7 correct · 3 incorrect, including 2 unanswered',
                    ),
                    const SizedBox(height: 16),
                    QuizProgressBar(
                      leftLabel: hasRealResult
                          ? 'Question ${reviewIndex + 1} of ${questions.length}'
                          : 'Question 3 of 10',
                      rightLabel: statusLabel,
                      rightLabelColor: statusColor,
                      fraction: hasRealResult
                          ? (reviewIndex + 1) / questions.length
                          : 0.3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      hasRealResult
                          ? '${config.topic} · ${question!.type.label}'
                          : 'Cell basics · Multiple choice',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      question?.prompt ?? 'What is the basic unit of life?',
                      style: AppTextStyles.screenTitle,
                    ),
                    const SizedBox(height: 14),
                    _AnswerCard(
                      background: isCorrect
                          ? AppColors.successSurface
                          : AppColors.dangerSurface,
                      iconAsset: isCorrect
                          ? 'assets/icons/figma/check_circle_2.svg'
                          : 'assets/icons/figma/circle_x.svg',
                      iconColor: isCorrect ? AppColors.success : AppColors.danger,
                      label: 'Your answer',
                      labelColor:
                          isCorrect ? AppColors.successText : AppColors.danger,
                      value: yourAnswerText(),
                    ),
                    const SizedBox(height: 14),
                    _AnswerCard(
                      background: _successSurface,
                      iconAsset: 'assets/icons/figma/check_circle_2.svg',
                      iconColor: AppColors.success,
                      label: 'Correct answer',
                      labelColor: AppColors.successText,
                      value: correctAnswerText(),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why this is correct',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            question?.explanation ??
                                'Cells are the basic unit of life. Each cell '
                                    'contains structures that work together to '
                                    'support its functions. A tissue is a group of '
                                    'similar cells working together.',
                            style: AppTextStyles.muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/figma/file_text.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Source · Page 1 of 12',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cell Biology - Chapter 4.pdf',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            QuizBottomBar(
              leftLabel: 'Previous',
              rightLabel: 'Next',
              linkLabel: 'Back to Results',
              onLeft: () {
                if (hasRealResult && reviewIndex > 0) {
                  ref.read(reviewIndexProvider.notifier).previous();
                } else {
                  context.pop();
                }
              },
              onRight: () {
                if (hasRealResult) {
                  ref
                      .read(reviewIndexProvider.notifier)
                      .next(questions.length);
                }
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
                  style: AppTextStyles.caption.copyWith(color: labelColor),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
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
