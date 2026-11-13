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
          'generation needs the internet: your extracted text is '
          'sent to your online AI service to generate it.',
    ),
    (
      'How does AI generation work?',
      'Generation runs through your online AI service (Groq, via '
          'your own backend). It needs an internet connection; your '
          'documents and study sets stay on your device.',
    ),
    (
      'Why can’t I read a scanned PDF?',
      'Scanned, image-only PDFs are read automatically with on-device '
          'OCR during import. If OCR finds no readable text, try a '
          'clearer scan or a text-based version.',
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
                          for (final format in ['PDF', 'PPTX']) ...[
                            if (format != 'PDF') const SizedBox(width: 8),
                            Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: context.appSurfaceSubtle,
                                border: Border.all(color: context.appBorder),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  format,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    height: 16 / 12,
                                    color: context.appTextSecondary,
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
                          color: context.appCard,
                          border: Border.all(color: context.appBorder),
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
                              label: 'Groq AI Service',
                              supportingText:
                                  'Online AI generation · Manage AI Service',
                              showDivider: true,
                              onTap: () => context.push(AppRoutes.aiService),
                            ),
                            const SizedBox(height: 10),
                            const _VersionRow(
                              label: 'AI model',
                              value: 'gpt-oss-120b (Groq)',
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
          style: AppTextStyles.body(context).copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 18 / 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: AppTextStyles.greeting(context).copyWith(height: 18 / 12),
        ),
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
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.appSurfaceSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/figma/message_square.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  context.appTextSecondary,
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
                  style: AppTextStyles.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
                ),
                const SizedBox(height: 3),
                Text(
                  'Share an issue or suggestion',
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/figma/arrow_up_right.svg',
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(context.appPrimary, BlendMode.srcIn),
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
        Text(
          label,
          style: AppTextStyles.greeting(context).copyWith(height: 18 / 12),
        ),
        Text(
          value,
          style: AppTextStyles.greeting(
            context,
          ).copyWith(height: 18 / 12, color: context.appText),
        ),
      ],
    );
  }
}
