import '../../documents/domain/document_models.dart';
import 'generation_config.dart';
import 'generation_models.dart';

/// The AI generation feature's gateway to the on-device model.
///
/// Implementations throw the typed failures from
/// `generation_failures.dart`; the UI routes to the matching designed
/// error screen based on the failure type. A source document with too
/// little text fails with the documents feature's
/// `InsufficientTextException` instead — generation reuses that
/// failure rather than redefining it.
///
/// The bound implementation is `GenerationRepositoryImpl`
/// (ai_generation/data), running on flutter_edge_ai + the LiteRT-LM
/// engine through the `EdgeAiEngine` seam.
abstract class GenerationRepository {
  /// Whether an AI model is installed on this device and ready to
  /// generate. The generation setup screen's Generate action consults
  /// this before routing: ready → the processing screen, not ready →
  /// the missing-model screen.
  Future<bool> isModelReady();

  /// Generates flashcards from [source]'s extracted text, following
  /// [config] (count, difficulty, topic, language, explanations).
  ///
  /// Progress is emitted as [GenerationProgress] events in stage
  /// order (sourceTextReady → localGeneration → checkAndSave). The
  /// final event carries the [GenerationResult]; see
  /// [GenerationProgress] for the contract.
  ///
  /// Cancelling the returned stream's subscription aborts the job;
  /// nothing is persisted in that case, matching the extraction
  /// stream's semantics. Failures arrive on the stream's error
  /// channel: [ModelNotInstalledFailure] when no model is installed,
  /// [LowMemoryFailure] when the device cannot host the model,
  /// `InsufficientTextException` when the source has too little text,
  /// and [GenerationFailedFailure] for anything else that stops the
  /// job.
  Stream<GenerationProgress> generateFlashcards(
    ExtractedDocument source,
    GenerationConfig config,
  );

  /// Generates quiz questions from [source]'s extracted text. The
  /// [config]'s material type selects the question kind (MCQs,
  /// true/false or short answers); count, difficulty, topic, language
  /// and the explanations toggle apply as in [generateFlashcards].
  ///
  /// Same stream contract as [generateFlashcards]: staged
  /// [GenerationProgress] events, the result on the final event,
  /// typed failures on the error channel, and cancellation by
  /// unsubscribing before anything is persisted.
  Stream<GenerationProgress> generateQuiz(
    ExtractedDocument source,
    GenerationConfig config,
  );
}
