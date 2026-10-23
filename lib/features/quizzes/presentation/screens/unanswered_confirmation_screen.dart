import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Unanswered questions confirmation, implemented from the Figma
/// frame "SI Buddy · Unanswered Questions Confirmation" (5:6141).
/// In Figma the dialog overlays the last quiz question, so it is
/// built as a dimmed scaffold with a centred dialog card; the
/// parent question content behind it is intentionally omitted.
class UnansweredConfirmationScreen extends StatelessWidget {
  const UnansweredConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      textStyle: AppTextStyles.button,
    );
    return Scaffold(
      backgroundColor: const Color(0x99172033),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Submit with 2 unanswered questions?',
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: 16),
                Text(
                  'Questions 9 and 10 are unanswered. They will count '
                  'as incorrect if you submit now.',
                  style: AppTextStyles.body.copyWith(
                    height: 22 / 14,
                    color: AppColors.muted,
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
