import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/privacy_reassurance.dart';

/// Document details, implemented from the Figma frame
/// "SI Buddy · Document details" (4:5163).
///
/// Shows the document identity, original file, an extracted-text
/// preview, associated study sets, and a pinned management bar
/// (Rename / Export / Delete).
class DocumentDetailsScreen extends StatelessWidget {
  const DocumentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Document details', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                children: [
                  Text(
                    'Cell Biology - Chapter 4.pdf',
                    style: AppTextStyles.display,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Biology',
                          style: AppTextStyles.captionStrong.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Saved on this device',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _OriginalFileCard(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Extracted text', style: AppTextStyles.title),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.extractionReview),
                        child: Text('View all', style: AppTextStyles.link),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Cell Biology',
                              style: AppTextStyles.itemTitle,
                            ),
                            Text(
                              'Page 1 of 12',
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cells are the basic unit of life. Each cell contains structures that work together to support its functions.',
                          style: AppTextStyles.muted.copyWith(height: 20 / 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Associated study sets', style: AppTextStyles.title),
                      Text('2 sets', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _StudySetRow(
                    iconAsset: 'assets/icons/figma/gallery_vertical_end.svg',
                    title: 'Cell structures',
                    subtitle: '20 flashcards · Studied 20 min ago',
                    onTap: () => context.push(AppRoutes.deck),
                  ),
                  const SizedBox(height: 10),
                  _StudySetRow(
                    iconAsset: 'assets/icons/figma/list_checks.svg',
                    title: 'Cell structures',
                    subtitle: '10-question quiz · Created yesterday',
                    onTap: () => context.push(AppRoutes.history),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/pencil.svg',
                        label: 'Rename',
                        color: AppColors.primary,
                        onTap: () {
                          // TODO(backend): rename the document.
                        },
                      ),
                      const SizedBox(width: 8),
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/share_2.svg',
                        label: 'Export',
                        color: AppColors.primary,
                        onTap: () {
                          // TODO(backend): export the document.
                        },
                      ),
                      const SizedBox(width: 8),
                      _ManagementAction(
                        iconAsset: 'assets/icons/figma/trash_2.svg',
                        label: 'Delete',
                        color: AppColors.danger,
                        backgroundColor: AppColors.dangerSurface,
                        onTap: () => context.push(AppRoutes.deleteFile),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const PrivacyReassurance(
                    text: 'Your notes stay on your device.',
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

/// Card for the original file with its "Open original" action row.
class _OriginalFileCard extends StatelessWidget {
  const _OriginalFileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
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
                child: Text('PDF', style: AppTextStyles.badge),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original file',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'PDF · 2.4 MB · 12 pages',
                      style: AppTextStyles.muted.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/figma/file_text.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              // TODO(backend): open the original file.
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Open original', style: AppTextStyles.link),
                SvgPicture.asset(
                  'assets/icons/figma/arrow_up_right.svg',
                  width: 15,
                  height: 15,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One associated study set row (flashcards deck or quiz).
class _StudySetRow extends StatelessWidget {
  const _StudySetRow({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.itemTitle),
                    const SizedBox(height: 5),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/figma/chevron_right.svg',
                width: 16,
                height: 16,
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

/// One action in the bottom management bar (Rename / Export / Delete).
class _ManagementAction extends StatelessWidget {
  const _ManagementAction({
    required this.iconAsset,
    required this.label,
    required this.color,
    required this.onTap,
    this.backgroundColor,
  });

  final String iconAsset;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  iconAsset,
                  width: 15,
                  height: 15,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                Text(label, style: AppTextStyles.link.copyWith(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
