import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';
import 'package:si_buddy/features/ai_generation/presentation/providers/generation_providers.dart';
import 'package:si_buddy/features/ai_generation/presentation/providers/study_session_providers.dart';
import 'package:si_buddy/features/documents/data/document_repository_impl.dart';
import 'package:si_buddy/features/documents/presentation/providers/documents_providers.dart';
import 'package:si_buddy/features/study/data/study_repository.dart';

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl studyRepository;
  late DocumentRepositoryImpl documentRepository;
  late int documentId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    studyRepository = StudyRepositoryImpl(db: db);
    documentRepository = DocumentRepositoryImpl(db: db);
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
    await documentRepository.updateExtractedText(
      documentId,
      'Cells are the basic unit of life.\n\nThe nucleus stores DNA.',
    );
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer container() =>
      ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

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

  test('loads a persisted flashcard deck as the session result', () async {
    final deckId = await studyRepository.saveDeck(
      documentId: documentId,
      title: 'Cells',
      materialType: GenerationMaterialType.flashcards,
      flashcards: twoCards(),
      questions: const [],
    );
    final c = container();
    addTearDown(c.dispose);

    final loaded = await c
        .read(generationJobProvider.notifier)
        .loadDeck(deckId);
    expect(loaded, isTrue);

    final state = c.read(generationJobProvider);
    expect(state.status, GenerationJobStatus.completed);
    expect(state.deckId, deckId);
    expect(state.result, isNotNull);
    expect(state.result!.documentId, documentId);
    expect(state.result!.flashcards, hasLength(2));
    expect(state.result!.flashcards.first.front, 'What is a cell?');
    expect(state.source, isNotNull);
    expect(state.source!.document.id, documentId);
    expect(state.config?.materialType, GenerationMaterialType.flashcards);
    // The session starts at the first card with no ratings.
    expect(c.read(studyCardIndexProvider), 0);
    expect(c.read(cardRatingsProvider), isEmpty);
  });

  test('returns false for a deck that no longer exists', () async {
    final c = container();
    addTearDown(c.dispose);
    expect(
      await c.read(generationJobProvider.notifier).loadDeck(9999),
      isFalse,
    );
    expect(c.read(generationJobProvider).status, GenerationJobStatus.idle);
  });

  test('resume restores an unfinished quiz attempt’s answers', () async {
    final deckId = await studyRepository.saveDeck(
      documentId: documentId,
      title: 'Cells quiz',
      materialType: GenerationMaterialType.mcqs,
      flashcards: const [],
      questions: twoQuestions(),
    );
    final questions = await studyRepository.getQuestions(deckId);
    final attemptId = await studyRepository.startAttempt(
      deckId: deckId,
      totalQuestions: 2,
    );
    await studyRepository.recordAnswer(
      attemptId: attemptId,
      questionId: questions.first.id,
      selectedIndex: 0,
      isCorrect: true,
    );
    await studyRepository.updateAttemptProgress(attemptId, 1);

    final c = container();
    addTearDown(c.dispose);
    final loaded = await c
        .read(generationJobProvider.notifier)
        .loadDeck(deckId, resume: true);
    expect(loaded, isTrue);
    expect(c.read(quizAnswersProvider), {
      'Cells are the basic unit of life.': 0,
    });

    // Without resume the same deck loads with a clean session.
    final c2 = container();
    addTearDown(c2.dispose);
    await c2.read(generationJobProvider.notifier).loadDeck(deckId);
    expect(c2.read(quizAnswersProvider), isEmpty);
  });
}
