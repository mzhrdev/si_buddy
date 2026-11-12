import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../../core/database/settings_repository.dart';
import '../../data/study_repository.dart';
import '../../domain/study_models.dart';

/// The study repository the study screens run on: persisted decks,
/// attempts, reviews, sessions and revisions over the app database.
final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  return StudyRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

// ---------------------------------------------------------------------------
// Decks
// ---------------------------------------------------------------------------

/// All persisted decks, newest first, streamed as they change.
final decksStreamProvider = StreamProvider<List<StudyDeck>>((ref) {
  return ref.watch(studyRepositoryProvider).watchDecks();
});

/// One document's decks, newest first, streamed as they change.
final documentDecksProvider = StreamProvider.family<List<StudyDeck>, int>((
  ref,
  documentId,
) {
  return ref.watch(studyRepositoryProvider).watchDecksForDocument(documentId);
});

/// How many study sets each document has (its deck count), as one
/// map keyed by document id, streamed as decks change. Library cards
/// read their count from here instead of a per-document watch.
final deckCountsByDocumentProvider = StreamProvider<Map<int, int>>((ref) {
  return ref.watch(studyRepositoryProvider).watchDecks().map((decks) {
    final counts = <int, int>{};
    for (final deck in decks) {
      counts[deck.documentId] = (counts[deck.documentId] ?? 0) + 1;
    }
    return counts;
  });
});

// ---------------------------------------------------------------------------
// Statistics
// ---------------------------------------------------------------------------

/// Bumped whenever persisted study activity changes (a session ends,
/// a card is reviewed, a quiz attempt is recorded or completed), so
/// the statistics providers below recompute. Deck changes already
/// invalidate them through [decksStreamProvider]; this covers the
/// activity that happens inside an existing deck.
class StudyDataVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final studyDataVersionProvider =
    NotifierProvider<StudyDataVersionNotifier, int>(
      StudyDataVersionNotifier.new,
    );

/// Genuine study statistics, computed from persisted rows only.
/// Recomputed whenever the deck list changes (new decks imply new
/// activity may exist) or study activity is recorded; the stats
/// query itself is cheap.
final studyStatsProvider = FutureProvider<StudyStats>((ref) async {
  ref.watch(decksStreamProvider);
  ref.watch(studyDataVersionProvider);
  return ref.read(studyRepositoryProvider).getStats();
});

/// Daily study activity for the last 7 local calendar days, oldest
/// first — the Statistics weekly chart. Recomputed with the stats.
final dailyActivityProvider = FutureProvider<List<DailyActivity>>((ref) async {
  ref.watch(decksStreamProvider);
  ref.watch(studyDataVersionProvider);
  return ref.read(studyRepositoryProvider).getDailyActivity(days: 7);
});

/// The most recent unfinished study work, for "Pick up where you
/// left off". Recomputed whenever the deck list changes.
final incompleteActivityProvider = FutureProvider<IncompleteActivity?>((
  ref,
) async {
  ref.watch(decksStreamProvider);
  return ref.read(studyRepositoryProvider).getLatestIncompleteActivity();
});

/// Finished quiz attempts, newest first — the study history.
/// Recomputed whenever the deck list changes.
final completedAttemptsProvider = FutureProvider<List<CompletedAttempt>>((
  ref,
) async {
  ref.watch(decksStreamProvider);
  return ref.read(studyRepositoryProvider).listCompletedAttempts(limit: 5);
});

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

/// The user's daily study goal in minutes. The design's default is
/// 20; the value is persisted once the user changes it.
final dailyGoalMinutesProvider = StreamProvider<int>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchString(SettingsKeys.dailyGoalMinutes)
      .map((value) => int.tryParse(value ?? '') ?? 20);
});

// ---------------------------------------------------------------------------
// Study sessions
// ---------------------------------------------------------------------------

