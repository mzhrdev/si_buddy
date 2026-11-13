import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/database/settings_repository.dart';
import '../../../../core/layout/responsive_spacing.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

/// Marks onboarding complete in settings, best-effort and never
/// awaited by navigation: the write is a single local insert, but
/// leaving a screen must never wait on storage.
void markOnboardingComplete(WidgetRef ref) {
  unawaited(_saveOnboardingCompleted(ref));
}

Future<void> _saveOnboardingCompleted(WidgetRef ref) async {
  try {
    await ref
        .read(settingsRepositoryProvider)
        .setBool(SettingsKeys.onboardingCompleted, true);
  } catch (_) {
    // Best-effort only: a failed write just replays onboarding
    // once on the next cold start.
  }
}

/// Shared chrome for the three onboarding pages, from the Figma component
/// "SI Buddy / Onboarding header" and the "Onboarding actions" region:
/// brand lockup + Skip, page dots, primary button and the caption below it.

/// 32px bold onboarding headline (lh 38, tracking -0.64).
TextStyle onboardingHeadline(BuildContext context) => TextStyle(
  fontFamily: 'Inter',
  fontSize: 32,
  fontWeight: FontWeight.w700,
  height: 38 / 32,
  letterSpacing: -0.64,
  color: context.appText,
);

/// 14px body copy in the muted tone (lh 22), as used under the headline.
TextStyle onboardingBody(BuildContext context) => TextStyle(
  fontFamily: 'Inter',
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 22 / 14,
  color: context.appMuted,
);

/// Header row: 34px brand mark + "SI Buddy" on the left, "Skip" on the right.
///
/// Skipping finishes onboarding: the completion flag is persisted
/// before [onSkip] runs, so the splash screen routes straight to
/// Home on the next cold start instead of replaying onboarding.
class OnboardingHeader extends ConsumerWidget {
  const OnboardingHeader({required this.onSkip, super.key});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSpacing.horizontal(context),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/svgs/figma/brand_mark.svg',
              width: 34,
              height: 34,
            ),
            const SizedBox(width: 9),
            Text('SI Buddy', style: AppTextStyles.screenTitle(context)),
            const Spacer(),
            TextButton(
              onPressed: () {
                markOnboardingComplete(ref);
                onSkip();
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.only(left: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Skip',
                style: AppTextStyles.body(context).copyWith(
                  fontWeight: FontWeight.w600,
                  height: 20 / 14,
                  color: context.appPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eyebrow + two-line headline + body copy block ("Introduction" region).
class OnboardingIntro extends StatelessWidget {
  const OnboardingIntro({
    required this.eyebrow,
    required this.headline,
    required this.body,
    super.key,
  });

  final String eyebrow;
  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveSpacing.page(context, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppTextStyles.captionAccent(context)),
          const SizedBox(height: 12),
          Text(headline, style: onboardingHeadline(context)),
          const SizedBox(height: 12),
          Text(body, style: onboardingBody(context)),
        ],
      ),
    );
  }
}

/// Bottom region: page indicators, the primary button (label + forward
/// arrow) and the small caption centered below it.
class OnboardingActions extends StatelessWidget {
  const OnboardingActions({
    required this.pageIndex,
    required this.buttonLabel,
    required this.caption,
    required this.onNext,
    super.key,
  });

  /// Zero-based index of the active page dot (3 pages total).
  final int pageIndex;
  final String buttonLabel;
  final String caption;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveSpacing.page(context, top: 22, bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                Container(
                  width: i == pageIndex ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == pageIndex
                        ? context.appPrimary
                        : context.appAccentMuted,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onNext,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(buttonLabel),
                const SizedBox(width: 12),
                SvgPicture.asset(
                  'assets/svgs/figma/arrow_right.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    context.appCard,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(caption, style: AppTextStyles.greeting(context)),
        ],
      ),
    );
  }
}

/// A tilted source-file card used by the onboarding / empty-state
/// illustrations: document symbol over a format label (PDF, DOCX, PPTX).
class SourceFileCard extends StatelessWidget {
  const SourceFileCard({
    required this.label,
    this.width = 79,
    this.height = 100,
    this.padding = 12,
    this.gap = 9,
    this.iconWidth = 22,
    this.iconHeight = 27,
    this.labelStyle,
    super.key,
  });

  final String label;
  final double width;
  final double height;
  final double padding;
  final double gap;
  final double iconWidth;
  final double iconHeight;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/svgs/figma/file.svg',
            width: iconWidth,
            height: iconHeight,
          ),
          SizedBox(height: gap),
          Text(
            label,
            style:
                labelStyle ??
                TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: context.appTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
