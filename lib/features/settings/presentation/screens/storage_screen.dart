import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../documents/domain/document_models.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../model_management/presentation/providers/model_providers.dart';
import '../widgets/settings_row.dart';

/// Storage, implemented from the Figma frame "SI Buddy · Storage"
/// (5:20835).
///
/// Every figure comes from real state: the documents total from the
/// library's live stream, the model from the model provider, and
/// study materials honestly at zero (decks and quizzes are kept in
/// memory this session only — nothing is persisted yet). Temporary
/// cache is not measured, so it is not listed. The local-files
/// section lists the real imported documents.
class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(documentsStreamProvider).value ?? const [];
    final modelReady = ref.watch(modelProvider).isReady;
    final documentsBytes = documents.fold<int>(
      0,
      (sum, doc) => sum + doc.sizeBytes,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Storage', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  _UsageCard(
                    documentsBytes: documentsBytes,
                    fileCount: documents.length,
                  ),
                  const SizedBox(height: 16),
                  SettingsRow(
                    iconAsset: 'assets/icons/figma/cpu.svg',
                    label: 'AI Model',
                    supportingText: modelReady
                        ? 'Gemma 3 1B IT · Installed'
                        : 'Gemma 3 1B IT · Not installed',
                    trailingValue: modelReady ? '~0.5 GB' : 'Not installed',
                    showDivider: true,
                    onTap: () => context.push(AppRoutes.readyOffline),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.clearCache),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/figma/eraser.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Clear Cache',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 20 / 14,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'Local files',
                    children: [
                      if (documents.isEmpty)
                        const EmptyState(
                          icon: Icons.folder_outlined,
                          title: 'No local files yet',
                          message:
                              'Import a document to see it listed here.',
                        )
                      else ...[
                        for (var i = 0; i < documents.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          _LocalFileCard(document: documents[i]),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Deleting a file also removes its extracted text. '
                          'Generated study sets and progress remain.',
                          style: AppTextStyles.greeting.copyWith(
                            height: 18 / 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One imported document's storage card: name, format/size/pages,
/// and the details and delete actions (both select the document
/// first, like the library does).
class _LocalFileCard extends ConsumerWidget {
  const _LocalFileCard({required this.document});

  final Document document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            document.originalFileName,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${document.format.label} · ${formatFileSize(document.sizeBytes)} · ${document.pageCount} ${document.format.unitLabel}',
            style: AppTextStyles.greeting,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(selectedDocumentIdProvider.notifier)
                      .select(document.id);
                  context.push(AppRoutes.details);
                },
                child: Text('View details', style: AppTextStyles.link),
              ),
              GestureDetector(
                onTap: () {
                  ref
                      .read(selectedDocumentIdProvider.notifier)
                      .select(document.id);
                  context.push(AppRoutes.deleteFile);
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'Delete File',
                      style: AppTextStyles.link.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The "Known content usage" card: total, breakdown bar and
/// per-category totals — all from the real documents total.
class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.documentsBytes, required this.fileCount});

  /// Sum of the imported files' sizes, in bytes.
  final int documentsBytes;

  /// Number of imported files.
  final int fileCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Known-content usage',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatFileSize(documentsBytes),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 34 / 28,
              letterSpacing: -0.56,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Excludes the AI model and temporary cache. Not a complete '
            'app or device total.',
            style: AppTextStyles.greeting.copyWith(height: 18 / 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: documentsBytes > 0
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UsageCategory(
            name: 'Documents & extracted text',
            amount: formatFileSize(documentsBytes),
            detail: fileCount == 0
                ? 'No files imported yet'
                : '$fileCount file${fileCount == 1 ? '' : 's'}',
          ),
          const SizedBox(height: 12),
          const _UsageCategory(
            name: 'Study materials',
            amount: '0 B',
            detail: 'Decks and quizzes are kept in memory this session only',
          ),
        ],
      ),
    );
  }
}

/// One usage category: name and total on one line (13 semibold),
/// optional detail line (11 muted) below.
class _UsageCategory extends StatelessWidget {
  const _UsageCategory({required this.name, required this.amount, this.detail});

  final String name;
  final String amount;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final totalStyle = AppTextStyles.body.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 18 / 13,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: totalStyle),
            Text(amount, style: totalStyle),
          ],
        ),
        if (detail != null) ...[
          const SizedBox(height: 3),
          Text(detail!, style: AppTextStyles.caption),
        ],
      ],
    );
  }
}
