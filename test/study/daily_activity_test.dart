import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';
import 'package:si_buddy/features/study/data/study_repository.dart';

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;
  late int documentId;
  late int deckId;
  late int cardId;
  late int questionId;

  DateTime dayStart(int daysAgo) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: daysAgo));
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = StudyRepositoryImpl(db: db);
    documentId = await db
        .into(db.dbDocuments)
        .insert(
          DbDocumentsCompanion.insert(
            title: 'Cells',
            originalFileName: 'cells.pdf',
            format: 'pdf',
            sizeBytes: 1024,
            pageCount: 3,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            storedPath: '/tmp/cells.pdf',
          ),
        );
    deckId = await repository.saveDeck(
      documentId: documentId,
      title: 'Cells',
      materialType: GenerationMaterialType.flashcards,
      flashcards: const [
        GeneratedFlashcard(front: 'What is a cell?', back: 'Basic unit.'),
      ],
      questions: const [
        GeneratedQuizQuestion(
          prompt: 'Cells are the basic unit of life.',
          type: QuizQuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 0,
        ),
      ],
    );
    cardId = (await repository.getFlashcards(deckId)).first.id;
    questionId = (await repository.getQuestions(deckId)).first.id;
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertSession({
    required DateTime startedAt,
    DateTime? endedAt,
    int durationSeconds = 0,
    int cardsReviewed = 0,
  }) async {
    await db
        .into(db.dbStudySessions)
        .insert(
          DbStudySessionsCompanion.insert(
            deckId: Value(deckId),
            startedAt: startedAt,
            endedAt: Value(endedAt),
            durationSeconds: Value(durationSeconds),
            cardsReviewed: Value(cardsReviewed),
            type: 'flashcards',
          ),
        );
  }

  group('getDailyActivity', () {
    test('returns 7 days of zeros for an empty database', () async {
      final activity = await repository.getDailyActivity(days: 7);
      expect(activity, hasLength(7));
      for (final day in activity) {
        expect(day.studySeconds, 0);
        expect(day.cardsReviewed, 0);
        expect(day.quizzesCompleted, 0);
      }
      // Oldest first, ending today.
      expect(activity.first.date, dayStart(6));
      expect(activity.last.date, dayStart(0));
    });

    test('groups sessions, reviews and completions by local day', () async {
      final today = dayStart(0).add(const Duration(hours: 10));
      final yesterday = dayStart(1).add(const Duration(hours: 10));
      final eightDaysAgo = dayStart(8).add(const Duration(hours: 10));
      await insertSession(
        startedAt: today,
        endedAt: today.add(const Duration(seconds: 90)),
        durationSeconds: 90,
        cardsReviewed: 2,
      );
      await insertSession(
        startedAt: yesterday,
        endedAt: yesterday.add(const Duration(seconds: 120)),
        durationSeconds: 120,
      );
      // An open session (no end) contributes nothing.
      await insertSession(startedAt: today, durationSeconds: 999);
      // Older than the window: excluded.
      await insertSession(
        startedAt: eightDaysAgo,
        endedAt: eightDaysAgo.add(const Duration(seconds: 600)),
        durationSeconds: 600,
      );
      await db
          .into(db.dbCardReviews)
          .insert(
            DbCardReviewsCompanion.insert(
              cardId: cardId,
              rating: 'Easy',
              reviewedAt: today,
            ),
          );
      await db
          .into(db.dbCardReviews)
          .insert(
            DbCardReviewsCompanion.insert(
              cardId: cardId,
              rating: 'Hard',
              reviewedAt: yesterday,
            ),
          );
      final attemptId = await repository.startAttempt(
        deckId: deckId,
        totalQuestions: 1,
      );
      await repository.recordAnswer(
        attemptId: attemptId,
        questionId: questionId,
        selectedIndex: 0,
      );
      await repository.completeAttempt(attemptId, 1);

      final activity = await repository.getDailyActivity(days: 7);
      final todayRow = activity.last;
      expect(todayRow.studySeconds, 90);
      expect(todayRow.cardsReviewed, 1);
      expect(todayRow.quizzesCompleted, 1);
      final yesterdayRow = activity[activity.length - 2];
      expect(yesterdayRow.studySeconds, 120);
      expect(yesterdayRow.cardsReviewed, 1);
      expect(yesterdayRow.quizzesCompleted, 0);
      // The window is 7 days: the 8-days-ago session is nowhere.
      expect(activity.fold<int>(0, (sum, day) => sum + day.studySeconds), 210);
    });
  });

  group('deleteSession', () {
    test('removes the session row entirely', () async {
      final sessionId = await repository.startSession(
        deckId: deckId,
        type: 'flashcards',
      );
      await repository.deleteSession(sessionId);
      final stats = await repository.getStats();
      expect(stats.sessionsToday, 0);
      expect(stats.totalStudySeconds, 0);
    });
  });
}
