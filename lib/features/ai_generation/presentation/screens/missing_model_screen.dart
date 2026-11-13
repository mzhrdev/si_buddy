import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../widgets/generation_error_layout.dart';

/// Missing AI service error, implemented from the Figma frame
/// "SI Buddy · Missing model" (5:672): generation cannot start
/// because this build has no AI service configured. Generation
/// runs through the app's backend proxy (Groq, via the app's own
/// proxy) — there is no on-device model to install anymore.
class MissingModelScreen extends StatelessWidget {
  const MissingModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenerationErrorLayout(
      headline: 'AI service not configured',
      body:
          'Generation needs your online AI service. This build '
          'doesn’t have one configured.',
      guidance:
          'Your extracted text is sent to your AI service to '
          'generate study material — generation always needs an '
          'internet connection.',
      primaryLabel: 'Open AI Model',
      onPrimary: () => context.push(AppRoutes.aiService),
      secondaryLabel: 'Back to Setup',
      onSecondary: () => context.pop(),
    );
  }
}
