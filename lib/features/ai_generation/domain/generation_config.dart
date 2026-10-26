// The user's choices for one AI generation job, mirroring the
// generation setup screen control for control. The screen's state
// lives in a `GenerationConfigNotifier` holding this immutable value;
// when a model runtime is bound, the same value is handed to
// `GenerationRepository` unchanged.

/// What to create, as offered by the setup screen's material-type
/// chips. The [label]s are the chips' exact strings.
enum GenerationMaterialType {
  flashcards('Flashcards'),
  mcqs('MCQs'),
  trueFalse('True/false'),
  shortAnswers('Short answers'),
  summaries('Summaries');

  const GenerationMaterialType(this.label);

  /// The chip label as shown on the setup screen.
  final String label;

  /// Whether this type produces quiz questions (routed to
  /// `GenerationRepository.generateQuiz`) rather than flashcards.
  bool get isQuiz =>
      this == GenerationMaterialType.mcqs ||
      this == GenerationMaterialType.trueFalse ||
      this == GenerationMaterialType.shortAnswers;
}

/// Difficulty, as offered by the setup screen's difficulty chips.
enum GenerationDifficulty {
  easy('Easy'),
  medium('Medium'),
  hard('Hard');

  const GenerationDifficulty(this.label);

  /// The chip label as shown on the setup screen.
  final String label;
}

/// Immutable generation configuration: exactly the state of the
/// generation setup screen.
///
/// Defaults are the design's defaults — Flashcards, 20 items, Medium,
/// topic "Cell structures", language "English", explanations on.
class GenerationConfig {
  const GenerationConfig({
    this.materialType = GenerationMaterialType.flashcards,
    this.count = defaultCount,
    this.difficulty = GenerationDifficulty.medium,
    this.topic = defaultTopic,
    this.language = defaultLanguage,
    this.includeExplanations = true,
    this.documentId,
  });

  /// The setup stepper's lower bound: decrementing stops at 1. (The
  /// design has no upper bound on this screen; the quiz setup
  /// screen's 50 cap belongs to that screen, not this one.)
  static const int minCount = 1;

  /// The design's default count.
  static const int defaultCount = 20;

  /// The design's default topic.
  static const String defaultTopic = 'Cell structures';

  /// The design's default language.
  static const String defaultLanguage = 'English';

  /// What to create (material-type chips).
  final GenerationMaterialType materialType;

  /// Cards / questions to generate ("Count" stepper).
  final int count;

  /// Difficulty chips.
  final GenerationDifficulty difficulty;

  /// The topic field's value; chosen via the topic picker.
  final String topic;

  /// The language field's value; chosen via the language picker.
  final String language;

  /// The "Include explanations" toggle ("Add context to each
  /// answer"). When off, generated items carry no explanation.
  final bool includeExplanations;

  /// The library id of the source document (the one shown on the
  /// setup screen's source card), or null when no document has been
  /// bound to the job yet.
  final int? documentId;

  GenerationConfig copyWith({
    GenerationMaterialType? materialType,
    int? count,
    GenerationDifficulty? difficulty,
    String? topic,
    String? language,
    bool? includeExplanations,
    int? documentId,
  }) {
    return GenerationConfig(
      materialType: materialType ?? this.materialType,
      count: count ?? this.count,
      difficulty: difficulty ?? this.difficulty,
      topic: topic ?? this.topic,
      language: language ?? this.language,
      includeExplanations: includeExplanations ?? this.includeExplanations,
      documentId: documentId ?? this.documentId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GenerationConfig &&
        other.materialType == materialType &&
        other.count == count &&
        other.difficulty == difficulty &&
        other.topic == topic &&
        other.language == language &&
        other.includeExplanations == includeExplanations &&
        other.documentId == documentId;
  }

  @override
  int get hashCode => Object.hash(
    materialType,
    count,
    difficulty,
    topic,
    language,
    includeExplanations,
    documentId,
  );

  @override
  String toString() =>
      'GenerationConfig(materialType: ${materialType.label}, count: $count, '
      'difficulty: ${difficulty.label}, topic: $topic, language: $language, '
      'includeExplanations: $includeExplanations, documentId: $documentId)';
}
