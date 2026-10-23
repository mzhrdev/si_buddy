import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/quiz_bottom_bar.dart';
import '../widgets/quiz_progress.dart';

/// Quiz question — multiple choice, implemented from the Figma
/// frame "SI Buddy · Quiz Question — MCQ" (5:5927). The selected
/// option matches the design ("A tissue") and can be changed
/// locally; answers are presented as saved between questions.
class QuizMcqScreen extends StatefulWidget {
  const QuizMcqScreen({super.key});

  @override
  State<QuizMcqScreen> createState() => _QuizMcqScreenState();
}

class _QuizMcqScreenState extends State<QuizMcqScreen> {
  static const _options = [
    ('A', 'An organ'),
    ('B', 'A tissue'),
    ('C', 'The cell'),
    ('D', 'An organ system'),
  ];

  String _selected = 'B';

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
                      leftLabel: 'Question 3 of 10',
                      rightLabel: '3 / 10 answered',
                      fraction: 0.3,
                    ),
                    const SizedBox(height: 16),
                    const QuizTopicTimerRow(
                      topic: 'Cell basics',
                      timeLeft: '08:42 left',
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
                                  'MULTIPLE CHOICE',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text('03 / 10', style: AppTextStyles.caption),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'What is the basic unit of life?',
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Select one answer.',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (var i = 0; i < _options.length; i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              AnswerOptionTile(
                                marker: _options[i].$1,
                                label: _options[i].$2,
                                selected: _selected == _options[i].$1,
                                onTap: () =>
                                    setState(() => _selected = _options[i].$1),
                              ),
                            ],
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
              onRight: () => context.push(AppRoutes.trueFalse),
              onLink: () => context.push(AppRoutes.unanswered),
            ),
          ],
        ),
      ),
    );
  }
}
