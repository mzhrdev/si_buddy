import '../../documents/domain/document_failures.dart';
import '../../documents/domain/document_models.dart';
import '../domain/generation_config.dart';
import '../domain/generation_failures.dart';
import '../domain/generation_models.dart';
import '../domain/generation_repository.dart';
import 'edge_ai_engine.dart';
import 'generation_output_parser.dart';
import 'generation_prompts.dart';

/// The real [GenerationRepository], over the [EdgeAiEngine] seam.
///
/// Emits the interface's staged progress: `sourceTextReady` once the
/// source is validated, `localGeneration` while tokens stream from
/// the model (the fraction tracks reply growth against the expected
/// size for the requested count), and `checkAndSave` with the parsed
/// result on the final event. Nothing is persisted — saving decks
/// and cards is the flashcards/quizzes phase; cancellation simply
/// ends the stream, and the parsed result only exists on the
/// terminal event the UI holds.
class GenerationRepositoryImpl implements GenerationRepository {
  GenerationRepositoryImpl({
    required this.engine,
    this.minSourceChars = defaultMinSourceChars,
  });

  /// The runtime seam generation runs on.
  final EdgeAiEngine engine;

  /// Minimum usable source text, in characters. Below this there is
  /// not enough material for even a small set of items; the job fails
  /// with documents' `InsufficientTextException`, which the UI routes
  /// to the insufficient-text screen.
  static const int defaultMinSourceChars = 200;

  final int minSourceChars;

  @override
  Future<bool> isModelReady() => engine.isModelReady();

  @override
  Stream<GenerationProgress> generateFlashcards(
    ExtractedDocument source,
    GenerationConfig config,
  ) => _generate(source, config);

  @override
  Stream<GenerationProgress> generateQuiz(
    ExtractedDocument source,
    GenerationConfig config,
  ) => _generate(source, config);

  /// One pipeline for both entry points: the [config]'s material
  /// type drives the prompt, the parser and which result list is
  /// filled (flashcards + summaries → flashcards; the quiz types →
  /// questions), exactly as the interface documents.
  Stream<GenerationProgress> _generate(
    ExtractedDocument source,
    GenerationConfig config,
  ) async* {
    final text = source.fullText.trim();
    if (text.length < minSourceChars) {
      throw InsufficientTextException(
        fileName: source.document.originalFileName,
        charCount: text.length,
      );
    }
    if (!await engine.isModelReady()) {
      throw const ModelNotInstalledFailure();
    }

    yield const GenerationProgress(
      stage: GenerationStage.sourceTextReady,
      fraction: 0.05,
    );

    final prompt = buildGenerationPrompt(source: source, config: config);
    final buffer = StringBuffer();
    final expectedChars = _expectedOutputChars(config);

    yield const GenerationProgress(
      stage: GenerationStage.localGeneration,
      fraction: 0.1,
    );
    try {
      await for (final token in engine.generateText(
        prompt,
        maxOutputTokens: _outputTokenBudget(config),
      )) {
        buffer.write(token);
        final grown = buffer.length / expectedChars;
        yield GenerationProgress(
          stage: GenerationStage.localGeneration,
          fraction: 0.1 + 0.8 * (grown > 1 ? 1 : grown),
        );
      }
    } on EngineNoActiveModelException {
      throw const ModelNotInstalledFailure();
    } on EngineGenerationException catch (e) {
      if (e.isLowMemory) throw const LowMemoryFailure();
      throw GenerationFailedFailure(reason: e.message);
    }

    yield const GenerationProgress(
      stage: GenerationStage.checkAndSave,
      fraction: 0.95,
    );

    final output = buffer.toString();
    final result = switch (config.materialType) {
      GenerationMaterialType.flashcards => GenerationResult(
        documentId: source.document.id,
        flashcards: parseFlashcards(
          output,
          maxCount: config.count,
          includeExplanations: config.includeExplanations,
        ),
      ),
      GenerationMaterialType.summaries => GenerationResult(
        documentId: source.document.id,
        flashcards: parseSummary(
          output,
          maxCount: config.count,
          topic: config.topic,
        ),
      ),
      GenerationMaterialType.mcqs => GenerationResult(
        documentId: source.document.id,
        questions: parseMcqs(
          output,
          maxCount: config.count,
          includeExplanations: config.includeExplanations,
        ),
      ),
      GenerationMaterialType.trueFalse => GenerationResult(
        documentId: source.document.id,
        questions: parseTrueFalse(
          output,
          maxCount: config.count,
          includeExplanations: config.includeExplanations,
        ),
      ),
      GenerationMaterialType.shortAnswers => GenerationResult(
        documentId: source.document.id,
        questions: parseShortAnswers(
          output,
          maxCount: config.count,
          includeExplanations: config.includeExplanations,
        ),
      ),
    };

    if (result.isEmpty) {
      throw GenerationFailedFailure(
        reason:
            'The model produced no parseable ${config.materialType.label} '
            'items.',
      );
    }

    yield GenerationProgress(
      stage: GenerationStage.checkAndSave,
      fraction: 1,
      result: result,
    );
  }

  /// Rough size of a complete reply, for the progress fraction only:
  /// ~140 characters per flashcard/question (question + answer +
  /// explanation), ~2500 for a summary.
  int _expectedOutputChars(GenerationConfig config) {
    if (config.materialType == GenerationMaterialType.summaries) return 2500;
    return config.count * 140;
  }

  /// Output token cap for the job: ~110 tokens per item, clamped to
  /// a range the 4096-token context can hold next to the prompt.
  int _outputTokenBudget(GenerationConfig config) {
    if (config.materialType == GenerationMaterialType.summaries) return 1024;
    final budget = config.count * 110;
    return budget < 512 ? 512 : (budget > 2048 ? 2048 : budget);
  }
}
