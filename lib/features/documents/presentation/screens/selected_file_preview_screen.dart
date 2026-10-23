import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/import_action_buttons.dart';
import '../widgets/privacy_reassurance.dart';
import '../widgets/state_message.dart';

/// Review step before importing, implemented from the Figma frame
/// "SI Buddy · Selected-file preview" (4:3338): first-page preview,
/// filename with a working rename dialog, metadata chips and a
/// subject picker, then the "Import document" action.
class SelectedFilePreviewScreen extends StatefulWidget {
  const SelectedFilePreviewScreen({super.key});

  @override
  State<SelectedFilePreviewScreen> createState() =>
      _SelectedFilePreviewScreenState();
}

class _SelectedFilePreviewScreenState extends State<SelectedFilePreviewScreen> {
  static const _subjects = ['Biology', 'Chemistry', 'Research Methods'];

  String _filename = 'Cell Biology - Chapter 4.pdf';
  String _subject = 'Biology';

  Future<void> _rename() async {
    final controller = TextEditingController(text: _filename);
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
      setState(() => _filename = result);
    }
  }

  Future<void> _pickSubject() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final subject in _subjects)
              ListTile(
                title: Text(subject),
                trailing: subject == _subject
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(subject),
              ),
          ],
        ),
      ),
    );
    if (result != null) setState(() => _subject = result);
  }

  @override
  Widget build(BuildContext context) {
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
                        const _DocumentPreview(),
                        const SizedBox(height: 22),
                        _FileDetails(filename: _filename, onRename: _rename),
                        const SizedBox(height: 22),
                        Text('Subject', style: AppTextStyles.itemTitle),
                        const SizedBox(height: 8),
                        _SubjectField(subject: _subject, onTap: _pickSubject),
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
                          onPressed: () =>
                              context.push(AppRoutes.importLoading),
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
/// "Page 1 of 12" caption.
class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview();

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
          Text('Page 1 of 12', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Filename label row with the rename action, the filename itself and
/// the metadata chips.
class _FileDetails extends StatelessWidget {
  const _FileDetails({required this.filename, required this.onRename});

  final String filename;
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
            for (final meta in const ['PDF document', '2.4 MB', '12 pages'])
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(meta, style: AppTextStyles.caption),
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
