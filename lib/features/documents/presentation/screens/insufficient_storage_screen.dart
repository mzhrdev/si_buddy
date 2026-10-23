import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/documents_providers.dart';
import '../widgets/import_issue_layout.dart';
import '../widgets/selected_document_card.dart';

/// Low-storage error, implemented from the Figma frame
/// "SI Buddy · Insufficient storage" (4:3658): the guidance card
/// compares the storage needed for the import with what is available.
class InsufficientStorageScreen extends ConsumerWidget {
  const InsufficientStorageScreen({super.key});

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
      iconAsset: 'assets/icons/figma/hard_drive.svg',
      // Figma: warning-text
      iconColor: AppColors.warningText,
      // Figma: warning-surface
      surfaceColor: AppColors.warningSurface,
      headline: 'A little more room needed.',
      body:
          'There isn’t enough device storage to save this document and its extracted text.',
      guidance: const _StorageGuidance(),
      primaryLabel: 'Manage device storage',
      secondaryLabel: 'Retry import',
      // TODO(backend): open the Android storage settings.
      onPrimary: () {},
      onSecondary: () => context.pop(),
    );
  }
}

/// "Free up at least 18 MB" heading, the needed/available comparison
/// with its proportion track, and the retry instruction.
class _StorageGuidance extends StatelessWidget {
  const _StorageGuidance();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Free up at least 18 MB', style: AppTextStyles.itemTitle),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('30 MB', style: AppTextStyles.screenTitle),
                const SizedBox(height: 3),
                Text('Needed for import', style: AppTextStyles.caption),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '12 MB',
                  style: AppTextStyles.screenTitle.copyWith(
                    // Figma: warning-text
                    color: AppColors.warningText,
                  ),
                ),
                const SizedBox(height: 3),
                Text('Available on device', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              Container(height: 5, color: AppColors.border),
              FractionallySizedBox(
                widthFactor: 12 / 30,
                child: Container(height: 5, color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Remove unneeded files in Android storage settings, then return here and retry.',
          style: AppTextStyles.muted.copyWith(height: 20 / 13),
        ),
      ],
    );
  }
}
