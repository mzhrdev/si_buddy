import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../providers/generation_providers.dart';
import '../widgets/generation_error_layout.dart';

/// Insufficient text error, implemented from the Figma frame
/// "SI Buddy · Insufficient text" (5:731): the extracted text is too
/// short to create the requested set.
///
/// The copy names the real request from the shared config (count,
/// material, topic) — never the design's sample "20 flashcards
/// about cell structures".
class InsufficientTextScreen extends ConsumerWidget {
  const InsufficientTextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(generationConfigProvider);
    final topic = config.topic.isEmpty ? null : config.topic;
    return GenerationErrorLayout(
      headline: 'Not enough usable text',
      body:
          'There isn’t enough usable extracted text to create ${config.count} ${config.materialType.materialNoun}${topic == null ? '' : ' about $topic'}.',
      guidance:
          'Review the extracted text for missing or incomplete passages, or choose a document with more text.',
      primaryLabel: 'Review Extracted Text',
      onPrimary: () => context.push(AppRoutes.extractionReview),
      secondaryLabel: 'Choose Another Document',
      onSecondary: () => context.pushReplacement(AppRoutes.importFiles),
    );
  }
}
