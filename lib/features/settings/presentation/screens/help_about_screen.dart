import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/settings_row.dart';

/// Help & About, implemented from the Figma frame
/// "SI Buddy · Help & About" (5:21010).
class HelpAboutScreen extends StatelessWidget {
  const HelpAboutScreen({super.key});

  static const _faqs = [
    (
      'Can I study offline?',
      'Yes. Saved documents and study sets work offline. New AI '
          'generation needs the installed model and enough device '
          'resources.',
    ),
    (
      'How do I download the model?',
      'Open AI Model in Settings. Use internet for the download; once '
          'installed, Gemma runs locally.',
    ),
    (
      'Why can’t I read a scanned PDF?',
      'Image-only scans need OCR first. Import a text-based PDF or an '
          'OCR-processed copy with selectable text.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Help & About', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  SettingsSection(
                    title: 'Supported file types',
                    children: [
                      Row(
                        children: [
                          for (final format in ['PDF', 'DOCX', 'PPTX']) ...[
                            if (format != 'PDF') const SizedBox(width: 8),
                            Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  format,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 16 / 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'Frequently asked questions',
                    children: [
                      for (var i = 0; i < _faqs.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _Faq(question: _faqs[i].$1, answer: _faqs[i].$2),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _FeedbackRow(),
                  const SizedBox(height: 16),
                  SettingsSection(
                    title: 'About SI Buddy',
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _VersionRow(
                              label: 'App version',
                              value: 'To be confirmed',
                            ),
                            const SizedBox(height: 10),
                            SettingsRow(
                              iconAsset: 'assets/icons/figma/cpu.svg',
                              label: 'Gemma 3 1B IT',
                              supportingText:
                                  'AI Ready Offline · Manage AI Model',
                              showDivider: true,
                              onTap: () => context.push(AppRoutes.readyOffline),
                            ),
                            const SizedBox(height: 10),
                            const _VersionRow(
                              label: 'Model version',
                              value: 'To be confirmed',
                            ),
                          ],
                        ),
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

/// One FAQ entry: semibold question (13) over a regular answer (12).
class _Faq extends StatelessWidget {
  const _Faq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 18 / 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(answer, style: AppTextStyles.greeting.copyWith(height: 18 / 12)),
      ],
    );
  }
}

/// The "Send feedback" row: icon chip and two-line details like a
/// settings row, but with an external-link arrow instead of a chevron.
class _FeedbackRow extends StatelessWidget {
  const _FeedbackRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/figma/message_square.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Send feedback',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Share an issue or suggestion',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/figma/arrow_up_right.svg',
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

/// A label/value line in the About card (12 regular; label muted,
/// value in the primary text color).
class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.greeting.copyWith(height: 18 / 12)),
        Text(
          value,
          style: AppTextStyles.greeting.copyWith(
            height: 18 / 12,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
