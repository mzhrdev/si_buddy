import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../widgets/generation_error_layout.dart';

/// Missing model error, implemented from the Figma frame
/// "SI Buddy · Missing model" (5:672): generation cannot start
/// because no on-device AI model is installed yet.
class MissingModelScreen extends StatelessWidget {
  const MissingModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenerationErrorLayout(
      headline: 'Install an AI model first',
      body:
          'No AI model is installed. SI Buddy needs a local model before it can generate study material.',
      guidance:
          'Connect to the internet for the initial model download. Once installed, generation runs on your device.',
      primaryLabel: 'Open AI Model',
      onPrimary: () => context.push(AppRoutes.notInstalled),
      secondaryLabel: 'Back to Setup',
      onSecondary: () => context.pop(),
    );
  }
}
