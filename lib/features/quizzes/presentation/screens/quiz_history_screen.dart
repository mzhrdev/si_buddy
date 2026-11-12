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
import '../widgets/quiz_progress.dart';
import '../widgets/quiz_source_card.dart';

/// Quiz history, implemented from the Figma frame
/// "SI Buddy · Quiz History" (5:6367): the quiz and its source
/// document, followed by the previous attempts with review and
/// retry actions for each attempt.
///
/// Quiz attempts are not persisted yet, so the only attempt shown
/// is this session's quiz, scored from its real answers. Without
/// a quiz it shows an honest empty state — never sample attempts.
class QuizHistoryScreen extends ConsumerWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastGenerationResultProvider);
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final answers = ref.watch(quizAnswersProvider);
    final questions = result?.questions ?? const [];
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Quiz history', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.history_outlined,
                  title: 'No quiz history yet',
                  message:
                      'Take a generated quiz to see your attempts and scores here.',
                  actionLabel: 'Generate a quiz',
                  onAction: () => context.push(AppRoutes.quizSetup),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final correct = questions
        .where((q) =>
            q.correctIndex != null && answers[q.prompt] == q.correctIndex)
        .length;
    final total = questions.length;
    final percent = total == 0 ? 0 : (correct * 100 ~/ total);
    final source = job.source;
    final subject = ref.watch(extractionProvider).subject;
    final attempt = _Attempt(
      date: 'This session',
      latest: true,
      score: '$correct / $total',
      percent: '$percent%',
      duration: 'Not tracked',
    );
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Quiz history', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    QuizIdentity(
                      title: generatedMaterialTitle(
                        config: config,
                        documentName: source?.document.originalFileName,
                      ),
                      meta:
                          '${config.language} · $total questions · ${config.difficulty.label} · ${config.materialType.label}',
                      titleStyle: AppTextStyles.display(context),
                    ),
                    const SizedBox(height: 16),
                    QuizSourceCard(
                      title: source?.document.originalFileName,
                      subtitle: source == null
                          ? null
                          : generationSourceSubtitle(
                              document: source.document,
                              subject: subject,
                            ),
                      formatLabel: source?.document.format.label,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Previous attempts',
                          style: AppTextStyles.body(context).copyWith(
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                          ),
                        ),
                        Text(
                          '1 attempt',
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 12,
                            height: 18 / 12,
                            color: context.appMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _AttemptCard(attempt: attempt),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/figma/check_circle_2.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            context.appPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Saved quizzes can be studied offline.',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.appPrimary,
                          ),
                        ),
                      ],
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

/// One quiz attempt: this session's quiz, scored from its real
/// answers. Duration is not tracked yet, so it says so.
class _Attempt {
  const _Attempt({
    required this.date,
    required this.latest,
    required this.score,
    required this.percent,
    required this.duration,
  });

  final String date;
  final bool latest;
  final String score;
  final String percent;
  final String duration;
}

/// One attempt card: date (with a LATEST tag on the newest attempt),
/// score + percentage + duration, and Review / Retry Quiz actions.
class _AttemptCard extends StatelessWidget {
  const _AttemptCard({required this.attempt});

  final _Attempt attempt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                attempt.date,
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                ),
              ),
              if (attempt.latest)
                Text(
                  'LATEST',
                  style: AppTextStyles.badge(context).copyWith(color: context.appPrimary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(attempt.score, style: AppTextStyles.headline(context)),
              const SizedBox(width: 8),
              Text(
                attempt.percent,
                style: AppTextStyles.body(context).copyWith(
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: context.appPrimary,
                ),
              ),
              const Spacer(),
              Text(
                attempt.duration,
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  height: 18 / 12,
                  color: context.appMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _AttemptAction(
                  iconAsset: 'assets/icons/figma/list_checks.svg',
                  label: 'Review',
                  onTap: () => context.push(AppRoutes.review),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AttemptAction(
                  iconAsset: 'assets/icons/figma/rotate_ccw.svg',
                  label: 'Retry Quiz',
                  onTap: () => context.push(AppRoutes.quizSetup),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 36px bordered action button inside an attempt card.
class _AttemptAction extends StatelessWidget {
  const _AttemptAction({
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appCard,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 15,
                height: 15,
                colorFilter: ColorFilter.mode(
                  context.appPrimary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: context.appPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
