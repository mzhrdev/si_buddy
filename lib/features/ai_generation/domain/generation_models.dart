// Domain models for AI generation results and progress: what the
// model produces, and the staged progress the generation processing
// screen renders. Plain Dart classes, in the style of the documents
// feature's models — the data layer maps runtime output into these
// types and the presentation layer only ever sees these types.

/// A question type the quiz flow can present, matching the built
/// quiz screens (MCQ, true/false, short answer). The [label]s are
/// the quiz setup screen's type-chip strings.
enum QuizQuestionType {
  mcq('MCQ'),
  trueFalse('True/False'),
  shortAnswer('Short Answer');

  const QuizQuestionType(this.label);

  /// The label as shown on the quiz screens.
  final String label;
}

/// One generated flashcard: the study card front (question) and back
/// (answer) the flashcard screens display, in the card editor's
/// "Question" / "Answer" fields.
class GeneratedFlashcard {
  const GeneratedFlashcard({
    required this.front,
    required this.back,
    this.explanation,
  });

  /// The question shown on the card front.
  final String front;

  /// The answer shown on the card back.
  final String back;

  /// Extra context shown with the answer, when the generation config
  /// had explanations on; null otherwise.
  final String? explanation;
}

/// One generated quiz question, shaped for the built quiz screens:
/// an MCQ's labelled options, a true/false prompt, or a short-answer
/// prompt with the expected answer the review screen compares
/// against.
class GeneratedQuizQuestion {
  const GeneratedQuizQuestion({
    required this.prompt,
    required this.type,
    this.options = const [],
    this.correctIndex,
    this.expectedAnswer,
    this.explanation,
  });

  /// The question text.
  final String prompt;

  /// Which quiz screen presents this question.
  final QuizQuestionType type;

  /// The answer options for [QuizQuestionType.mcq] (four, labelled
  /// A–D by the screen) and [QuizQuestionType.trueFalse]
  /// (`['True', 'False']`). Empty for short-answer questions.
  final List<String> options;

  /// Index into [options] of the correct answer, for MCQ and
  /// true/false questions. Null for short-answer questions, whose
  /// expected answer is [expectedAnswer].
  final int? correctIndex;

  /// The expected answer text for [QuizQuestionType.shortAnswer].
  final String? expectedAnswer;

  /// Why the answer is correct, shown by the answer review screen
  /// when the generation config had explanations on; null otherwise.
  final String? explanation;
}

/// The finished output of one generation job: the items produced
/// from one source document. A flashcards job fills [flashcards], a
/// quiz job fills [questions]; the other list stays empty.
class GenerationResult {
  const GenerationResult({
    required this.documentId,
    this.flashcards = const [],
    this.questions = const [],
  });

  /// The library id of the document the items were generated from.
  final int documentId;

  /// The generated flashcards, in generation order.
  final List<GeneratedFlashcard> flashcards;

  /// The generated quiz questions, in generation order.
  final List<GeneratedQuizQuestion> questions;

  /// Total items produced, across both kinds.
  int get itemCount => flashcards.length + questions.length;

  /// Whether the job produced nothing (a failure mode the UI can
  /// distinguish from a successful generation).
  bool get isEmpty => itemCount == 0;
}

/// One stage of the generation pipeline, mirroring the staged
/// checklist rendered by the generation processing screen. The
/// [label]s are the screen's exact stage titles.
enum GenerationStage {
  sourceTextReady('Text extraction complete'),
  localGeneration('Local AI generation'),
  checkAndSave('Check and save');

  const GenerationStage(this.label);

  /// The stage title as shown on the processing screen.
  final String label;
}

/// A progress event emitted while generating.
///
/// The streams returned by `GenerationRepository` emit these in
/// stage order. Intermediate events carry progress only; the final
/// event (stage [GenerationStage.checkAndSave], fraction 1.0)
/// additionally carries the finished [GenerationResult]. Failures
/// are delivered on the stream's error channel as typed failures —
/// never as events. This mirrors the documents feature's
/// `ExtractionUpdate` contract.
class GenerationProgress {
  const GenerationProgress({
    required this.stage,
    required this.fraction,
    this.result,
  });

  /// The stage currently in progress.
  final GenerationStage stage;

  /// Overall progress, 0.0–1.0 — the processing screen's percentage
  /// and progress bar.
  final double fraction;

  /// The finished generation; non-null only on the final event.
  final GenerationResult? result;

  /// Whether this is the terminal event carrying the result.
  bool get isComplete => result != null;
}
