import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/documents_providers.dart';
import '../widgets/import_issue_layout.dart';
import '../widgets/selected_document_card.dart';

/// Scanned-PDF OCR result, implemented from the Figma frame
/// "SI Buddy · Scanned PDF requires OCR" (4:3609).
///
/// Shown when a PDF import completes with no readable text even after
/// on-device OCR ran over its scanned pages: the review would only
/// show empty pages, so the user gets the explanation and a way to
/// pick another file instead. The document card shows the real
/// imported file when the screen was reached from an extraction job,
/// and says there is no document when opened directly.
class ScannedPdfOcrScreen extends ConsumerWidget {
  const ScannedPdfOcrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(extractionProvider);
    final hasJob = state.file != null;
    return ImportIssueLayout(
      documentCard: SelectedDocumentCard(
        title: hasJob ? state.documentTitle : null,
        subtitle: hasJob ? state.documentSubtitle : null,
        formatLabel: state.file?.format.label,
      ),
      iconAsset: 'assets/svgs/figma/scan_text.svg',
      iconColor: context.appPrimary,
      surfaceColor: context.appSurface,
      headline: 'No readable text found.',
      body:
          'These pages are scanned images, and OCR couldn’t read any text from them.',
      guidance: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try a clearer scan or a text version',
            style: AppTextStyles.itemTitle(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Re-scan the pages at a higher contrast, or get a text-based export from the source — a PDF with selectable text — and import that version instead.',
            style: AppTextStyles.muted(context).copyWith(height: 20 / 13),
          ),
        ],
      ),
      primaryLabel: 'Choose text-based version',
      secondaryLabel: 'Back to import',
      onPrimary: () => context.pushReplacement(AppRoutes.importFiles),
      onSecondary: () => context.pop(),
    );
  }
}
