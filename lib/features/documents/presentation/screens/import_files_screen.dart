import 'dart:math' as math;

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

/// Import entry point, implemented from the Figma frame
/// "SI Buddy · Import files" (4:3267): a device-browser card with the
/// supported-format illustration and "Browse files" action, followed
/// by the recently imported documents.
class ImportFilesScreen extends StatelessWidget {
  const ImportFilesScreen({super.key});

  static const _recent = [
    _RecentDoc('PDF', 'Cell Biology · Chapter 4', '12 pages · 2.4 MB · Today'),
    _RecentDoc('PPTX', 'Organic Chemistry', '28 slides · 5.1 MB · Yesterday'),
    _RecentDoc('DOCX', 'Research Methods', '8 pages · 840 KB · Oct 12'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Import notes', onBack: () => context.pop()),
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
                          headline: 'Bring your notes.',
                          body:
                              'Choose a document from your Android device to add to your study space.',
                        ),
                        const SizedBox(height: 24),
                        _DeviceBrowserCard(
                          onBrowse: () =>
                              context.push(AppRoutes.selectedPreview),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recently imported',
                              style: AppTextStyles.title,
                            ),
                            Text('3 documents', style: AppTextStyles.caption),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final doc in _recent)
                          _RecentDocumentRow(
                            doc: doc,
                            onTap: () => context.push(AppRoutes.details),
                          ),
                      ],
                    ),
                    const PrivacyReassurance(
                      text: 'No account. No cloud. Just your notes.',
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

class _RecentDoc {
  const _RecentDoc(this.format, this.title, this.meta);

  final String format;
  final String title;
  final String meta;
}

/// White bordered card with the fanned supported-documents
/// illustration, the "Browse files" primary action and its caption.
class _DeviceBrowserCard extends StatelessWidget {
  const _DeviceBrowserCard({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          const _SupportedDocumentsIllustration(),
          const SizedBox(height: 14),
          Text(
            'Your files. One study space.',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 14),
          Text('Supports PDF, DOCX and PPTX', style: AppTextStyles.greeting),
          const SizedBox(height: 14),
          ImportPrimaryButton(label: 'Browse files', onPressed: onBrowse),
          const SizedBox(height: 14),
          Text('Opens your Android file picker', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Three fanned source-file cards (PDF tilted left, DOCX centred,
/// PPTX tilted right) from the Figma illustration.
class _SupportedDocumentsIllustration extends StatelessWidget {
  const _SupportedDocumentsIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 86,
      child: Stack(
        children: [
          Positioned(
            left: 19,
            top: 0,
            child: Transform.rotate(
              angle: -9 * math.pi / 180,
              child: const _SourceFileCard(label: 'PDF'),
            ),
          ),
          const Positioned(
            left: 81,
            top: 0,
            child: _SourceFileCard(label: 'DOCX'),
          ),
          Positioned(
            left: 132,
            top: 9,
            child: Transform.rotate(
              angle: 9 * math.pi / 180,
              child: const _SourceFileCard(label: 'PPTX'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceFileCard extends StatelessWidget {
  const _SourceFileCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/figma/file_text.svg',
            width: 17,
            height: 21,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

/// One "Recently imported" row: bordered format box, title and
/// metadata, and a chevron.
class _RecentDocumentRow extends StatelessWidget {
  const _RecentDocumentRow({required this.doc, required this.onTap});

  final _RecentDoc doc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 65,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(doc.format, style: AppTextStyles.badge),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: AppTextStyles.itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      doc.meta,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/figma/chevron_right.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.muted,
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
