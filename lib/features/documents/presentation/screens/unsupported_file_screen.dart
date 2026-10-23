import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/import_issue_layout.dart';

/// Unsupported-format error, implemented from the Figma frame
/// "SI Buddy · Unsupported file" (4:3455): a .pages file was selected;
/// the recovery guidance lists the supported formats.
class UnsupportedFileScreen extends StatelessWidget {
  const UnsupportedFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ImportIssueLayout(
      documentCard: const _PagesDocumentCard(),
      iconAsset: 'assets/icons/figma/file_x_2.svg',
      // Figma: warning-text
      iconColor: AppColors.warningText,
      // Figma: warning-surface
      surfaceColor: AppColors.warningSurface,
      headline: 'This file type isn’t supported.',
      body:
          'We can’t import .pages files. Choose a PDF, Word or PowerPoint document instead.',
      guidance: const _SupportedFormatsGuidance(),
      primaryLabel: 'Choose another file',
      secondaryLabel: 'Back to import',
      onPrimary: () => context.pop(),
      onSecondary: () => context.pop(),
    );
  }
}

/// Selected-document card variant for the .pages file (the shared
/// card is PDF-specific).
class _PagesDocumentCard extends StatelessWidget {
  const _PagesDocumentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('PAGES', style: AppTextStyles.badge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cell Biology - Chapter 4.pages',
                  style: AppTextStyles.itemTitle.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text('Apple Pages · 2.4 MB', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Choose a supported format" heading, the PDF/DOCX/PPTX badges and
/// the export instruction.
class _SupportedFormatsGuidance extends StatelessWidget {
  const _SupportedFormatsGuidance();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose a supported format', style: AppTextStyles.itemTitle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final format in const ['PDF', 'DOCX', 'PPTX'])
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(format, style: AppTextStyles.captionStrong),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Export your notes in one of these formats, then select the new file.',
          style: AppTextStyles.muted.copyWith(height: 20 / 13),
        ),
      ],
    );
  }
}
