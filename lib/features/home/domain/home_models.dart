/// Data models for the Home dashboard.
///
/// The Home screen is state-driven (production brief, Phase 3): it
/// renders exactly one of the states below, derived from the real
/// model state, the library, the persisted decks and the recorded
/// study activity — never fabricated numbers or sample content.
library;

import '../../study/domain/study_models.dart';

/// The Home state machine.
///
/// - [noModel] (A): no AI service configured — welcome + AI
///   service setup only.
/// - [noDocuments] (B): service configured, nothing imported —
///   service status + Import Notes.
/// - [noStudySets] (C): documents imported, no study sets — Import
///   action + Recent Documents + a generate next step.
/// - [active] (D/F): unfinished study work exists — statistics +
///   "Pick up where you left off" + Recent Documents.
/// - [completedOnly] (E): only completed activity — Recent
///   Documents + study history.
enum HomeState { noModel, noDocuments, noStudySets, active, completedOnly }

/// Pure derivation of the Home state from the real inputs, so the
/// state machine is unit-testable without providers or a database.
HomeState deriveHomeState({
  required bool modelReady,
  required int documentCount,
  required int deckCount,
  required IncompleteActivity? incomplete,
  required bool hasCompletedActivity,
}) {
  if (!modelReady) return HomeState.noModel;
  if (documentCount == 0) return HomeState.noDocuments;
  if (deckCount == 0) return HomeState.noStudySets;
  if (incomplete != null) return HomeState.active;
  if (hasCompletedActivity) return HomeState.completedOnly;
  // Decks exist but nothing was ever studied and nothing is
  // unfinished: unreachable in practice (any unstudied deck is
  // unfinished work), but a studied-deck history is the honest
  // fallback.
  return HomeState.completedOnly;
}

class StudyProgress {
  const StudyProgress({
    required this.cardsReviewed,
    required this.minutesStudied,
    required this.dailyGoalMinutes,
    required this.streakDays,
    required this.modelReady,
  });

  final int cardsReviewed;

  /// Minutes studied today (local calendar day) — what the daily
  /// goal bar measures against.
  final int minutesStudied;
  final int dailyGoalMinutes;
  final int streakDays;

  /// Whether the AI service is configured and ready.
  final bool modelReady;

  int get minutesRemaining => dailyGoalMinutes - minutesStudied;

  double get goalFraction =>
      dailyGoalMinutes == 0 ? 0 : minutesStudied / dailyGoalMinutes;
}

/// A recently imported document, as shown in "Recent documents".
class DocumentSummary {
  const DocumentSummary({
    required this.format,
    required this.title,
    required this.details,
    this.id,
  });

  /// Library id, when this summary comes from a saved document.

  /// File format badge, e.g. "PDF" or "PPTX".
  final String format;
  final String title;

  /// Pre-formatted metadata line, e.g. "PDF · 12 pages · Today".
  final String details;

  final int? id;
}

/// One unfinished deck, as shown in "Pick up where you left off".
class PickUpItem {
  const PickUpItem({
    required this.deckId,
    required this.title,
    required this.isQuiz,
    required this.currentIndex,
    required this.totalItems,
  });

  /// Persisted deck id, for loading the deck when Continue is
  /// tapped.
  final int deckId;
  final String title;

  /// True for a quiz deck, false for flashcards.
  final bool isQuiz;

  /// Resume position: the quiz attempt's current question index, or
  /// the number of flashcards already reviewed.
  final int currentIndex;
  final int totalItems;

  double get fraction =>
      totalItems == 0 ? 0 : (currentIndex / totalItems).clamp(0.0, 1.0);

  String get kindLabel => isQuiz ? 'Quiz' : 'Flashcards';

  String get progressText => isQuiz
      ? 'Question ${currentIndex + 1} of $totalItems'
      : '$currentIndex of $totalItems reviewed';
}

/// One finished quiz attempt, as shown in the study history.
class HistoryItem {
  const HistoryItem({required this.title, required this.subtitle});

  final String title;

  /// Pre-formatted result line, e.g. "8/10 · 16 Oct 2026".
  final String subtitle;
}

/// Everything the Home dashboard renders.
class HomeDashboardData {
  const HomeDashboardData({
    required this.state,
    required this.progress,
    required this.documents,
    required this.pickUp,
    required this.history,
    required this.nextStepDocument,
  });

  final HomeState state;
  final StudyProgress progress;

  /// Recent documents, newest first.
  final List<DocumentSummary> documents;

  /// Unfinished work, when the state is [HomeState.active].
  final PickUpItem? pickUp;

  /// Finished quiz attempts, newest first, for
  /// [HomeState.completedOnly].
  final List<HistoryItem> history;

  /// Newest document, the generate next step when the state is
  /// [HomeState.noStudySets].
  final DocumentSummary? nextStepDocument;
}
