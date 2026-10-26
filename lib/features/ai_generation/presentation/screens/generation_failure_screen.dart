import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../providers/generation_providers.dart';
import '../widgets/generation_error_layout.dart';

/// Generation failure, implemented from the Figma frame
/// "SI Buddy · Generation failure" (5:849): the local AI could not
/// complete the set and no study material was saved.
class GenerationFailureScreen extends ConsumerWidget {
  const GenerationFailureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GenerationErrorLayout(
      headline: 'Generation didn\u2019t finish',
      body:
          'The local AI couldn\u2019t complete this flashcard set. No new study material was saved.',
      guidance:
          'Retry with the same selections, or go back to setup to adjust them. Your source document is unchanged.',
      primaryLabel: 'Retry',
      onPrimary: () {
        // Restart the failed job with the same source and selections
        // when one is still held; if none is (the screen was opened
        // directly), the processing screen shows its design state,
        // exactly as before.
        ref.read(generationJobProvider.notifier).retry();
        context.pushReplacement(AppRoutes.generationProcessing);
      },
      secondaryLabel: 'Back to Setup',
      onSecondary: () => context.pop(),
    );
  }
}
