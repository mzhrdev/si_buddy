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

  Future<int> saveCardsDeck({
    required String title,
    required List<GeneratedFlashcard> cards,
  }) => repository.saveDeck(
    documentId: documentId,
    title: title,
    materialType: GenerationMaterialType.flashcards,
    flashcards: cards,
    questions: const [],
  );

  Future<int> saveQuizDeck({
    required String title,
    required List<GeneratedQuizQuestion> questions,
  }) => repository.saveDeck(
    documentId: documentId,
    title: title,
    materialType: GenerationMaterialType.mcqs,
    flashcards: const [],
    questions: questions,
  );

  group('searchStudyContent', () {
    test('finds a flashcard by its front and back text', () async {
      await saveCardsDeck(
        title: 'Cells',
        cards: const [
          GeneratedFlashcard(
            front: 'What is a cell?',
            back: 'Basic unit of life.',
          ),
          GeneratedFlashcard(front: 'What stores DNA?', back: 'The nucleus.'),
        ],
      );

      final byFront = await repository.searchStudyContent('stores DNA');
      expect(byFront, hasLength(1));
      expect(byFront.first.snippet, 'What stores DNA?');
      expect(byFront.first.isQuiz, isFalse);

      final byBack = await repository.searchStudyContent('basic unit');
      expect(byBack, hasLength(1));
      expect(byBack.first.snippet, 'What is a cell?');
    });

    test('finds a quiz question by its prompt', () async {
      await saveQuizDeck(
        title: 'Cells quiz',
        questions: const [
          GeneratedQuizQuestion(
            prompt: 'Which organelle stores DNA?',
            type: QuizQuestionType.mcq,
            options: ['Nucleus', 'Ribosome', 'Golgi', 'Mitochondrion'],
            correctIndex: 0,
          ),
        ],
      );

      final matches = await repository.searchStudyContent('ORGANELLE');
      expect(matches, hasLength(1));
      expect(matches.first.isQuiz, isTrue);
      expect(matches.first.deck.title, 'Cells quiz');
      expect(matches.first.snippet, 'Which organelle stores DNA?');
    });

    test('matches are case-insensitive and newest deck first', () async {
      await saveCardsDeck(
        title: 'Old deck',
        cards: const [GeneratedFlashcard(front: 'Nucleus facts', back: 'x')],
      );
      await saveCardsDeck(
        title: 'New deck',
        cards: const [
          GeneratedFlashcard(front: 'More nucleus facts', back: 'y'),
        ],
      );

      final matches = await repository.searchStudyContent('nucleus');
      expect(matches.map((m) => m.deck.title).toList(), [
        'New deck',
        'Old deck',
      ]);
    });

    test('empty query returns nothing and the limit caps results', () async {
      await saveCardsDeck(
        title: 'Cells',
        cards: const [
          GeneratedFlashcard(front: 'Nucleus 1', back: 'x'),
          GeneratedFlashcard(front: 'Nucleus 2', back: 'x'),
          GeneratedFlashcard(front: 'Nucleus 3', back: 'x'),
        ],
      );

      expect(await repository.searchStudyContent(''), isEmpty);
      expect(await repository.searchStudyContent('  '), isEmpty);
      expect(await repository.searchStudyContent('nucleus'), hasLength(3));

      final limited = await repository.searchStudyContent('nucleus', limit: 2);
      expect(limited, hasLength(2));
    });

    test('no match returns an empty list', () async {
      await saveCardsDeck(
        title: 'Cells',
        cards: const [GeneratedFlashcard(front: 'What is a cell?', back: 'x')],
      );
      expect(await repository.searchStudyContent('mitochondria'), isEmpty);
    });
  });
}
