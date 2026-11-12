import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';

/// Unanswered questions confirmation, implemented from the Figma
/// frame "SI Buddy · Unanswered Questions Confirmation" (5:6141).
/// In Figma the dialog overlays the last quiz question, so it is
/// built as a dimmed scaffold with a centred dialog card; the
/// parent question content behind it is intentionally omitted.
///
/// The count and question numbers are this session's real
/// unanswered questions — never the design's sample "2" and "9
/// and 10". With none unanswered, the dialog says so.
class UnansweredConfirmationScreen extends ConsumerWidget {
  const UnansweredConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastGenerationResultProvider);
    final answers = ref.watch(quizAnswersProvider);
    final shortAnswers = ref.watch(quizShortAnswersProvider);
    final questions = result?.questions ?? const [];
    final unanswered = <int>[];
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final answered = answers.containsKey(q.prompt) ||
          (shortAnswers[q.prompt]?.trim().isNotEmpty ?? false);
      if (!answered) unanswered.add(i + 1);
    }
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      textStyle: AppTextStyles.button(context),
    );
    return Scaffold(
      backgroundColor: const Color(0x99111111),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.appCard,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  unanswered.isEmpty
                      ? 'All questions answered'
                      : 'Submit with ${unanswered.length} unanswered question${unanswered.length == 1 ? '' : 's'}?',
                  style: AppTextStyles.screenTitle(context),
                ),
                const SizedBox(height: 16),
                Text(
                  unanswered.isEmpty
                      ? 'Every question has an answer. You can submit now.'
                      : 'Question${unanswered.length == 1 ? '' : 's'} ${unanswered.join(', ')} ${unanswered.length == 1 ? 'is' : 'are'} unanswered. They will count '
                          'as incorrect if you submit now.',
                  style: AppTextStyles.body(context).copyWith(
                    height: 22 / 14,
                    color: context.appMuted,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: buttonStyle,
                  onPressed: () => context.pop(),
                  child: const Text('Return to Questions'),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  style: buttonStyle,
                  onPressed: () => context.push(AppRoutes.results),
                  child: const Text('Submit Anyway'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
