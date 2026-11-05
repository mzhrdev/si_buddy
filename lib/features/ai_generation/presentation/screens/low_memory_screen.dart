import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/generation_providers.dart';
import '../widgets/generation_error_layout.dart';

/// Low memory error, implemented from the Figma frame
/// "SI Buddy · Low memory" (5:790): the device does not have enough
/// free memory to run generation for this set.
///
/// The copy names the real request from the shared config (count
/// and material) — never the design's sample "20 flashcards".
class GenerationLowMemoryScreen extends ConsumerWidget {
  const GenerationLowMemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(generationConfigProvider);
    return GenerationErrorLayout(
      headline: 'Not enough free memory',
      body:
          'Your device doesn’t have enough available memory to generate this set of ${config.count} ${config.materialType.materialNoun}.',
      guidance:
          'Close other apps and reduce the count in setup. An installed model still needs free device memory to run.',
      primaryLabel: 'Reduce Count',
      onPrimary: () => context.pop(),
      secondaryLabel: 'Back to Setup',
      onSecondary: () => context.pop(),
    );
  }
}