/// Tracks the one study session that is open right now (Phase 5):
/// studying a deck starts a session, leaving the deck (or starting
/// another deck) ends it with its real duration and the cards
/// reviewed. The session is persisted through the repository, so
/// Statistics and the Planner read genuine study time.
///
/// Sessions that never became real studying — abandoned within 30
/// seconds with nothing reviewed, or left open overnight — are
/// deleted instead of ended, so they never inflate the statistics.
class StudySessionTracker extends Notifier<ActiveStudySession?> {
  @override
  ActiveStudySession? build() => null;

  static const _junkThreshold = Duration(seconds: 30);

  /// Starts a session for [deckId] (type `flashcards` or `quiz`).
  /// A no-op when a session for the same deck is already open.
  /// Any other open session is ended first. The `mounted` guards
  /// matter: the start is async, and the provider may be disposed
  /// (tests, app shutdown) before the database write returns — a
  /// state write after that throws.
  Future<void> start({int? deckId, required String type}) async {
    if (!ref.mounted) return;
    if (state != null && state!.deckId == deckId && state!.type == type) {
      return;
    }
    await end();
    if (!ref.mounted) return;
    int sessionId;
    try {
      sessionId = await ref
          .read(studyRepositoryProvider)
          .startSession(deckId: deckId, type: type);
    } catch (_) {
      // Best-effort: studying works without the session row; the
      // statistics simply miss this visit.
      return;
    }
    if (!ref.mounted) return;
    state = ActiveStudySession(
      sessionId: sessionId,
      deckId: deckId,
      type: type,
      startedAt: DateTime.now(),
    );
  }

  /// Records that the card at [cardIndex] was reviewed in this
  /// session (distinct cards only — re-rating the same card does
  /// not count twice).
  void recordCardReviewed(int cardIndex) {
    final active = state;
    if (active == null) return;
    // The set lives on the active session object, which the state
    // already holds — mutating it is enough; nothing watches this
    // provider for rebuilds.
    active.reviewedIndexes.add(cardIndex);
  }

  /// How long the open session has run so far, or null when no
  /// session is open. The quiz results screen reads this before
  /// ending the session, so it can show the real duration.
  Duration? elapsedNow() {
    final active = state;
    if (active == null) return null;
    return DateTime.now().difference(active.startedAt);
  }

  /// Ends the open session, if any, with its real duration and
  /// reviewed-card count. Junk and stale sessions are deleted.
  Future<void> end() async {
    if (!ref.mounted) return;
    final active = state;
    state = null;
    if (active == null) return;
    final repository = ref.read(studyRepositoryProvider);
    final elapsed = DateTime.now().difference(active.startedAt);
    final today = DateTime.now();
    final startedDay = DateTime(
      active.startedAt.year,
      active.startedAt.month,
      active.startedAt.day,
    );
    final isToday = startedDay == DateTime(today.year, today.month, today.day);
    try {
      if (!isToday ||
          (elapsed < _junkThreshold && active.reviewedIndexes.isEmpty)) {
        await repository.deleteSession(active.sessionId);
      } else {
        await repository.endSession(
          active.sessionId,
          durationSeconds: elapsed.inSeconds,
          cardsReviewed: active.reviewedIndexes.length,
        );
      }
    } catch (_) {
      // Best-effort: the session row stays open and contributes
      // nothing until the next start ends it.
      return;
    }
    if (!ref.mounted) return;
    ref.read(studyDataVersionProvider.notifier).bump();
  }
}

class ActiveStudySession {
  ActiveStudySession({
    required this.sessionId,
    required this.deckId,
    required this.type,
    required this.startedAt,
  });

  final int sessionId;
  final int? deckId;
  final String type;
  final DateTime startedAt;

  /// Card indexes reviewed in this session (distinct).
  final Set<int> reviewedIndexes = {};
}

final studySessionTrackerProvider =
    NotifierProvider<StudySessionTracker, ActiveStudySession?>(
      StudySessionTracker.new,
    );
