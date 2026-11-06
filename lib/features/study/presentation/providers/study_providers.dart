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

/// Genuine study statistics, computed from persisted rows only.
/// Recomputed whenever the deck list changes (new decks imply new
/// activity may exist); the stats query itself is cheap.
final studyStatsProvider = FutureProvider<StudyStats>((ref) async {
  ref.watch(decksStreamProvider);
  return ref.read(studyRepositoryProvider).getStats();
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
