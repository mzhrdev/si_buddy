/// Data models for the Home dashboard.
///
/// Plain immutable classes; populated by providers today (mock data that
/// mirrors the Figma design) and by repositories later.
class StudyProgress {
  const StudyProgress({
    required this.cardsReviewed,
    required this.minutesStudied,
    required this.dailyGoalMinutes,
    required this.streakDays,
    required this.modelReady,
  });

  final int cardsReviewed;
  final int minutesStudied;
  final int dailyGoalMinutes;
  final int streakDays;

  /// Whether the on-device AI model is installed and ready offline.
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
  });

  /// File format badge, e.g. "PDF" or "PPTX".
  final String format;
  final String title;

  /// Pre-formatted metadata line, e.g. "PDF · 12 pages · Today".
  final String details;
}

/// A recently studied deck, as shown in "Pick up where you left off".
class DeckSummary {
  const DeckSummary({
    required this.title,
    required this.cardCount,
    required this.dueCount,
    required this.lastStudied,
  });

  final String title;
  final int cardCount;
  final int dueCount;

  /// Pre-formatted recency label, e.g. "Studied 20 min ago".
  final String lastStudied;

  String get stats => '$cardCount cards · $dueCount due';
}

/// Everything the Home dashboard renders.
class HomeDashboardData {
  const HomeDashboardData({
    required this.progress,
    required this.documents,
    required this.decks,
  });

  final StudyProgress progress;
  final List<DocumentSummary> documents;
  final List<DeckSummary> decks;
}
