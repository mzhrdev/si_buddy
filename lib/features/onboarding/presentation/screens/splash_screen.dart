import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';

/// Splash screen, implemented from the Figma frame
/// "SI Buddy · Splash" (3:987): 108px brand mark, the "SI Buddy" wordmark
/// and the tagline, centered on the background. Advances to the first
/// onboarding page automatically after a short delay; tapping skips ahead.
class SplashDesignScreen extends StatefulWidget {
  const SplashDesignScreen({super.key});

  @override
  State<SplashDesignScreen> createState() => _SplashDesignScreenState();
}

class _SplashDesignScreenState extends State<SplashDesignScreen> {
  Timer? _timer;
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), _advance);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _advance() {
    if (_advanced || !mounted) return;
    _advanced = true;
    _timer?.cancel();
    context.go(AppRoutes.onboardingImport);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _advance,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Spacer(),
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
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
