import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/onboarding_chrome.dart';

/// Onboarding page 3, implemented from the Figma frame
/// "SI Buddy · Private and offline" (3:1141): a personal-device
/// illustration with an online-generation reminder card, above the
/// "Big ideas. Small footprint." intro.
///
/// "Get Started" finishes onboarding: the completion flag is
/// persisted before navigating home, so the splash screen routes
/// straight to Home on the next cold start.
class PrivateOfflineScreen extends ConsumerWidget {
  const PrivateOfflineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Your notes stay on your device. Study material '
                  'you already made works offline; new AI generation '
                  'needs the internet.',
            ),
            const Spacer(),
            OnboardingActions(
              pageIndex: 2,
              buttonLabel: 'Get Started',
              caption: 'No account needed. Just you and your notes.',
              onNext: () {
                // Marking completion never blocks navigation: the
                // write is a single local insert, best-effort.
                markOnboardingComplete(ref);
                context.go(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The 337×316 illustration: the personal device (163×257 SVG) with the
/// "Online AI generation" reminder card overlapping its base.
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
                color: context.appCard,
                border: Border.all(color: context.appBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/figma/wifi.svg',
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
