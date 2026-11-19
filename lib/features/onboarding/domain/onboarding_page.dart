// The onboarding content model: one entry per page. The single
// onboarding screen reads [onboardingPages] and renders the current
// entry, so changing a page's text or illustration is an edit to
// this list, not a new screen.
//
// The illustrations are hand-built Figma widgets, not image files,
// so the model names one by [OnboardingIllustration] and the screen
// builds the matching widget. The text is copied verbatim from the
// three Figma frames the old screens implemented.

/// Which illustration a page shows.
enum OnboardingIllustration {
  /// PDF / DOCX / PPTX cards dropping into a notes folder.
  importNotes,

  /// Flashcard overlapping a quick-quiz card.
  studyTools,

  /// Personal device with the online-generation reminder card.
  privateOffline,
}

/// One onboarding page: the illustration to show and the copy around
/// it. All fields are plain data — no widgets live in the model.
class OnboardingPage {
  const OnboardingPage({
    required this.illustration,
    required this.eyebrow,
    required this.headline,
    required this.body,
    required this.buttonLabel,
    required this.caption,
  });

  final OnboardingIllustration illustration;

  /// Small caps label above the headline.
  final String eyebrow;

  /// Two-line headline (uses an explicit line break).
  final String headline;

  /// Body copy under the headline.
  final String body;

  /// Primary button label ('Next', or 'Get Started' on the last page).
  final String buttonLabel;

  /// Small caption under the button.
  final String caption;
}

/// The pages, in order. Add, remove or reorder entries here and the
/// screen, the dots and the button follow — no screen changes needed.
const onboardingPages = <OnboardingPage>[
  OnboardingPage(
    illustration: OnboardingIllustration.importNotes,
    eyebrow: 'BRING YOUR NOTES',
    headline: 'Your notes,\nall together.',
    body:
        'Import PDF, Word and PowerPoint files. Turn your class '
        'notes into your own study space.',
    buttonLabel: 'Next',
    caption: 'Make room for a better way to study.',
  ),
  OnboardingPage(
    illustration: OnboardingIllustration.studyTools,
    eyebrow: 'MEET YOUR STUDY BUDDY',
    headline: 'Less prep.\nMore lightbulbs.',
    body:
        'Let on-device AI turn your notes into flashcards, quizzes '
        'and summaries. Study your way.',
    buttonLabel: 'Next',
    caption: 'Make room for a better way to study.',
  ),
  OnboardingPage(
    illustration: OnboardingIllustration.privateOffline,
    eyebrow: 'YOUR DEVICE. YOUR SPACE.',
    headline: 'Big ideas.\nSmall footprint.',
    body:
        'Your notes stay on your device. Download the AI model '
        'when you’re ready, then study offline.',
    buttonLabel: 'Get Started',
    caption: 'No account needed. Just you and your notes.',
  ),
];
