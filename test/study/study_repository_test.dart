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

  List<GeneratedFlashcard> twoCards() => const [
    GeneratedFlashcard(front: 'What is a cell?', back: 'Basic unit of life.'),
    GeneratedFlashcard(front: 'What stores DNA?', back: 'The nucleus.'),
  ];

  List<GeneratedQuizQuestion> twoQuestions() => const [
    GeneratedQuizQuestion(
      prompt: 'Cells are the basic unit of life.',
      type: QuizQuestionType.trueFalse,
      options: ['True', 'False'],
      correctIndex: 0,
    ),
    GeneratedQuizQuestion(
      prompt: 'Which organelle stores DNA?',
      type: QuizQuestionType.mcq,
      options: ['Nucleus', 'Ribosome', 'Golgi', 'Mitochondrion'],
      correctIndex: 0,
    ),
  ];

  group('decks', () {
    test('saves a flashcard deck and reads it back in order', () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells',
        materialType: GenerationMaterialType.flashcards,
        flashcards: twoCards(),
        questions: const [],
      );
      final deck = await repository.getDeck(deckId);
      expect(deck, isNotNull);
      expect(deck!.title, 'Cells');
      expect(deck.totalItems, 2);
      expect(deck.isQuiz, isFalse);

      final cards = await repository.getFlashcards(deckId);
      expect(cards.map((c) => c.front), [
        'What is a cell?',
        'What stores DNA?',
      ]);
      expect(cards.first.asGenerated.back, 'Basic unit of life.');
    });

    test('saves a quiz deck with options and correct answers', () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells quiz',
        materialType: GenerationMaterialType.mcqs,
        flashcards: const [],
        questions: twoQuestions(),
      );
      final deck = await repository.getDeck(deckId);
      expect(deck!.isQuiz, isTrue);

      final questions = await repository.getQuestions(deckId);
      expect(questions, hasLength(2));
      expect(questions[1].options, [
        'Nucleus',
        'Ribosome',
        'Golgi',
        'Mitochondrion',
      ]);
      expect(questions[1].correctIndex, 0);
      expect(questions[0].asGenerated.type, QuizQuestionType.trueFalse);
    });

    test('streams deck counts per document', () async {
      expect(
        await repository.watchDeckCountForDocument(documentId).first,
        0,
      );
      await repository.saveDeck(
        documentId: documentId,
        title: 'Cells',
        materialType: GenerationMaterialType.flashcards,
        flashcards: twoCards(),
        questions: const [],
      );
      expect(
        await repository.watchDeckCountForDocument(documentId).first,
        1,
      );
    });

    test('deleting a deck removes its cards', () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells',
        materialType: GenerationMaterialType.flashcards,
        flashcards: twoCards(),
        questions: const [],
      );
      await repository.deleteDeck(deckId);
      expect(await repository.getDeck(deckId), isNull);
      expect(await repository.getFlashcards(deckId), isEmpty);
    });

    test('updating a flashcard persists the edit', () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells',
        materialType: GenerationMaterialType.flashcards,
        flashcards: twoCards(),
        questions: const [],
      );
      final cards = await repository.getFlashcards(deckId);
      await repository.updateFlashcard(
        cards.first.id,
        'Edited question?',
        'Edited answer.',
      );
      final updated = await repository.getFlashcards(deckId);
      expect(updated.first.front, 'Edited question?');
      expect(updated.first.back, 'Edited answer.');
    });
  });

  group('quiz attempts', () {
    late int deckId;
    late int questionId;

    setUp(() async {
      deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells quiz',
        materialType: GenerationMaterialType.mcqs,
        flashcards: const [],
        questions: twoQuestions(),
      );
      questionId = (await repository.getQuestions(deckId)).first.id;
    });

    test('records answers and resumes an unfinished attempt', () async {
      final attemptId = await repository.startAttempt(
        deckId: deckId,
        totalQuestions: 2,
      );
      await repository.recordAnswer(
        attemptId: attemptId,
        questionId: questionId,
        selectedIndex: 0,
        isCorrect: true,
      );
      await repository.updateAttemptProgress(attemptId, 1);

      final incomplete = await repository.getIncompleteAttempt(deckId);
      expect(incomplete, isNotNull);
      expect(incomplete!.id, attemptId);
      expect(incomplete.currentIndex, 1);

      final answers = await repository.getAnswers(attemptId);
      expect(answers, hasLength(1));
      expect(answers.first.isCorrect, isTrue);

      await repository.completeAttempt(attemptId, 1);
      expect(await repository.getIncompleteAttempt(deckId), isNull);
    });

    test('re-recording an answer replaces it instead of duplicating',
        () async {
      final attemptId = await repository.startAttempt(
        deckId: deckId,
        totalQuestions: 2,
      );
      await repository.recordAnswer(
        attemptId: attemptId,
        questionId: questionId,
        selectedIndex: 1,
        isCorrect: false,
      );
      await repository.recordAnswer(
        attemptId: attemptId,
        questionId: questionId,
        selectedIndex: 0,
        isCorrect: true,
      );
      final answers = await repository.getAnswers(attemptId);
      expect(answers, hasLength(1));
      expect(answers.first.selectedIndex, 0);
    });
  });

  group('reviews, sessions and stats', () {
    test('stats are zero with no activity', () async {
      final stats = await repository.getStats();
      expect(stats.cardsReviewed, 0);
      expect(stats.streakDays, 0);
      expect(stats.totalStudySeconds, 0);
      expect(stats.averageQuizScore, isNull);
    });

    test('reviews and sessions feed cards-reviewed, minutes and streak',
        () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells',
        materialType: GenerationMaterialType.flashcards,
        flashcards: twoCards(),
        questions: const [],
      );
      final cardId = (await repository.getFlashcards(deckId)).first.id;
      await repository.recordReview(cardId: cardId, rating: 'Easy');
      // A review yesterday too, so the streak spans two days.
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await db
          .into(db.dbCardReviews)
          .insert(
            DbCardReviewsCompanion.insert(
              cardId: cardId,
              rating: 'Hard',
              reviewedAt: yesterday,
            ),
          );
      final sessionId = await repository.startSession(
        deckId: deckId,
        type: 'flashcards',
      );
      await repository.endSession(
        sessionId,
        durationSeconds: 600,
        cardsReviewed: 2,
      );

      final stats = await repository.getStats();
      expect(stats.cardsReviewed, 2);
      expect(stats.totalFlashcardsGenerated, 2);
      expect(stats.totalStudyMinutes, 10);
      expect(stats.sessionsToday, 1);
      expect(stats.streakDays, 2);
    });

    test('quiz completion rate and average score come from attempts',
        () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells quiz',
        materialType: GenerationMaterialType.mcqs,
        flashcards: const [],
        questions: twoQuestions(),
      );
      final first = await repository.startAttempt(
        deckId: deckId,
        totalQuestions: 2,
      );
      await repository.completeAttempt(first, 2);
      await repository.startAttempt(deckId: deckId, totalQuestions: 2);

      final stats = await repository.getStats();
      expect(stats.totalQuizzesGenerated, 1);
      expect(stats.totalQuizzesAttempted, 2);
      expect(stats.quizzesCompleted, 1);
      expect(stats.quizCompletionRate, 0.5);
      expect(stats.averageQuizScore, 1.0);
    });
  });

  group('revisions', () {
    test('schedules, lists and completes a revision', () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells',
        materialType: GenerationMaterialType.flashcards,
        flashcards: twoCards(),
        questions: const [],
      );
      final revisionId = await repository.scheduleRevision(
        deckId: deckId,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        note: 'Before the exam',
      );
      final upcoming = await repository.watchUpcomingRevisions().first;
      expect(upcoming, hasLength(1));
      expect(upcoming.first.note, 'Before the exam');

      await repository.completeRevision(revisionId);
      expect(await repository.watchUpcomingRevisions().first, isEmpty);
    });
  });
}
