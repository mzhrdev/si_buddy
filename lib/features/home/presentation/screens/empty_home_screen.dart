import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// First-run (empty) home, implemented from the Figma frame
/// "SI Buddy · Empty Home" (3:1951): a welcome header, the first-import
/// invitation with its folder illustration, an AI-model setup card and a
/// privacy reassurance line. The bottom navigation comes from the shell.
class EmptyHomeScreen extends StatelessWidget {
  const EmptyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          children: [
            // Friendly greeting.
            SizedBox(
              height: 54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Your personal study space',
                        style: AppTextStyles.greeting,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Welcome to SI Buddy.',
                        style: AppTextStyles.display.copyWith(
                          letterSpacing: -0.48,
                        ),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    'assets/icons/figma/brand_mark.svg',
                    width: 38,
                    height: 38,
                  ),
                ],
              ),
            ),
            // First import invitation.
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Column(
                children: [
                  const _FirstNotesIllustration(),
                  const SizedBox(height: 18),
                  const Text(
                    'Big ideas start with\nyour first notes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 34 / 28,
                      letterSpacing: -0.56,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No notes yet. Import a document to turn it into '
                    'flashcards, quizzes and summaries.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 22 / 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.importFiles),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Import Notes'),
                        const SizedBox(width: 12),
                        SvgPicture.asset(
                          'assets/icons/figma/arrow_right.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'PDF, DOCX or PPTX · Stored on your device',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            // AI model setup guidance.
            Padding(
              padding: const EdgeInsets.only(top: 26),
              child: Container(
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
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/figma/download_plain.svg',
                              width: 19,
                              height: 19,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI model not downloaded',
                              style: AppTextStyles.itemTitle,
                            ),
                            SizedBox(height: 3),
                            Text(
                              'One download. Then AI works offline.',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You can import notes now. Connect to the internet to '
                      'download the model before generating study tools.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 18 / 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.notInstalled),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Set up AI model',
                            style: AppTextStyles.link,
                          ),
                          const SizedBox(width: 7),
                          SvgPicture.asset(
                            'assets/icons/figma/arrow_right.svg',
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
              ),
            ),
            // Privacy reassurance.
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/figma/shield_check.svg',
                    width: 13,
                    height: 13,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'No account. No cloud. Just your notes.',
                    style: AppTextStyles.caption,
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

/// The 270×170 "Bring your first notes" illustration: three small source
/// files above a primary "Your study space" folder.
class _FirstNotesIllustration extends StatelessWidget {
  const _FirstNotesIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 170,
      child: Stack(
        children: [
          // Folder tab and backing.
          Positioned(
            left: 58,
            top: 86,
            child: Container(
              width: 59,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.accentMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            left: 58,
            top: 96,
            child: Container(
              width: 156,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accentMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Source files.
          Positioned(
            left: 55,
            top: 13,
            child: Transform.rotate(
              angle: -12 * math.pi / 180,
              child: const _SourceFileChip(label: 'PDF'),
            ),
          ),
          const Positioned(
            left: 110,
            top: 12,
            child: _SourceFileChip(label: 'DOCX'),
          ),
          Positioned(
            left: 151,
            top: 24,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: const _SourceFileChip(label: 'PPTX'),
            ),
          ),
          // Notes folder.
          Positioned(
            left: 51,
            top: 108,
            child: Container(
              width: 168,
              height: 58,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your study space',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 16 / 12,
                      color: AppColors.white,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/figma/plus.svg',
                    width: 16,
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small 52×68 source-file card (document symbol + format label).
class _SourceFileChip extends StatelessWidget {
  const _SourceFileChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 68,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/figma/file.svg',
            width: 16,
            height: 20,
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.badge),
        ],
      ),
    );
  }
}
