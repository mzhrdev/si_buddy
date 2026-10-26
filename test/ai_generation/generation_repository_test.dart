import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/edge_ai_engine.dart';
import 'package:si_buddy/features/ai_generation/data/generation_repository_impl.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_failures.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';
import 'package:si_buddy/features/documents/domain/document_failures.dart';
import 'package:si_buddy/features/documents/domain/document_models.dart';

/// A scripted [EdgeAiEngine]: tests set the model state and either
/// the tokens a generation streams or the error it fails with.
class FakeEdgeAiEngine implements EdgeAiEngine {
  bool ready = true;
  bool installed = true;
  List<String> tokens = const [];
  Object? generationError;
  bool generateCalled = false;
  String? lastPrompt;
  bool generationCancelled = false;

  @override
  Future<bool> isModelReady() async => ready;

  @override
  Future<bool> isModelInstalled() async => installed;

  @override
  Stream<double> downloadModel() => const Stream.empty();

  @override
  Future<void> deleteModel() async {}

  @override
  Stream<String> generateText(String prompt, {int maxOutputTokens = 1024}) {
    generateCalled = true;
    lastPrompt = prompt;
    final error = generationError;
    if (error != null) return Stream.error(error);
    late StreamController<String> controller;
    controller = StreamController<String>(
      onListen: () async {
        for (final token in tokens) {
          if (controller.isClosed || !controller.hasListener) return;
          controller.add(token);
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        await controller.close();
      },
      onCancel: () async {
        generationCancelled = true;
      },
    );
    return controller.stream;
  }
}

ExtractedDocument sourceWith(String text) {
  final now = DateTime(2026, 1, 1);
  return ExtractedDocument(
    document: Document(
      id: 7,
      title: 'Cell Biology - Chapter 4',
      originalFileName: 'Cell Biology - Chapter 4.pdf',
      format: DocumentFormat.pdf,
      sizeBytes: 2400000,
      pageCount: 12,
      folderId: null,
      createdAt: now,
      updatedAt: now,
      storedPath: '/tmp/doc.pdf',
    ),
    fullText: text,
    sections: [text],
    charCount: text.length,
  );
}

const plentyOfText =
    'The mitochondria is the powerhouse of the cell and produces ATP. '
    'The nucleus stores DNA and controls cell activities. '
    'Ribosomes build proteins from amino acids following mRNA templates. '
    'Together these organelles keep the cell alive and working.';

/// Runs [stream] to completion and returns its error, or null when
/// it completed normally.
Future<Object?> captureError(Stream<GenerationProgress> stream) async {
  try {
    await stream.drain<void>();
    return null;
  } catch (error) {
    return error;
  }
}

void main() {
  late FakeEdgeAiEngine engine;
  late GenerationRepositoryImpl repository;

  setUp(() {
    engine = FakeEdgeAiEngine();
    repository = GenerationRepositoryImpl(engine: engine);
  });

  group('isModelReady', () {
    test('delegates to the engine seam', () async {
      expect(await repository.isModelReady(), isTrue);
      engine.ready = false;
      expect(await repository.isModelReady(), isFalse);
    });
  });

  group('generateFlashcards', () {
    test('emits stages in order and a terminal parsed result', () async {
      engine.tokens = [
        'Q: What produces ATP?\n',
        'A: The mitochondria.\n\n',
        'Q: What stores DNA?\nA: The nucleus.',
      ];
      final events = await repository
          .generateFlashcards(sourceWith(plentyOfText), const GenerationConfig(count: 2))
          .toList();

      // Stage order: source ready → local generation (progress) →
      // check and save, ending with the terminal result event.
      expect(events.first.stage, GenerationStage.sourceTextReady);
      expect(
        events.map((e) => e.stage).toSet(),
        containsAll(GenerationStage.values),
      );
      final stages = events.map((e) => e.stage.index).toList();
      expect(stages, orderedEquals([...stages]..sort()));
      final terminal = events.last;
      expect(terminal.isComplete, isTrue);
      expect(terminal.fraction, 1.0);
      final result = terminal.result!;
      expect(result.flashcards, hasLength(2));
      expect(result.flashcards.first.front, 'What produces ATP?');
      expect(result.itemCount, 2);
      expect(result.documentId, 7);
      // The prompt really was built from the source and config.
      expect(engine.lastPrompt, contains('mitochondria'));
    });

    test('token progress grows during the generation stage', () async {
      engine.tokens = [
        'Q: What produ',
        'ces ATP?\n',
        'A: The mito',
        'chondria.\n\n',
        'Q: What stores',
        ' DNA?\n',
        'A: The nucl',
        'eus.',
      ];
      final events = await repository
          .generateFlashcards(sourceWith(plentyOfText), const GenerationConfig())
          .toList();
      final generationFractions = events
          .where((e) => e.stage == GenerationStage.localGeneration)
          .map((e) => e.fraction)
          .toList();
      expect(generationFractions.length, greaterThan(1));
      for (var i = 1; i < generationFractions.length; i++) {
        expect(
          generationFractions[i],
          greaterThanOrEqualTo(generationFractions[i - 1]),
        );
      }
    });

    test('no active model maps to ModelNotInstalledFailure', () async {
      engine.ready = false;
      final error = await captureError(
        repository.generateFlashcards(
          sourceWith(plentyOfText),
          const GenerationConfig(),
        ),
      );
      expect(error, isA<ModelNotInstalledFailure>());
      expect(engine.generateCalled, isFalse);
    });

    test('losing the model mid-flight also maps to ModelNotInstalled', () async {
      engine.generationError = const EngineNoActiveModelException();
      final error = await captureError(
        repository.generateFlashcards(
          sourceWith(plentyOfText),
          const GenerationConfig(),
        ),
      );
      expect(error, isA<ModelNotInstalledFailure>());
    });

    test('empty text fails with InsufficientTextException before the engine runs', () async {
      final error = await captureError(
        repository.generateFlashcards(
          sourceWith('   '),
          const GenerationConfig(),
        ),
      );
      expect(error, isA<InsufficientTextException>());
      expect(engine.generateCalled, isFalse);
    });

    test('too-short text fails with InsufficientTextException', () async {
      final error = await captureError(
        repository.generateFlashcards(
          sourceWith('Too short.'),
          const GenerationConfig(),
        ),
      );
      expect(error, isA<InsufficientTextException>());
    });

    test('low-memory engine failures map to LowMemoryFailure', () async {
      engine.generationError = const EngineGenerationException(
        'cannot allocate',
        isLowMemory: true,
      );
      final error = await captureError(
        repository.generateFlashcards(
          sourceWith(plentyOfText),
          const GenerationConfig(),
        ),
      );
      expect(error, isA<LowMemoryFailure>());
    });

    test('other engine failures map to GenerationFailedFailure', () async {
      engine.generationError = const EngineGenerationException('boom');
      final error = await captureError(
        repository.generateFlashcards(
          sourceWith(plentyOfText),
          const GenerationConfig(),
        ),
      );
      expect(error, isA<GenerationFailedFailure>());
    });

    test('unparseable output fails instead of delivering an empty result', () async {
      engine.tokens = ['the model said something unstructured'];
      final error = await captureError(
        repository.generateFlashcards(
          sourceWith(plentyOfText),
          const GenerationConfig(),
        ),
      );
      expect(error, isA<GenerationFailedFailure>());
    });

    test('cancelling the subscription stops the engine and yields no result', () async {
      // Sixty 5ms chunks: generation would run ~300ms if not stopped.
      engine.tokens = List.generate(60, (i) => 'piece $i of a long answer ');
      final received = <GenerationProgress>[];
      final subscription = repository
          .generateFlashcards(sourceWith(plentyOfText), const GenerationConfig())
          .listen(received.add, onError: (_) {});
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await subscription.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(engine.generationCancelled, isTrue);
      expect(received.any((e) => e.isComplete), isFalse);
    });
  });

  group('generateQuiz', () {
    test('routes MCQ configs through the quiz path and parses them', () async {
      engine.tokens = [
        '1. Which organelle produces ATP?\nA) Nucleus\nB) Mitochondria\nC) Ribosome\nD) Golgi\nANSWER: B',
      ];
      final events = await repository
          .generateQuiz(
            sourceWith(plentyOfText),
            const GenerationConfig(
              materialType: GenerationMaterialType.mcqs,
              count: 1,
            ),
          )
          .toList();
      final result = events.last.result!;
      expect(result.flashcards, isEmpty);
      expect(result.questions, hasLength(1));
      expect(result.questions.single.correctIndex, 1);
    });
  });
}
