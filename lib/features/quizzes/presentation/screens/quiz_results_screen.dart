import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';

/// Quiz results, implemented from the Figma frame
/// "SI Buddy · Quiz Results" (5:6216): score summary card, topic
/// performance bars and the follow-up actions. All actions are
/// primary buttons, matching the design.
class QuizResultsScreen extends StatelessWidget {
  const QuizResultsScreen({super.key});

  static const _topics = [
    ('Cell basics', '3 / 4 correct · 75%', 0.75),
    ('Organelles', '3 / 4 correct · 75%', 0.75),
    ('Membranes', '1 / 2 correct · 50%', 0.5),
  ];

  @override
  Widget build(BuildContext context) {
    final actionStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      textStyle: AppTextStyles.button,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Quiz results', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nice work, study buddy.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.display,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cell structures · 10 questions · Medium',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12,
                        height: 18 / 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '7 / 10',
                                      style: _scoreStyle(AppColors.text),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Questions correct',
                                      style: _subStyle(),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '70%',
                                    style: _scoreStyle(AppColors.primary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Duration · 6m 24s', style: _subStyle()),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: const LinearProgressIndicator(
                              value: 0.7,
                              minHeight: 6,
                              backgroundColor: AppColors.surface,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '7 correct',
                                style: _countStyle(AppColors.successText),
                              ),
                              Text(
                                '3 incorrect',
                                style: _countStyle(AppColors.danger),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Includes 2 unanswered, counted as incorrect.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Topic performance',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < _topics.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _TopicResult(
                        name: _topics[i].$1,
                        score: _topics[i].$2,
                        fraction: _topics[i].$3,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      style: actionStyle,
                      onPressed: () => context.push(AppRoutes.review),
                      child: const Text('Review Answers'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      style: actionStyle,
                      onPressed: () => context.push(AppRoutes.quizSetup),
                      child: const Text('Retry Quiz'),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      style: actionStyle,
                      onPressed: () => context.push(AppRoutes.generationSetup),
                      child: const Text('Generate Flashcards from Mistakes'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Use your 3 missed questions to focus your next review.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => context.push(AppRoutes.history),
                      child: SizedBox(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma/history.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'View Quiz History',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 18 / 13,
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
          ],
        ),
      ),
    );
  }

  static TextStyle _scoreStyle(Color color) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 38 / 32,
    letterSpacing: -0.64,
    color: color,
  );

  static TextStyle _subStyle() => AppTextStyles.body.copyWith(
    fontSize: 12,
    height: 18 / 12,
    color: AppColors.muted,
  );

  static TextStyle _countStyle(Color color) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: color,
  );
}

/// One topic row in the results: name, score label and progress bar.
class _TopicResult extends StatelessWidget {
  const _TopicResult({
    required this.name,
    required this.score,
    required this.fraction,
  });

  final String name;
  final String score;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppTextStyles.body.copyWith(fontSize: 13, height: 20 / 13),
            ),
            Text(
              score,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 16 / 12,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
