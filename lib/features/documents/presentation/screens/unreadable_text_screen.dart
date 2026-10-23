import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/documents_providers.dart';
import '../widgets/import_issue_layout.dart';
import '../widgets/selected_document_card.dart';

/// Garbled-text error, implemented from the Figma frame
/// "SI Buddy · Unreadable text" (4:3560).
class UnreadableTextScreen extends ConsumerWidget {
  const UnreadableTextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // When the user lands here from a failed import, the card shows
    // the file that failed; otherwise it keeps the design's sample.
    final file = ref.watch(importJobProvider).file;
    return ImportIssueLayout(
      documentCard: file == null
          ? const SelectedDocumentCard(
              title: 'Cell Biology - Chapter 4.pdf',
              subtitle: 'PDF · 2.4 MB',
            )
          : SelectedDocumentCard(
              title: file.name,
              subtitle: '${file.format.label} · ${file.sizeLabel}',
              formatLabel: file.format.label,
            ),
      iconAsset: 'assets/icons/figma/text_cursor_input.svg',
      // Figma: warning-text
      iconColor: AppColors.warningText,
      // Figma: warning-surface
      surfaceColor: AppColors.warningSurface,
      headline: 'We couldn’t read the text.',
      body:
          'The PDF opens, but its text is garbled or incorrectly encoded. It can’t be used for study tools yet.',
      guidance: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export a readable version', style: AppTextStyles.itemTitle),
          const SizedBox(height: 8),
          Text(
            'Export again from the original app as a text-based PDF or DOCX. Check that you can select and copy a sentence as readable text, then try that version.',
            style: AppTextStyles.muted.copyWith(height: 20 / 13),
          ),
        ],
      ),
      primaryLabel: 'Choose readable version',
      secondaryLabel: 'Back to import',
      onPrimary: () => context.pop(),
      onSecondary: () => context.pop(),
    );
  }
}
