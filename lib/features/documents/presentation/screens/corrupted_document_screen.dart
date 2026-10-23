import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/import_issue_layout.dart';
import '../widgets/selected_document_card.dart';

/// Damaged-document error, implemented from the Figma frame
/// "SI Buddy · Corrupted document" (4:3511).
class CorruptedDocumentScreen extends StatelessWidget {
  const CorruptedDocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImportIssueLayout(
      documentCard: const SelectedDocumentCard(
        title: 'Cell Biology - Chapter 4.pdf',
        subtitle: 'PDF · 2.4 MB',
      ),
      iconAsset: 'assets/icons/figma/file_warning.svg',
      iconColor: AppColors.danger,
      surfaceColor: AppColors.dangerSurface,
      headline: 'This document won’t open.',
      body:
          'The PDF appears to be damaged or incomplete, so we couldn’t read its contents.',
      guidance: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Try a fresh copy', style: AppTextStyles.itemTitle),
          const SizedBox(height: 8),
          Text(
            'Re-export the original document or download a fresh copy from its source. Check that it opens, then choose the new file.',
            style: AppTextStyles.muted.copyWith(height: 20 / 13),
          ),
        ],
      ),
      primaryLabel: 'Choose another file',
      secondaryLabel: 'Back to import',
      onPrimary: () => context.pop(),
      onSecondary: () => context.pop(),
    );
  }
}
