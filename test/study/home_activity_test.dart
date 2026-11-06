import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';
import 'package:si_buddy/features/study/data/study_repository.dart';
import 'package:si_buddy/features/study/domain/study_models.dart';

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

  Future<int> saveFlashcards({String title = 'Cells'}) => repository.saveDeck(
    documentId: documentId,
    title: title,
    materialType: GenerationMaterialType.flashcards,
    flashcards: twoCards(),
    questions: const [],
  );

  group('getLatestIncompleteActivity', () {
    test('null when there are no decks', () async {
      expect(await repository.getLatestIncompleteActivity(), isNull);
    });

    test('a fresh flashcard deck is not-started work', () async {
      final deckId = await saveFlashcards();
      final activity = await repository.getLatestIncompleteActivity();
      expect(activity, isNotNull);
      expect(activity!.deck.id, deckId);
      expect(activity.kind, IncompleteActivityKind.notStarted);
      expect(activity.currentIndex, 0);
      expect(activity.totalItems, 2);
    });

    test('a partly reviewed deck reports its reviewed count', () async {
      final deckId = await saveFlashcards();
      final cards = await repository.getFlashcards(deckId);
      await repository.recordReview(cardId: cards.first.id, rating: 'Easy');
      final activity = await repository.getLatestIncompleteActivity();
      expect(activity, isNotNull);
      expect(activity!.kind, IncompleteActivityKind.flashcardsInProgress);
      expect(activity.currentIndex, 1);
      expect(activity.totalItems, 2);
      expect(activity.fraction, 0.5);
    });

    test('a fully reviewed deck is no longer unfinished work', () async {
      final deckId = await saveFlashcards();
      final cards = await repository.getFlashcards(deckId);
      for (final card in cards) {
        await repository.recordReview(cardId: card.id, rating: 'Easy');
      }
      expect(await repository.getLatestIncompleteActivity(), isNull);
    });

    test('an open quiz attempt is unfinished work at its question', () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells quiz',
        materialType: GenerationMaterialType.mcqs,
        flashcards: const [],
        questions: twoQuestions(),
      );
      final attemptId = await repository.startAttempt(
        deckId: deckId,
        totalQuestions: 2,
      );
      await repository.updateAttemptProgress(attemptId, 1);
      final activity = await repository.getLatestIncompleteActivity();
      expect(activity, isNotNull);
      expect(activity!.deck.id, deckId);
      expect(activity.kind, IncompleteActivityKind.quizIncomplete);
      expect(activity.currentIndex, 1);
      expect(activity.totalItems, 2);
    });

    test(
      'an open attempt takes precedence over a newer unstudied deck',
      () async {
        final quizDeckId = await repository.saveDeck(
          documentId: documentId,
          title: 'Cells quiz',
          materialType: GenerationMaterialType.mcqs,
          flashcards: const [],
          questions: twoQuestions(),
        );
        await repository.startAttempt(deckId: quizDeckId, totalQuestions: 2);
        await saveFlashcards(title: 'Newer deck');
        final activity = await repository.getLatestIncompleteActivity();
        expect(activity, isNotNull);
        expect(activity!.deck.id, quizDeckId);
        expect(activity.kind, IncompleteActivityKind.quizIncomplete);
      },
    );

    test('a completed attempt is not unfinished work', () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells quiz',
        materialType: GenerationMaterialType.mcqs,
        flashcards: const [],
        questions: twoQuestions(),
      );
      final attemptId = await repository.startAttempt(
        deckId: deckId,
        totalQuestions: 2,
      );
      await repository.completeAttempt(attemptId, 2);
      expect(await repository.getLatestIncompleteActivity(), isNull);
    });
  });

  group('listCompletedAttempts', () {
    test('lists finished attempts newest first with deck titles', () async {
      final deckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells quiz',
        materialType: GenerationMaterialType.mcqs,
        flashcards: const [],
        questions: twoQuestions(),
      );
      final attemptId = await repository.startAttempt(
        deckId: deckId,
        totalQuestions: 2,
      );
      await repository.completeAttempt(attemptId, 1);
      final completed = await repository.listCompletedAttempts();
      expect(completed, hasLength(1));
      expect(completed.first.deckTitle, 'Cells quiz');
      expect(completed.first.attempt.score, 1);
      expect(completed.first.attempt.totalQuestions, 2);
      expect(completed.first.attempt.isCompleted, isTrue);
    });

    test('empty when nothing is finished', () async {
      expect(await repository.listCompletedAttempts(), isEmpty);
    });
  });

  group('getStats studied today', () {
    test('counts only today’s session minutes', () async {
      final sessionId = await repository.startSession(type: 'flashcards');
      await repository.endSession(
        sessionId,
        durationSeconds: 600,
        cardsReviewed: 5,
      );
      final stats = await repository.getStats();
      expect(stats.studiedTodaySeconds, 600);
      expect(stats.studiedTodayMinutes, 10);
      expect(stats.totalStudyMinutes, 10);
      expect(stats.sessionsToday, 1);
    });
  });
}
