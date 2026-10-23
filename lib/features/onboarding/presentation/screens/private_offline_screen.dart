import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/onboarding_chrome.dart';

/// Onboarding page 3, implemented from the Figma frame
/// "SI Buddy · Private and offline" (3:1141): a personal-device
/// illustration with a model-download reminder card, above the
/// "Big ideas. Small footprint." intro.
class PrivateOfflineScreen extends StatelessWidget {
  const PrivateOfflineScreen({super.key});

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
              child: Center(child: _PrivateIllustration()),
            ),
            const OnboardingIntro(
              eyebrow: 'YOUR DEVICE. YOUR SPACE.',
              headline: 'Big ideas.\nSmall footprint.',
              body:
                  'Your notes stay on your device. Download the AI model '
                  'when you’re ready, then study offline.',
            ),
            const Spacer(),
            OnboardingActions(
              pageIndex: 2,
              buttonLabel: 'Get Started',
              caption: 'No account needed. Just you and your notes.',
              onNext: () => context.go(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}

/// The 337×316 illustration: the personal device (163×257 SVG) with the
/// "One model download" reminder card overlapping its base.
class _PrivateIllustration extends StatelessWidget {
  const _PrivateIllustration();

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
              'assets/icons/figma/personal_device.svg',
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
                color: AppColors.white,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/figma/download.svg',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 11),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One model download',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 16 / 12,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Then AI works offline.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          height: 16 / 11,
                          color: AppColors.muted,
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
