import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/documents_providers.dart';
import '../widgets/import_issue_layout.dart';
import '../widgets/selected_document_card.dart';

/// Damaged-document error, implemented from the Figma frame
/// "SI Buddy · Corrupted document" (4:3511).
class CorruptedDocumentScreen extends ConsumerWidget {
  const CorruptedDocumentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // When the user lands here from a failed import, the card shows
    // the file that failed; opened directly, it says there is no
    // document instead of the design's sample.
    final file = ref.watch(importJobProvider).file;
    return ImportIssueLayout(
      documentCard: SelectedDocumentCard(
        title: file?.name,
        subtitle: file == null
            ? null
            : '${file.format.label} · ${file.sizeLabel}',
        formatLabel: file?.format.label,
      ),
      iconAsset: 'assets/svgs/figma/file_warning.svg',
      iconColor: context.appDanger,
      surfaceColor: context.appDangerSurface,
      headline: 'This document won’t open.',
      body:
          'The PDF appears to be damaged or incomplete, so we couldn’t read its contents.',
      guidance: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Try a fresh copy', style: AppTextStyles.itemTitle(context)),
          const SizedBox(height: 8),
          Text(
            'Re-export the original document or download a fresh copy from its source. Check that it opens, then choose the new file.',
            style: AppTextStyles.muted(context).copyWith(height: 20 / 13),
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
