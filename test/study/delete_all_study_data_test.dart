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
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'deleteAllStudyData empties every study table, keeps documents',
    () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells',
        materialType: GenerationMaterialType.flashcards,
        flashcards: const [
          GeneratedFlashcard(front: 'What is a cell?', back: 'Basic unit.'),
        ],
        questions: const [],
      );
      final quizDeckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells quiz',
        materialType: GenerationMaterialType.mcqs,
        flashcards: const [],
        questions: const [
          GeneratedQuizQuestion(
            prompt: 'Cells are the basic unit of life.',
            type: QuizQuestionType.trueFalse,
            options: ['True', 'False'],
            correctIndex: 0,
          ),
        ],
      );
      final card = (await repository.getFlashcards(deckId)).single;
      await repository.recordReview(cardId: card.id, rating: 'again');
      final attemptId = await repository.startAttempt(
        deckId: quizDeckId,
        totalQuestions: 1,
      );
      final question = (await repository.getQuestions(quizDeckId)).single;
      await repository.recordAnswer(
        attemptId: attemptId,
        questionId: question.id,
        selectedIndex: 0,
        isCorrect: true,
      );
      await repository.completeAttempt(attemptId, 1);
      final sessionId = await repository.startSession(
        deckId: deckId,
        type: 'flashcards',
      );
      await repository.endSession(
        sessionId,
        durationSeconds: 120,
        cardsReviewed: 1,
      );
      await repository.scheduleRevision(
        deckId: deckId,
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        note: 'Review the hard cards',
      );
      await db
          .into(db.dbSubjects)
          .insert(
            DbSubjectsCompanion.insert(
              name: 'Biology',
              createdAt: DateTime.now(),
            ),
          );

      // Sanity: the data is really there before the wipe.
      expect((await repository.watchDecks().first).length, 2);
      expect((await repository.getStats()).totalFlashcardsGenerated, 1);
      expect((await repository.getStats()).totalQuizzesGenerated, 1);
      expect((await repository.watchUpcomingRevisions().first).length, 1);
      expect((await db.select(db.dbSubjects).get()).length, 1);

      await repository.deleteAllStudyData();

      expect(await repository.watchDecks().first, isEmpty);
      expect((await repository.getStats()).totalFlashcardsGenerated, 0);
      expect((await repository.getStats()).totalQuizzesGenerated, 0);
      expect(await repository.watchUpcomingRevisions().first, isEmpty);
      expect(await db.select(db.dbSubjects).get(), isEmpty);
      expect(await db.select(db.dbFlashcards).get(), isEmpty);
      expect(await db.select(db.dbQuizQuestions).get(), isEmpty);
      expect(await db.select(db.dbQuizAttempts).get(), isEmpty);
      expect(await db.select(db.dbQuestionAnswers).get(), isEmpty);
      expect(await db.select(db.dbCardReviews).get(), isEmpty);
      expect(await db.select(db.dbStudySessions).get(), isEmpty);
      expect(await db.select(db.dbRevisions).get(), isEmpty);
      // The document itself survives — documents are deleted
      // separately, with their stored files and extracted text.
      expect((await db.select(db.dbDocuments).get()).length, 1);
    },
  );
}
