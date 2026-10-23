import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/settings_row.dart';

/// Storage, implemented from the Figma frame "SI Buddy · Storage"
/// (5:20835). All figures are the design's illustrative mock values.
class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Storage', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  const _UsageCard(),
                  const SizedBox(height: 16),
                  SettingsRow(
                    iconAsset: 'assets/icons/figma/cpu.svg',
                    label: 'AI Model',
                    supportingText: 'Gemma 3 1B IT · AI Ready Offline',
                    trailingValue: 'To be confirmed',
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
                      Container(
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
                              'Cell Biology - Chapter 4.pdf',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PDF · 2.4 MB · 12 pages',
                              style: AppTextStyles.greeting,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => context.push(AppRoutes.details),
                                  child: Text(
                                    'View details',
                                    style: AppTextStyles.link,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      context.push(AppRoutes.deleteFile),
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
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
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Deleting a file also removes its extracted text. '
                        'Generated study sets and progress remain.',
                        style: AppTextStyles.greeting.copyWith(height: 18 / 12),
                      ),
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

/// The "Known content usage" card: total, segmented breakdown bar and
/// per-category totals.
class _UsageCard extends StatelessWidget {
  const _UsageCard();

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
            'Known-content usage · Illustrative',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 16 / 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '12.0 MB',
            style: TextStyle(
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
            'Excludes the unconfirmed model size. Not a complete app '
            'or device total.',
            style: AppTextStyles.greeting.copyWith(height: 18 / 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 75,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 3),
              Container(
                width: 25,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.accentMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _UsageCategory(
            name: 'Documents & extracted text',
            amount: '3.0 MB',
            detail: '2.4 MB source file + 0.6 MB extracted text',
          ),
          const SizedBox(height: 12),
          const _UsageCategory(
            name: 'Study materials',
            amount: '1.0 MB',
            detail: 'Flashcards, quizzes, summaries & progress',
          ),
          const SizedBox(height: 12),
          const _UsageCategory(name: 'Temporary cache', amount: '8.0 MB'),
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
