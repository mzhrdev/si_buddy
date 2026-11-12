import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';
import 'package:si_buddy/features/documents/presentation/providers/documents_providers.dart';
import 'package:si_buddy/features/study/data/study_repository.dart';
import 'package:si_buddy/features/study/domain/study_models.dart';
import 'package:si_buddy/features/study/presentation/providers/study_providers.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int deckId;
  late int otherDeckId;

  Future<int> saveDeck(String title) async {
    final repository = StudyRepositoryImpl(db: db);
    final documentId = await db
        .into(db.dbDocuments)
        .insert(
          DbDocumentsCompanion.insert(
            title: title,
            originalFileName: '$title.pdf',
            format: 'pdf',
            sizeBytes: 1024,
            pageCount: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            storedPath: '/tmp/$title.pdf',
          ),
        );
    return repository.saveDeck(
      documentId: documentId,
      title: title,
      materialType: GenerationMaterialType.flashcards,
      flashcards: const [
        GeneratedFlashcard(front: 'Q1', back: 'A1'),
        GeneratedFlashcard(front: 'Q2', back: 'A2'),
      ],
      questions: const [],
    );
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    deckId = await saveDeck('Cells');
    otherDeckId = await saveDeck('Atoms');
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  StudySessionTracker tracker() =>
      container.read(studySessionTrackerProvider.notifier);

  Future<StudyStats> stats() =>
      container.read(studyRepositoryProvider).getStats();

  Future<List<DbStudySession>> sessions() =>
      db.select(db.dbStudySessions).get();

  group('StudySessionTracker', () {
    test('ending a session with reviews persists it', () async {
      await tracker().start(deckId: deckId, type: 'flashcards');
      tracker().recordCardReviewed(0);
      tracker().recordCardReviewed(1);
      // Re-rating the same card does not count twice.
      tracker().recordCardReviewed(0);
      await tracker().end();

      // The session row carries the distinct reviewed count; the
      // statistics' cards-reviewed counts DbCardReviews rows, which
      // only the card-rating flow writes.
      final rows = await sessions();
      expect(rows, hasLength(1));
      expect(rows.first.cardsReviewed, 2);
      expect(rows.first.endedAt, isNotNull);
      final result = await stats();
      expect(result.sessionsToday, 1);
    });

    test('a junk session (seconds, nothing reviewed) is deleted', () async {
      await tracker().start(deckId: deckId, type: 'flashcards');
      await tracker().end();

      expect(await sessions(), isEmpty);
      final result = await stats();
      expect(result.sessionsToday, 0);
      expect(result.totalStudySeconds, 0);
    });

    test('starting another deck ends the previous session', () async {
      await tracker().start(deckId: deckId, type: 'flashcards');
      tracker().recordCardReviewed(0);
      await tracker().start(deckId: otherDeckId, type: 'flashcards');
      expect(container.read(studySessionTrackerProvider)?.deckId, otherDeckId);
      await tracker().end();

      // The first session was ended (with its review) by the second
      // start; the second was junk and deleted.
      final rows = await sessions();
      expect(rows, hasLength(1));
      expect(rows.first.cardsReviewed, 1);
      final result = await stats();
      expect(result.sessionsToday, 1);
    });

    test('starting the same deck twice is a no-op', () async {
      await tracker().start(deckId: deckId, type: 'flashcards');
      tracker().recordCardReviewed(0);
      await tracker().start(deckId: deckId, type: 'flashcards');
      await tracker().end();

      final rows = await sessions();
      expect(rows, hasLength(1));
      expect(rows.first.cardsReviewed, 1);
      final result = await stats();
      expect(result.sessionsToday, 1);
    });

    test('ending with no open session is a no-op', () async {
      await tracker().end();
      expect(await sessions(), isEmpty);
      final result = await stats();
      expect(result.sessionsToday, 0);
    });
  });
}
