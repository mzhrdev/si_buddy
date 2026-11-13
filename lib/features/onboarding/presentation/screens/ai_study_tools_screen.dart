import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/onboarding_chrome.dart';

/// Onboarding page 2, implemented from the Figma frame
/// "SI Buddy · AI study tools" (3:1078): a flashcard and a quick-quiz card
/// above the "Less prep. More lightbulbs." intro.
class AiStudyToolsScreen extends StatelessWidget {
  const AiStudyToolsScreen({super.key});

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
              child: Center(child: _StudyToolsIllustration()),
            ),
            const OnboardingIntro(
              eyebrow: 'MEET YOUR STUDY BUDDY',
              headline: 'Less prep.\nMore lightbulbs.',
              body:
                  'Let on-device AI turn your notes into flashcards, quizzes '
                  'and summaries. Study your way.',
            ),
            const Spacer(),
            OnboardingActions(
              pageIndex: 1,
              buttonLabel: 'Next',
              caption: 'Make room for a better way to study.',
              onNext: () => context.push(AppRoutes.onboardingPrivate),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 337×316 illustration: a primary flashcard (tilted accent backing)
/// overlapping a white quick-quiz card with one selected answer.
class _StudyToolsIllustration extends StatelessWidget {
  const _StudyToolsIllustration();

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
