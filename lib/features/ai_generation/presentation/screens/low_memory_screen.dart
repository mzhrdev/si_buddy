import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/generation_error_layout.dart';

/// Low memory error, implemented from the Figma frame
/// "SI Buddy · Low memory" (5:790): the device does not have enough
/// free memory to run generation for this set.
class GenerationLowMemoryScreen extends StatelessWidget {
  const GenerationLowMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenerationErrorLayout(
      headline: 'Not enough free memory',
      body:
          'Your device doesn\u2019t have enough available memory to generate this set of 20 flashcards.',
      guidance:
          'Close other apps and reduce the count in setup. An installed model still needs free device memory to run.',
      primaryLabel: 'Reduce Count',
      onPrimary: () => context.pop(),
      secondaryLabel: 'Back to Setup',
      onSecondary: () => context.pop(),
    );
  }
}
