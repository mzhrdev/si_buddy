import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/quiz_bottom_bar.dart';
import '../widgets/quiz_progress.dart';

/// Quiz question — short answer, implemented from the Figma frame
/// "SI Buddy · Quiz Question — Short Answer" (5:6077). The answer
/// field is pre-filled with the design's answer text and is fully
/// editable; its border uses the primary colour as in the design.
class QuizShortAnswerScreen extends StatefulWidget {
  const QuizShortAnswerScreen({super.key});

  @override
  State<QuizShortAnswerScreen> createState() => _QuizShortAnswerScreenState();
}

class _QuizShortAnswerScreenState extends State<QuizShortAnswerScreen> {
  final _controller = TextEditingController(
    text:
        'It controls what enters and leaves the cell, helping maintain '
        'a stable internal environment.',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Quiz', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const QuizIdentity(
                      title: 'Cell structures',
                      meta: 'Biology · 10 questions · Medium · Mixed',
                    ),
                    const SizedBox(height: 16),
                    const QuizProgressBar(
                      leftLabel: 'Question 8 of 10',
                      rightLabel: '8 / 10 answered',
                      fraction: 0.8,
                    ),
                    const SizedBox(height: 16),
                    const QuizTopicTimerRow(
                      topic: 'Membranes',
                      timeLeft: '04:10 left',
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SHORT ANSWER',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text('08 / 10', style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'What is the main function of the cell membrane?',
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Your answer',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _controller,
                              maxLines: null,
                              minLines: 6,
                              style: AppTextStyles.body.copyWith(
                                height: 22 / 14,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(14),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Answers are saved as you move between questions.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            QuizBottomBar(
              leftLabel: 'Previous',
              rightLabel: 'Next',
              linkLabel: 'Submit Quiz',
              onLeft: () => context.pop(),
              onRight: () => context.push(AppRoutes.unanswered),
              onLink: () => context.push(AppRoutes.unanswered),
            ),
          ],
        ),
      ),
    );
  }
}
