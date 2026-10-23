import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/onboarding_chrome.dart';

/// Onboarding page 1, implemented from the Figma frame
/// "SI Buddy · Import notes" (3:1017): three source-file cards dropping
/// into a notes folder, above the "Your notes, all together." intro.
class ImportNotesScreen extends StatelessWidget {
  const ImportNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OnboardingHeader(onSkip: () => context.go(AppRoutes.home)),
            const SizedBox(
              height: 340,
              child: Center(child: _ImportIllustration()),
            ),
            const OnboardingIntro(
              eyebrow: 'BRING YOUR NOTES',
              headline: 'Your notes,\nall together.',
              body:
                  'Import PDF, Word and PowerPoint files. Turn your class '
                  'notes into your own study space.',
            ),
            const Spacer(),
            OnboardingActions(
              pageIndex: 0,
              buttonLabel: 'Next',
              caption: 'Make room for a better way to study.',
              onNext: () => context.push(AppRoutes.onboardingAi),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 337×316 illustration: PDF / DOCX / PPTX cards above a primary
/// "My study notes" folder with an accent-muted backing and tab.
class _ImportIllustration extends StatelessWidget {
  const _ImportIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 337,
      height: 316,
      child: Stack(
        children: [
          // Folder tab and back.
          Positioned(
            left: 49,
            top: 135,
            child: Container(
              width: 90,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.accentMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            left: 49,
            top: 148,
            child: Container(
              width: 239,
              height: 131,
              decoration: BoxDecoration(
                color: AppColors.accentMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Source files.
          Positioned(
            left: 47,
            top: 20,
            child: Transform.rotate(
              angle: -12 * math.pi / 180,
              child: const SourceFileCard(label: 'PDF'),
            ),
          ),
          const Positioned(
            left: 132,
            top: 18,
            child: SourceFileCard(label: 'DOCX'),
          ),
          Positioned(
            left: 192,
            top: 37,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: const SourceFileCard(label: 'PPTX'),
            ),
          ),
          // Notes folder.
          Positioned(
            left: 41,
            top: 170,
            child: Container(
              width: 255,
              height: 118,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My study notes',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 22 / 16,
                          color: AppColors.white,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/figma/plus.svg',
                        width: 18,
                        height: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'Ready for a fresh perspective',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 18 / 12,
                          color: AppColors.white,
                        ),
                      ),
                    ],
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
