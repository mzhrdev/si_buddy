import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../domain/onboarding_page.dart';
import '../widgets/onboarding_chrome.dart';
import '../widgets/onboarding_illustrations.dart';

/// The single onboarding screen: one route that renders every page
/// from [onboardingPages]. It replaces the three old per-page
/// screens (import notes, AI study tools, private/offline), which
/// were the same layout with different text and illustration.
///
/// "Next" advances to the next page in the model; on the last page
/// the button finishes onboarding — the completion flag is persisted
/// before navigating home, so the splash screen routes straight to
/// Home on the next cold start. The system back button goes to the
/// previous page, and on the first page it leaves onboarding, which
/// matches the old three-route behaviour.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  var _index = 0;

  OnboardingPage get _page => onboardingPages[_index];

  void _next() {
    if (_index < onboardingPages.length - 1) {
      setState(() => _index++);
    } else {
      // Marking completion never blocks navigation: the write is a
      // single local insert, best-effort.
      markOnboardingComplete(ref);
      context.go(AppRoutes.home);
    }
  }

  Widget _illustration(OnboardingIllustration illustration) {
    switch (illustration) {
      case OnboardingIllustration.importNotes:
        return const ImportNotesIllustration();
      case OnboardingIllustration.studyTools:
        return const StudyToolsIllustration();
      case OnboardingIllustration.privateOffline:
        return const PrivateOfflineIllustration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _index > 0) {
          setState(() => _index--);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingHeader(onSkip: () => context.go(AppRoutes.home)),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: SingleChildScrollView(
                    key: ValueKey(_index),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 340,
                          child: Center(
                            child: _illustration(_page.illustration),
                          ),
                        ),
                        OnboardingIntro(
                          eyebrow: _page.eyebrow,
                          headline: _page.headline,
                          body: _page.body,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              OnboardingActions(
                pageIndex: _index,
                pageCount: onboardingPages.length,
                buttonLabel: _page.buttonLabel,
                caption: _page.caption,
                onNext: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
