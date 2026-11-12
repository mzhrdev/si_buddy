import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/document_failures.dart';
import '../providers/documents_providers.dart';
import '../widgets/import_issue_layout.dart';
import '../widgets/selected_document_card.dart';

/// Unsupported-format error, implemented from the Figma frame
/// "SI Buddy · Unsupported file" (4:3455): the picked file's type
/// is not one the app can import; the recovery guidance lists the
/// supported formats (PDF and PPTX only).
///
/// The card shows the rejected file's real name and extension from
/// the failed extraction (or the import job); opened without one it
/// says there is no document instead of the design's sample
/// .pages file.
class UnsupportedFileScreen extends ConsumerWidget {
  const UnsupportedFileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extraction = ref.watch(extractionProvider);
    final jobFile = ref.watch(importJobProvider).file;
    final error = extraction.error;
    final fileName = error is UnsupportedFormatException
        ? error.fileName
        : extraction.file?.name ?? jobFile?.name;
    final extension = fileName == null || !fileName.contains('.')
        ? null
        : fileName.split('.').last.toLowerCase();
    return ImportIssueLayout(
      documentCard: SelectedDocumentCard(
        title: fileName,
        subtitle: extension == null ? null : '.$extension file',
        formatLabel: extension?.toUpperCase(),
      ),
      iconAsset: 'assets/icons/figma/file_x_2.svg',
      // Figma: warning-text
      iconColor: context.appWarningText,
      // Figma: warning-surface
      surfaceColor: context.appWarningSurface,
      headline: 'This file type isn’t supported.',
      body: extension == null
          ? 'We can’t import this file type. Choose a PDF or PPTX document instead.'
          : 'We can’t import .$extension files. Choose a PDF or PPTX document instead.',
      guidance: const _SupportedFormatsGuidance(),
      primaryLabel: 'Choose another file',
      secondaryLabel: 'Back to import',
      onPrimary: () => context.pop(),
      onSecondary: () => context.pop(),
    );
  }
}

/// "Choose a supported format" heading, the PDF/PPTX badges and
/// the export instruction.
class _SupportedFormatsGuidance extends StatelessWidget {
  const _SupportedFormatsGuidance();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a supported format', style: AppTextStyles.itemTitle(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final format in const ['PDF', 'PPTX'])
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.appSurfaceSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(format, style: AppTextStyles.captionStrong(context)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Export your notes in one of these formats, then select the new file.',
          style: AppTextStyles.muted(context).copyWith(height: 20 / 13),
        ),
      ],
    );
  }
}
