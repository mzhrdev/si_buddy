import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
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
/// file it shows an honest empty state. The first-page preview is a
/// neutral document illustration — the text is not extracted yet, so
/// it never shows the design's sample page content.
class SelectedFilePreviewScreen extends ConsumerStatefulWidget {
  const SelectedFilePreviewScreen({super.key});

  @override
  ConsumerState<SelectedFilePreviewScreen> createState() => _SelectedFilePreviewScreenState();
}

class _SelectedFilePreviewScreenState extends ConsumerState<SelectedFilePreviewScreen> {
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
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
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
                trailing: subject == current ? Icon(Icons.check, color: context.appPrimary) : null,
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
      // No file to import (the empty state has no import button, so
      // this only happens if the job is cleared mid-screen).
      return;
    }
    ref.read(extractionProvider.notifier).start(file: file, title: job.displayFileName, subject: job.subject);
    context.push(AppRoutes.extractionProcessing);
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(importJobProvider);
    final file = job.file;
    if (file == null) {
      return Scaffold(
        backgroundColor: context.appBackground,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Review document', onBack: () => context.pop()),
              const Expanded(
                child: EmptyState(
                  icon: Icons.description_outlined,
                  title: 'No document selected',
                  message: 'Pick a PDF or PPTX first — its preview and details will appear here.',
                ),
              ),
            ],
          ),
        ),
      );
    }
    final filename = job.displayFileName;
    final meta = <String>[
      file.format == DocumentFormat.pdf ? 'PDF document' : 'PPTX document',
      file.sizeLabel,
      if (file.pageCount != null) '${file.pageCount} ${file.format.unitLabel}',
    ];

    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Review document', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StateMessage(
                      headline: 'Ready to bring it in?',
                      body: 'Check your document and choose a subject.',
                    ),
                    const SizedBox(height: 22),
                    _DocumentPreview(filename: filename, pageCount: file.pageCount),
                    const SizedBox(height: 22),
                    _FileDetails(filename: filename, meta: meta, onRename: () => _rename(filename)),
                    const SizedBox(height: 22),
                    Text('Subject', style: AppTextStyles.itemTitle(context)),
                    const SizedBox(height: 8),
                    _SubjectField(subject: job.subject, onTap: () => _pickSubject(job.subject)),
                    const SizedBox(height: 8),
                    Text(
                      'Keep related notes together in your library.',
                      style: AppTextStyles.caption(context),
                    ),
                    const SizedBox(height: 24),
                    ImportPrimaryButton(label: 'Import document', onPressed: _import),
                    const SizedBox(height: 16),
                    const PrivacyReassurance(text: 'Your notes stay on your device.'),
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
/// Neutral first-page illustration for the picked file: the file
/// icon and name, with the page count when it is known. The text is
/// not extracted yet, so no page content is shown (and never the
/// design's sample page).
class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.filename, required this.pageCount});

  final String filename;
  final int? pageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 132,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: context.appChip, borderRadius: BorderRadius.circular(4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/figma/file_text.svg',
                  width: 32,
                  height: 38,
                  colorFilter: ColorFilter.mode(context.appPrimary, BlendMode.srcIn),
                ),
                const SizedBox(height: 10),
                Text(
                  filename,
                  style: AppTextStyles.caption(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(pageCount == null ? 'Page 1' : 'Page 1 of $pageCount', style: AppTextStyles.caption(context)),
        ],
      ),
    );
  }
}

/// Filename label row with the rename action, the filename itself and
/// the metadata chips.
class _FileDetails extends StatelessWidget {
  const _FileDetails({required this.filename, required this.meta, required this.onRename});

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
            Text('Filename', style: AppTextStyles.greeting(context).copyWith(fontWeight: FontWeight.w600)),
            InkWell(
              onTap: onRename,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/figma/pencil.svg',
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(context.appPrimary, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 5),
                    Text('Rename', style: AppTextStyles.link(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(filename, style: AppTextStyles.title(context)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final chip in meta)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: context.appChip,
                  border: Border.all(color: context.appBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(chip, style: AppTextStyles.caption(context)),
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
            border: Border.all(color: context.appBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma/book_open.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(context.appPrimary, BlendMode.srcIn),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(subject, style: AppTextStyles.body(context))),
              SvgPicture.asset(
                'assets/icons/figma/chevron_down.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(context.appNavInactive, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
