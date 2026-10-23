import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../widgets/generation_error_layout.dart';

/// Insufficient text error, implemented from the Figma frame
/// "SI Buddy · Insufficient text" (5:731): the extracted text is too
/// short to create the requested set of 20 flashcards.
class InsufficientTextScreen extends StatelessWidget {
  const InsufficientTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GenerationErrorLayout(
      headline: 'Not enough usable text',
      body:
          'There isn\u2019t enough usable extracted text to create 20 flashcards about cell structures.',
      guidance:
          'Review the extracted text for missing or incomplete passages, or choose a document with more text.',
      primaryLabel: 'Review Extracted Text',
      onPrimary: () => context.push(AppRoutes.extractionReview),
      secondaryLabel: 'Choose Another Document',
      onSecondary: () => context.push(AppRoutes.importFiles),
    );
  }
}
