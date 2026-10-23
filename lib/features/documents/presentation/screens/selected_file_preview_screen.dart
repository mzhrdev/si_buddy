import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/document_models.dart';
import '../providers/documents_providers.dart';
import '../widgets/import_action_buttons.dart';
import '../widgets/privacy_reassurance.dart';
import '../widgets/state_message.dart';

/// Review step before importing, implemented from the Figma frame
/// "SI Buddy · Selected-file preview" (4:3338): first-page preview,
/// filename with a working rename dialog, metadata chips and a
/// subject picker, then the "Import document" action.
///
/// The filename, metadata chips and subject come from the picked file
/// in [importJobProvider]; renaming and subject changes are written
/// back to it. "Import document" starts extraction and continues to
/// the processing screen. When the screen is opened without a picked
/// file it keeps the design's sample content and flow.
class SelectedFilePreviewScreen extends ConsumerStatefulWidget {
  const SelectedFilePreviewScreen({super.key});

  @override
  ConsumerState<SelectedFilePreviewScreen> createState() =>
      _SelectedFilePreviewScreenState();
}

class _SelectedFilePreviewScreenState
    extends ConsumerState<SelectedFilePreviewScreen> {
  static const _subjects = ['Biology', 'Chemistry', 'Research Methods'];

  Future<void> _rename(String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Filename'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      ref.read(importJobProvider.notifier).setTitle(result);
    }
  }

  Future<void> _pickSubject(String current) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final subject in _subjects)
              ListTile(
                title: Text(subject),
                trailing: subject == current
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(subject),
              ),
          ],
        ),
      ),
    );
    if (result != null) {
      ref.read(importJobProvider.notifier).setSubject(result);
    }
  }

  void _import() {
    final job = ref.read(importJobProvider);
    final file = job.file;
    if (file == null) {
      // Opened without a picked file: keep the design's sample flow.
      context.push(AppRoutes.importLoading);
      return;
    }
    ref
        .read(extractionProvider.notifier)
        .start(file: file, title: job.displayFileName, subject: job.subject);
    context.push(AppRoutes.extractionProcessing);
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(importJobProvider);
    final file = job.file;
    final filename = file == null
        ? 'Cell Biology - Chapter 4.pdf'
        : job.displayFileName;
    final meta = file == null
        ? const ['PDF document', '2.4 MB', '12 pages']
        : <String>[
            file.format == DocumentFormat.pdf
                ? 'PDF document'
                : 'PPTX document',
            file.sizeLabel,
            if (file.pageCount != null)
              '${file.pageCount} ${file.format.unitLabel}',
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Review document', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const StateMessage(
                          headline: 'Ready to bring it in?',
                          body: 'Check your document and choose a subject.',
                        ),
                        const SizedBox(height: 22),
                        _DocumentPreview(pageCount: file?.pageCount ?? 12),
                        const SizedBox(height: 22),
                        _FileDetails(
                          filename: filename,
                          meta: meta,
                          onRename: () => _rename(filename),
                        ),
                        const SizedBox(height: 22),
                        Text('Subject', style: AppTextStyles.itemTitle),
                        const SizedBox(height: 8),
                        _SubjectField(
                          subject: job.subject,
                          onTap: () => _pickSubject(job.subject),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keep related notes together in your library.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ImportPrimaryButton(
                          label: 'Import document',
                          onPressed: _import,
                        ),
                        const SizedBox(height: 16),
                        const PrivacyReassurance(
                          text: 'Your notes stay on your device.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bordered preview card holding a miniature first page and the
/// "Page 1 of N" caption.
class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.pageCount});

  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 132,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHAPTER 4',
                  style: AppTextStyles.badge.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 7),
                Text('Cell Biology', style: AppTextStyles.itemTitle),
                const SizedBox(height: 7),
                Text(
                  'The building blocks of life',
                  style: AppTextStyles.badge.copyWith(color: AppColors.text),
                ),
                const SizedBox(height: 7),
                Text(
                  'Cells are the basic unit of life. Each cell contains structures that work together to support its functions.',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(height: 2, color: AppColors.surface),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Page 1 of $pageCount', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Filename label row with the rename action, the filename itself and
/// the metadata chips.
class _FileDetails extends StatelessWidget {
  const _FileDetails({
    required this.filename,
    required this.meta,
    required this.onRename,
  });

  final String filename;
  final List<String> meta;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Filename',
              style: AppTextStyles.greeting.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            InkWell(
              onTap: onRename,
              child: SizedBox(
                height: 28,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma/pencil.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text('Rename', style: AppTextStyles.link),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(filename, style: AppTextStyles.title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final chip in meta)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(chip, style: AppTextStyles.caption),
              ),
          ],
        ),
      ],
    );
  }
}

/// Bordered subject selector row: book icon, current subject and a
/// chevron-down.
class _SubjectField extends StatelessWidget {
  const _SubjectField({required this.subject, required this.onTap});

  final String subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma/book_open.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(subject, style: AppTextStyles.body)),
              SvgPicture.asset(
                'assets/icons/figma/chevron_down.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.navInactive,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
