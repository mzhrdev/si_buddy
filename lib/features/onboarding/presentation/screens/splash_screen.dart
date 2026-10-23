import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';

/// Splash screen, implemented from the Figma frame
/// "SI Buddy · Splash" (3:987): 108px brand mark, the "SI Buddy" wordmark,
/// the tagline and a small loading dot, centered on the background.
class SplashDesignScreen extends StatelessWidget {
  const SplashDesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // TODO(backend): advance automatically once startup finishes.
          onTap: () => context.go(AppRoutes.onboardingImport),
          child: Column(
            children: [
              const Spacer(flex: 204),
              SvgPicture.asset(
                'assets/icons/figma/brand_mark.svg',
                width: 108,
                height: 108,
              ),
              const SizedBox(height: 36),
              const Text(
                'SI Buddy',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 48 / 40,
                  letterSpacing: -0.8,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your notes. Your AI. Your exam prep.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 22 / 14,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(flex: 199),
              // Loading animation (a single 10px dot in the design).
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(flex: 121),
            ],
          ),
        ),
      ),
    );
  }
}
