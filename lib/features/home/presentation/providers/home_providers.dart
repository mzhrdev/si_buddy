import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../model_management/presentation/providers/model_providers.dart';
import '../../../study/domain/study_models.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../../domain/home_models.dart';

/// Time-aware greeting shown above the dashboard headline,
/// e.g. "Good morning, study buddy".
final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  final part = hour < 12
      ? 'Good morning'
      : hour < 17
      ? 'Good afternoon'
      : 'Good evening';
  return '$part, study buddy';
});

/// Dashboard content, built from live sources only.
///
/// - Model status: the model provider's last known state. It is
///   probed once at startup and on every resume (see `MyApp`), so
///   a cold start reads the real state instead of "not installed".
/// - Recent documents: the real library stream, newest first.
/// - "Pick up where you left off": the most recent unfinished
///   persisted deck (an open quiz attempt first, otherwise the
///   newest unstudied or partly reviewed deck).
/// - Study progress: genuine persisted statistics — cards reviewed,
///   minutes studied today, streak — and the persisted daily goal.
/// - History: the newest finished quiz attempts.
///
/// The state machine ([deriveHomeState]) decides which sections the
/// screen shows; the provider only assembles the data.
final homeDashboardProvider = Provider<HomeDashboardData>((ref) {
  final modelReady = ref.watch(modelProvider).isReady;
  final documents = ref.watch(documentsStreamProvider).value ?? const [];
  final decks = ref.watch(decksStreamProvider).value ?? const [];
  final stats = ref.watch(studyStatsProvider).value ?? StudyStats.empty;
  final dailyGoal = ref.watch(dailyGoalMinutesProvider).value ?? 20;
  final incomplete = ref.watch(incompleteActivityProvider).value;
  final completed = ref.watch(completedAttemptsProvider).value ?? const [];

  final summaries = [
    for (final document in documents)
      DocumentSummary(
        id: document.id,
        format: document.format.label,
        title: documentDisplayName(document),
        details:
            '${document.format.label} · ${document.pageCount} ${document.format.unitLabel} · ${formatLibraryDate(document.createdAt)}',
      ),
  ];
  return HomeDashboardData(
    state: deriveHomeState(
      modelReady: modelReady,
      documentCount: documents.length,
      deckCount: decks.length,
      incomplete: incomplete,
      hasCompletedActivity:
          stats.cardsReviewed > 0 || stats.quizzesCompleted > 0,
    ),
    progress: StudyProgress(
      cardsReviewed: stats.cardsReviewed,
      minutesStudied: stats.studiedTodayMinutes,
      dailyGoalMinutes: dailyGoal,
      streakDays: stats.streakDays,
      modelReady: modelReady,
    ),
    documents: summaries,
    pickUp: incomplete == null
        ? null
        : PickUpItem(
            deckId: incomplete.deck.id,
            title: incomplete.deck.title,
            isQuiz: incomplete.deck.isQuiz,
            currentIndex: incomplete.currentIndex,
            totalItems: incomplete.totalItems,
          ),
    history: [
      for (final attempt in completed)
        HistoryItem(
          title: attempt.deckTitle,
          subtitle:
              '${attempt.attempt.score ?? 0}/${attempt.attempt.totalQuestions} · ${formatLibraryDate(attempt.attempt.completedAt ?? attempt.attempt.startedAt)}',
        ),
    ],
    nextStepDocument: summaries.isEmpty ? null : summaries.first,
  );
});
