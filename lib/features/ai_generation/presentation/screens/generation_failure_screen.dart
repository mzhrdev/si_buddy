import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../widgets/generation_error_layout.dart';

/// Generation failure, implemented from the Figma frame
/// "SI Buddy · Generation failure" (5:849): the local AI could not
/// complete the set and no study material was saved.
class GenerationFailureScreen extends StatelessWidget {
  const GenerationFailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenerationErrorLayout(
      headline: 'Generation didn\u2019t finish',
      body:
          'The local AI couldn\u2019t complete this flashcard set. No new study material was saved.',
      guidance:
          'Retry with the same selections, or go back to setup to adjust them. Your source document is unchanged.',
      primaryLabel: 'Retry',
      onPrimary: () => context.pushReplacement(AppRoutes.generationProcessing),
      secondaryLabel: 'Back to Setup',
      onSecondary: () => context.pop(),
    );
  }
}
