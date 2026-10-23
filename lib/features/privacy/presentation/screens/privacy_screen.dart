import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';

/// Section title (14, SemiBold, lh 20).
const _sectionTitleStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 20 / 14,
  color: AppColors.text,
);

/// Body copy on this screen (13, Regular, muted, lh 20).
const _bodyMutedStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 13,
  fontWeight: FontWeight.w400,
  height: 20 / 13,
  color: AppColors.muted,
);

/// Privacy, implemented from the Figma frame "SI Buddy · Privacy"
/// (5:20931).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Privacy', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  Container(
                    width: double.infinity,
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
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma/shield_check.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Your notes stay on your device',
                              style: _sectionTitleStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Document reading and text extraction happen '
                          'locally. With Gemma 3 1B IT installed, AI '
                          'study-material generation also runs on your '
                          'device.',
                          style: _bodyMutedStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No account needed.',
                          style: AppTextStyles.link.copyWith(height: 16 / 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'When internet is needed',
                    style: _sectionTitleStyle,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The initial model download and any re-download need '
                    'internet, as do Google Play purchases and restoring '
                    'purchases.',
                    style: _bodyMutedStyle,
                  ),
                  const SizedBox(height: 16),
                  const Text('Policies', style: _sectionTitleStyle),
                  const SizedBox(height: 8),
                  // TODO(backend): open the hosted policy pages.
                  const _PolicyRow(label: 'Privacy Policy'),
                  const _PolicyRow(label: 'Terms'),
                  const SizedBox(height: 16),
                  const Text('Data management', style: _sectionTitleStyle),
                  const SizedBox(height: 8),
                  const Text(
                    'Clear documents, extracted text, study materials, '
                    'progress, preferences and the downloaded model from '
                    'this app.',
                    style: _bodyMutedStyle,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.clearData),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.dangerSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/figma/trash_2.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.danger,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Clear All Local Data',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 20 / 14,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This cannot be undone. External exported copies are '
                    'not removed. An active Google Play subscription is '
                    'not cancelled.',
                    style: AppTextStyles.greeting.copyWith(height: 18 / 12),
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

/// A policy row: semibold label with an external-link arrow and a
/// bottom border, as in the Figma "Policies" section.
class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _sectionTitleStyle)),
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
