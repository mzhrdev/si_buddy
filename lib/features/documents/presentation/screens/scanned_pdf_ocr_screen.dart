import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/import_issue_layout.dart';
import '../widgets/selected_document_card.dart';

/// Scanned-PDF error, implemented from the Figma frame
/// "SI Buddy · Scanned PDF requires OCR" (4:3609).
class ScannedPdfOcrScreen extends StatelessWidget {
  const ScannedPdfOcrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImportIssueLayout(
      documentCard: const SelectedDocumentCard(
        title: 'Cell Biology - Chapter 4.pdf',
        subtitle: 'PDF · 2.4 MB',
      ),
      iconAsset: 'assets/icons/figma/scan_text.svg',
      iconColor: AppColors.primary,
      surfaceColor: AppColors.surface,
      headline: 'This PDF needs OCR.',
      body:
          'These pages are scanned images, not selectable text. OCR is needed before SI Buddy can read them.',
      guidance: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Turn images into selectable text',
            style: AppTextStyles.itemTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Use a separate OCR tool to create a searchable PDF, or get a text-based export from the source. Then select that version here. OCR isn’t available in this import.',
            style: AppTextStyles.muted.copyWith(height: 20 / 13),
          ),
        ],
      ),
      primaryLabel: 'Choose text-based version',
      secondaryLabel: 'Back to import',
      onPrimary: () => context.pop(),
      onSecondary: () => context.pop(),
    );
  }
}
