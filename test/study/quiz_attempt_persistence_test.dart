import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';
import 'package:si_buddy/features/ai_generation/presentation/providers/generation_providers.dart';
import 'package:si_buddy/features/documents/presentation/providers/documents_providers.dart';
import 'package:si_buddy/features/study/data/study_repository.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late StudyRepositoryImpl repository;
  late int documentId;
  late int deckId;

  const questions = [
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

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = StudyRepositoryImpl(db: db);
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
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
      title: 'Cells quiz',
      materialType: GenerationMaterialType.mcqs,
      flashcards: const [],
      questions: questions,
    );
    // Point the job at the persisted quiz deck, as `loadDeck` would.
    container.read(generationJobProvider.notifier).state = GenerationJobState(
      status: GenerationJobStatus.completed,
      deckId: deckId,
      config: GenerationConfig(
        materialType: GenerationMaterialType.mcqs,
        count: 2,
        documentId: documentId,
      ),
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  GenerationJobNotifier job() => container.read(generationJobProvider.notifier);

  group('quiz attempt persistence', () {
    test('the first answer starts an attempt and records it', () async {
      await job().recordQuizAnswer(
        prompt: 'Cells are the basic unit of life.',
        selectedIndex: 0,
      );

      final attempt = await repository.getIncompleteAttempt(deckId);
      expect(attempt, isNotNull);
      expect(attempt!.totalQuestions, 2);
      final answers = await repository.getAnswers(attempt.id);
      expect(answers, hasLength(1));
      expect(answers.first.selectedIndex, 0);
      expect(answers.first.isCorrect, true);
    });

    test('later answers reuse the same attempt', () async {
      await job().recordQuizAnswer(
        prompt: 'Cells are the basic unit of life.',
        selectedIndex: 1,
      );
      await job().recordQuizAnswer(
        prompt: 'Which organelle stores DNA?',
        selectedIndex: 0,
      );

      final attempts = await repository.listAttemptsForDeck(deckId);
      expect(attempts, hasLength(1));
      final answers = await repository.getAnswers(attempts.first.id);
      expect(answers, hasLength(2));
    });

    test(
      'completing the attempt records the score; a second call is a no-op',
      () async {
        await job().recordQuizAnswer(
          prompt: 'Cells are the basic unit of life.',
          selectedIndex: 0,
        );
        await job().completeQuizAttempt(1);
        await job().completeQuizAttempt(0);

        final attempts = await repository.listAttemptsForDeck(deckId);
        expect(attempts, hasLength(1));
        expect(attempts.first.completedAt, isNotNull);
        expect(attempts.first.score, 1);
        final stats = await repository.getStats();
        expect(stats.totalQuizzesAttempted, 1);
        expect(stats.quizzesCompleted, 1);
        // The attempt scored 1 of 2 questions.
        expect(stats.averageQuizScore, 0.5);
      },
    );

    test('an answer for an unknown prompt is ignored', () async {
      await job().recordQuizAnswer(
        prompt: 'No such question',
        selectedIndex: 0,
      );
      final attempts = await repository.listAttemptsForDeck(deckId);
      expect(attempts, isEmpty);
    });
  });

  group('card review persistence', () {
    test('rating a card writes a review row and counts it', () async {
      // The deck under test is a quiz deck; rebuild the job state
      // against a flashcard deck for the review path.
      final flashcardDeckId = await repository.saveDeck(
        documentId: documentId,
        title: 'Cells cards',
        materialType: GenerationMaterialType.flashcards,
        flashcards: const [
          GeneratedFlashcard(front: 'What is a cell?', back: 'Basic unit.'),
        ],
        questions: const [],
      );
      container.read(generationJobProvider.notifier).state = GenerationJobState(
        status: GenerationJobStatus.completed,
        deckId: flashcardDeckId,
      );
      await job().recordCardReview(0, 'Easy');

      final stats = await repository.getStats();
      expect(stats.cardsReviewed, 1);
    });
  });
}
