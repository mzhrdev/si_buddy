import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import 'onboarding_chrome.dart';

/// The onboarding illustrations, moved out of the old per-page
/// screens: each is a hand-built Figma frame, kept verbatim. The
/// single onboarding screen picks one by [OnboardingIllustration]
/// (see the onboarding page model).

/// The 337×316 illustration from the Figma frame
/// "SI Buddy · Import notes" (3:1017): three source-file cards
/// dropping into a notes folder, above the intro.
class ImportNotesIllustration extends StatelessWidget {
  const ImportNotesIllustration({super.key});

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
                color: context.appAccentMuted,
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
                color: context.appAccentMuted,
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
                color: context.appPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My study notes',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 22 / 16,
                          color: context.appCard,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/svgs/figma/plus.svg',
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
                        decoration: BoxDecoration(
                          color: context.appCard,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Ready for a fresh perspective',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 18 / 12,
                          color: context.appCard,
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

/// The 337×316 illustration from the Figma frame
/// "SI Buddy · AI study tools" (3:1078): a primary flashcard (tilted
/// accent backing) overlapping a white quick-quiz card with one
/// selected answer.
class StudyToolsIllustration extends StatelessWidget {
  const StudyToolsIllustration({super.key});

  static TextStyle _cardLabel(BuildContext context) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 14 / 10,
    color: context.appCard,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 337,
      height: 316,
      child: Stack(
        children: [
          // Flashcard backing, tilted -8°.
          Positioned(
            left: 41,
            top: 24,
            child: Transform.rotate(
              angle: -8 * math.pi / 180,
              child: Container(
                width: 196,
                height: 150,
                decoration: BoxDecoration(
                  color: context.appAccentMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Flashcard.
          Positioned(
            left: 37,
            top: 42,
            child: Container(
              width: 210,
              height: 148,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.appPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/figma/layers.svg',
                        width: 14,
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          context.appCard,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text('FLASHCARDS', style: _cardLabel(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What makes a memory stick?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 26 / 20,
                      color: context.appCard,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Tap. Recall. Repeat.', style: _cardLabel(context)),
                ],
              ),
            ),
          ),
          // Quiz card.
          Positioned(
            left: 100,
            top: 155,
            child: Container(
              width: 215,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appCard,
                border: Border.all(color: context.appBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUICK QUIZ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 14 / 10,
                          color: context.appPrimary,
                        ),
                      ),
                      Text(
                        '1 / 5',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          height: 14 / 10,
                          color: context.appMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'The best way to remember?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 16 / 12,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 9),
                  // Selected answer.
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/figma/circle_check.svg',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Active recall',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 16 / 11,
                            color: context.appPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  // Unselected answer.
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: context.appCard,
                            border: Border.all(color: context.appBorder),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reading it again',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 16 / 11,
                            color: context.appMuted,
                          ),
                        ),
                      ],
                    ),
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

/// The 337×316 illustration from the Figma frame
/// "SI Buddy · Private and offline" (3:1141): the personal device
/// (163×257 SVG) with the "Online AI generation" reminder card
/// overlapping its base.
class PrivateOfflineIllustration extends StatelessWidget {
  const PrivateOfflineIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 337,
      height: 316,
      child: Stack(
        children: [
          Positioned(
            left: 88,
            top: 20,
            child: SvgPicture.asset(
              'assets/svgs/figma/personal_device.svg',
              width: 163,
              height: 257,
            ),
          ),
          Positioned(
            left: 30,
            top: 244,
            child: Container(
              width: 277,
              height: 57,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: context.appCard,
                border: Border.all(color: context.appBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svgs/figma/download.svg',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Online AI generation',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 16 / 12,
                            color: context.appText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your notes are sent to your AI service.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 16 / 11,
                            color: context.appMuted,
                          ),
                        ),
                      ],
                    ),
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
