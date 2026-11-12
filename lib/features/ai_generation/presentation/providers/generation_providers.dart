import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../documents/domain/document_models.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../../data/edge_ai_engine.dart';
import '../../data/flutter_edge_ai_engine.dart';
import '../../data/generation_repository_impl.dart';
import '../../domain/generation_config.dart';
import '../../domain/generation_models.dart';
import '../../domain/generation_repository.dart';
import 'study_session_providers.dart';

/// The on-device AI runtime seam the whole app runs on.
///
/// Construction is pure Dart (no platform channel is touched until
/// a method runs), so this can be provided eagerly; tests override
/// it with a fake engine.
final edgeAiEngineProvider = Provider<EdgeAiEngine>((ref) {
  return const FlutterEdgeAiEngine();
});

/// The generation repository generation jobs run on: the real
/// implementation over the [edgeAiEngineProvider] seam
/// (flutter_edge_ai + LiteRT-LM, Qwen3 0.6B — see
/// MODEL_RUNTIME_EVALUATION.md).
final generationRepositoryProvider = Provider<GenerationRepository>((ref) {
  return GenerationRepositoryImpl(engine: ref.watch(edgeAiEngineProvider));
});

/// The bound generation repository, or null if creating it failed.
///
/// Kept from the interface phase as the setup screen's availability
/// seam. Creation of the real implementation is a pure constructor
/// and cannot fail; the try/catch remains only so a future binding
/// that CAN fail at creation degrades to the missing-model route
/// instead of crashing the setup screen.
final boundGenerationRepositoryProvider = Provider<GenerationRepository?>((
  ref,
) {
  try {
    return ref.watch(generationRepositoryProvider);
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------------------
// Generation config: the setup screen's state, one notifier method
// per control.
// ---------------------------------------------------------------------------

class GenerationConfigNotifier extends Notifier<GenerationConfig> {
  @override
  GenerationConfig build() => const GenerationConfig();

  /// Material-type chips (Flashcards / MCQs / True/false / Short
  /// answers / Summaries).
  void setMaterialType(GenerationMaterialType type) {
    state = state.copyWith(materialType: type);
  }

  /// Difficulty chips (Easy / Medium / Hard).
  void setDifficulty(GenerationDifficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  /// The count stepper's value, clamped at the design's lower bound
  /// of [GenerationConfig.minCount]. The setup screen's stepper has
  /// no upper bound, so neither does this.
  void setCount(int count) {
    state = state.copyWith(
      count: count < GenerationConfig.minCount
          ? GenerationConfig.minCount
          : count,
    );
  }

  /// The stepper's plus button.
  void incrementCount() => setCount(state.count + 1);

  /// The stepper's minus button; stops at the minimum.
  void decrementCount() => setCount(state.count - 1);

  /// The topic field, once the topic picker supplies a value.
  void setTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  /// The language field, once the language picker supplies a value.
  void setLanguage(String language) {
    state = state.copyWith(language: language);
  }

  /// The "Include explanations" toggle.
  void setIncludeExplanations(bool include) {
    state = state.copyWith(includeExplanations: include);
  }

  /// Binds the job to a library document (the setup screen's source
  /// card).
  void setDocumentId(int documentId) {
    state = state.copyWith(documentId: documentId);
  }
}

final generationConfigProvider =
    NotifierProvider<GenerationConfigNotifier, GenerationConfig>(
      GenerationConfigNotifier.new,
    );

// ---------------------------------------------------------------------------
// Generation job: consumes the repository's progress stream and
// exposes exactly the state the processing screen renders — the
// mirror of the documents feature's ExtractionNotifier.
// ---------------------------------------------------------------------------

/// Lifecycle of a generation job.
enum GenerationJobStatus { idle, running, completed, failed, cancelled }

/// Where a stage sits relative to the job's current stage (the same
/// three states the documents feature's extraction UI uses).
enum JobStageStatus { upcoming, active, complete }

class GenerationJobState {
  const GenerationJobState({
    this.status = GenerationJobStatus.idle,
    this.config,
    this.source,
    this.currentStage,
    this.fraction = 0,
    this.result,
    this.error,
    this.deckId,
  });

  final GenerationJobStatus status;

  /// The config the job is running with.
  final GenerationConfig? config;

  /// The document the job is generating from.
  final ExtractedDocument? source;

  /// The stage currently in progress.
  final GenerationStage? currentStage;

  /// Overall progress, 0.0–1.0.
  final double fraction;

  /// The finished generation, once [status] is completed.
  final GenerationResult? result;

  /// The failure that ended the job, once [status] is failed.
  final Object? error;

  /// The persisted deck id for the completed result, once the
  /// result has been saved to the local database. Null when the job
  /// has not completed or the save failed (the in-memory result
  /// still drives the current session in that case).
  final int? deckId;

  /// The processing screen's stage states (complete/active/upcoming).
  JobStageStatus statusOf(GenerationStage stage) {
    if (status == GenerationJobStatus.completed) {
      return JobStageStatus.complete;
    }
    final current = currentStage;
    if (current == null) {
      return stage == GenerationStage.sourceTextReady &&
              status == GenerationJobStatus.running
          ? JobStageStatus.active
          : JobStageStatus.upcoming;
    }
    if (stage.index < current.index) return JobStageStatus.complete;
    if (stage == current) return JobStageStatus.active;
    return JobStageStatus.upcoming;
  }

  /// The checklist subtitle for a stage. Complete/active subtitles
  /// follow the design's own strings ('Reviewed source text is
  /// ready', 'Building cards about cell structures', 'Starts after
  /// generation finishes'); the rest follow the same voice.
  String subtitleFor(GenerationStage stage) {
    final topic = config?.topic ?? '';
    final noun = switch (config?.materialType) {
      GenerationMaterialType.flashcards => 'cards',
      GenerationMaterialType.summaries => 'summary sections',
      GenerationMaterialType.shortAnswers => 'answers',
      _ => 'questions',
    };
    return switch (statusOf(stage)) {
      JobStageStatus.complete => switch (stage) {
        GenerationStage.sourceTextReady => 'Reviewed source text is ready',
        _ => 'Complete',
      },
      JobStageStatus.active => switch (stage) {
        GenerationStage.sourceTextReady => 'Preparing your reviewed text',
        GenerationStage.localGeneration =>
          topic.isEmpty ? 'Building $noun' : 'Building $noun about $topic',
        GenerationStage.checkAndSave => 'Checking and saving your material',
      },
      JobStageStatus.upcoming => switch (stage) {
        GenerationStage.sourceTextReady => 'Up next · prepare the source text',
        GenerationStage.localGeneration =>
          'Starts after the source text is ready',
        GenerationStage.checkAndSave => 'Starts after generation finishes',
      },
    };
  }

  GenerationJobState copyWith({
    GenerationJobStatus? status,
    GenerationStage? currentStage,
    double? fraction,
    GenerationResult? result,
    Object? error,
    int? deckId,
  }) {
    return GenerationJobState(
      status: status ?? this.status,
      config: config,
      source: source,
      currentStage: currentStage ?? this.currentStage,
      fraction: fraction ?? this.fraction,
      result: result ?? this.result,
      error: error ?? this.error,
      deckId: deckId ?? this.deckId,
    );
  }
}

class GenerationJobNotifier extends Notifier<GenerationJobState> {
  StreamSubscription<GenerationProgress>? _subscription;

  @override
  GenerationJobState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const GenerationJobState();
  }

  /// Starts generating [config]'s material from [source], replacing
  /// any job already in progress. The setup screen checks model
  /// readiness before calling this; failures during the job land in
  /// [GenerationJobState.error] for the processing screen to route.
  void start({
    required ExtractedDocument source,
    required GenerationConfig config,
  }) {
    _subscription?.cancel();
    // A new job starts a clean session: ratings, answers and the
    // card/question index from the previous deck must not leak into
    // this one — a stale rating count would otherwise show the new
    // deck as already reviewed (and the Finish action too early),
    // and a stale attempt id would record new answers into the old
    // quiz's attempt.
    _currentAttemptId = null;
    ref.read(studyCardIndexProvider.notifier).reset();
    ref.read(reviewIndexProvider.notifier).reset();
    ref.read(quizQuestionIndexProvider.notifier).reset();
    ref.read(cardRatingsProvider.notifier).clear();
    ref.read(quizAnswersProvider.notifier).clear();
    ref.read(quizShortAnswersProvider.notifier).clear();
    state = GenerationJobState(
      status: GenerationJobStatus.running,
      config: config,
      source: source,
      currentStage: GenerationStage.sourceTextReady,
    );
    final repository = ref.read(generationRepositoryProvider);
    final stream = config.materialType.isQuiz
        ? repository.generateQuiz(source, config)
        : repository.generateFlashcards(source, config);
    _subscription = stream.listen(
      (progress) async {
        // On completion, persist the result as a deck before the
        // state flips to completed, so the deck overview can rely
        // on the persisted deck. A save failure never fails the
        // generation the user just watched complete: the in-memory
        // result still drives this session.
        var deckId = state.deckId;
        if (progress.isComplete && progress.result != null) {
          deckId = await _persistResult(progress.result!);
        }
        state = state.copyWith(
          status: progress.isComplete
              ? GenerationJobStatus.completed
              : GenerationJobStatus.running,
          currentStage: progress.stage,
          fraction: progress.fraction,
          result: progress.result,
          deckId: deckId,
        );
      },
      onError: (Object error) {
        state = state.copyWith(
          status: GenerationJobStatus.failed,
          error: error,
        );
      },
      onDone: () {
        // A stream that ends without a result or an error was
        // aborted upstream (cancellation reaching the source).
        if (state.status == GenerationJobStatus.running) {
          state = state.copyWith(status: GenerationJobStatus.cancelled);
        }
      },
    );
  }

  /// Persists a completed generation result as a deck and returns
  /// its id, or null when the result cannot be saved (missing
  /// source/config, or a database failure). Saving is best-effort
  /// by design: the job already succeeded, and the in-memory
  /// result keeps the current session working.
  Future<int?> _persistResult(GenerationResult result) async {
    final config = state.config;
    final source = state.source;
    if (config == null || source == null) return null;
    try {
      return await ref
          .read(studyRepositoryProvider)
          .saveDeck(
            documentId: source.document.id,
            title: generatedMaterialTitle(
              config: config,
              documentName: source.document.originalFileName,
            ),
            materialType: config.materialType,
            flashcards: result.flashcards,
            questions: result.questions,
          );
    } catch (_) {
      return null;
    }
  }

  /// Cancels the running job. The engine stops generating and
  /// nothing is persisted.
  void cancel() {
    _subscription?.cancel();
    if (state.status == GenerationJobStatus.running) {
      state = state.copyWith(status: GenerationJobStatus.cancelled);
    }
  }

  /// Restarts the last job with the same source and config (the
  /// generation failure screen's Retry). Returns false when there
  /// is no job to retry.
  bool retry() {
    final source = state.source;
    final config = state.config;
    if (source == null || config == null) return false;
    start(source: source, config: config);
    return true;
  }

  /// Loads a persisted deck as the current session result, so the
  /// deck overview, study cards and quiz screens — which all read
  /// the session result — can open any deck from the library or
  /// Home, not just the one generated this session. Returns false
  /// when the deck (or its document's extracted text) no longer
  /// exists.
  ///
  /// With [resume] true, an unfinished quiz attempt's recorded
  /// answers are restored into the session, so Continue resumes
  /// where the user left off; otherwise the session starts clean.
  Future<bool> loadDeck(int deckId, {bool resume = false}) async {
    final studyRepository = ref.read(studyRepositoryProvider);
    final deck = await studyRepository.getDeck(deckId);
    if (deck == null) return false;
    final source = await ref
        .read(documentRepositoryProvider)
        .getExtractedDocument(deck.documentId);
    if (source == null) return false;
    final flashcards = await studyRepository.getFlashcards(deckId);
    final questions = await studyRepository.getQuestions(deckId);
    final result = GenerationResult(
      documentId: deck.documentId,
      flashcards: [for (final card in flashcards) card.asGenerated],
      questions: [for (final question in questions) question.asGenerated],
    );
    final config = GenerationConfig(
      materialType: deck.materialType,
      count: deck.totalItems,
      documentId: deck.documentId,
    );
    // Reset the session to the deck's start; resume restores the
    // unfinished attempt's answers instead.
    ref.read(studyCardIndexProvider.notifier).reset();
    ref.read(reviewIndexProvider.notifier).reset();
    ref.read(quizQuestionIndexProvider.notifier).reset();
    ref.read(cardRatingsProvider.notifier).clear();
    ref.read(quizAnswersProvider.notifier).clear();
    ref.read(quizShortAnswersProvider.notifier).clear();
    int? resumedAttemptId;
    if (resume) {
      final attempt = await studyRepository.getIncompleteAttempt(deckId);
      resumedAttemptId = attempt?.id;
      if (attempt != null) {
        final answers = await studyRepository.getAnswers(attempt.id);
        final questionsById = {
          for (final question in questions) question.id: question,
        };
        for (final answer in answers) {
          final question = questionsById[answer.questionId];
          if (question == null) continue;
          if (answer.selectedIndex != null) {
            ref
                .read(quizAnswersProvider.notifier)
                .answer(question.prompt, answer.selectedIndex!);
          } else if (answer.answerText != null) {
            ref
                .read(quizShortAnswersProvider.notifier)
                .answer(question.prompt, answer.answerText!);
          }
        }
      }
    }
    state = GenerationJobState(
      status: GenerationJobStatus.completed,
      config: config,
      source: source,
      result: result,
      deckId: deckId,
    );
    // Studying this deck starts a study session (Phase 5): the
    // tracker ends it when the deck is left or another deck opens.
    // Awaited — it is one local database write, and the session
    // must exist before the study screens build.
    await ref
        .read(studySessionTrackerProvider.notifier)
        .start(deckId: deckId, type: deck.isQuiz ? 'quiz' : 'flashcards');
    // A resumed quiz continues its unfinished attempt instead of
    // starting a new one.
    _currentAttemptId = resume && deck.isQuiz ? resumedAttemptId : null;
    return true;
  }

  /// Replaces one flashcard in the completed result (the card
  /// editor's Save), and writes the same edit to the persisted
  /// deck when the result was saved. Returns false when there is
  /// no completed result or the index is out of range.
  bool updateFlashcard(int index, String front, String back) {
    final result = state.result;
    if (result == null || index < 0 || index >= result.flashcards.length) {
      return false;
    }
    final cards = List<GeneratedFlashcard>.of(result.flashcards);
    cards[index] = GeneratedFlashcard(
      front: front,
      back: back,
      explanation: cards[index].explanation,
    );
    state = state.copyWith(
      result: GenerationResult(
        documentId: result.documentId,
        flashcards: cards,
        questions: result.questions,
      ),
    );
    final deckId = state.deckId;
    if (deckId != null) {
      _persistFlashcardEdit(deckId, index, front, back);
    }
    return true;
  }

  /// Writes one card edit to the persisted deck, best-effort: the
  /// in-memory edit is already applied, so a failure here only
  /// means the edit does not survive a restart.
  Future<void> _persistFlashcardEdit(
    int deckId,
    int index,
    String front,
    String back,
  ) async {
    try {
      final repository = ref.read(studyRepositoryProvider);
      final cards = await repository.getFlashcards(deckId);
      if (index < cards.length) {
        await repository.updateFlashcard(cards[index].id, front, back);
      }
    } catch (_) {
      // Best-effort only; the session result already has the edit.
    }
  }

  /// The quiz attempt the current quiz is recording into (null
  /// when no quiz is being taken). Lazily started on the first
  /// recorded answer, or restored by [loadDeck] when resuming.
  int? _currentAttemptId;

  /// Records a self-rating for the card at [index] in the persisted
  /// deck (Phase 5): the rating survives a restart and feeds the
  /// statistics' cards-reviewed count. Best-effort — the session
  /// rating is already applied by the caller.
  Future<void> recordCardReview(int index, String rating) async {
    final deckId = state.deckId;
    if (deckId == null) return;
    ref.read(studySessionTrackerProvider.notifier).recordCardReviewed(index);
    try {
      final repository = ref.read(studyRepositoryProvider);
      final cards = await repository.getFlashcards(deckId);
      if (index < cards.length) {
        await repository.recordReview(cardId: cards[index].id, rating: rating);
        ref.read(studyDataVersionProvider.notifier).bump();
      }
    } catch (_) {
      // Best-effort only; the session rating already exists.
    }
  }

  /// Records one quiz answer in the persisted attempt (Phase 5):
  /// the attempt starts lazily on the first answer (or continues the
  /// resumed attempt), so quiz progress survives a restart and the
  /// statistics' attempts/completion/score are real. Best-effort —
  /// the session answer is already applied by the caller.
  Future<void> recordQuizAnswer({
    required String prompt,
    int? selectedIndex,
    String? answerText,
  }) async {
    final deckId = state.deckId;
    if (deckId == null) return;
    try {
      final repository = ref.read(studyRepositoryProvider);
      final questions = await repository.getQuestions(deckId);
      final question = questions.where((q) => q.prompt == prompt).firstOrNull;
      if (question == null) return;
      var attemptId = _currentAttemptId;
      attemptId ??= await repository
          .getIncompleteAttempt(deckId)
          .then((attempt) => attempt?.id);
      attemptId ??= await repository.startAttempt(
        deckId: deckId,
        totalQuestions: questions.length,
      );
      _currentAttemptId = attemptId;
      // Scoreable questions (MCQ / true-false) record whether the
      // answer was right; short answers stay unscored (null).
      final isCorrect = question.correctIndex == null
          ? null
          : selectedIndex == question.correctIndex;
      await repository.recordAnswer(
        attemptId: attemptId,
        questionId: question.id,
        selectedIndex: selectedIndex,
        answerText: answerText,
        isCorrect: isCorrect,
      );
      ref.read(studyDataVersionProvider.notifier).bump();
    } catch (_) {
      // Best-effort only; the session answer already exists.
    }
  }

  /// Completes the quiz attempt being recorded, with the final
  /// [score] (correct answers). A no-op when no quiz is being
  /// taken — calling it twice is safe.
  Future<void> completeQuizAttempt(int score) async {
    final attemptId = _currentAttemptId;
    _currentAttemptId = null;
    if (attemptId == null) return;
    try {
      await ref.read(studyRepositoryProvider).completeAttempt(attemptId, score);
      ref.read(studyDataVersionProvider.notifier).bump();
    } catch (_) {
      // Best-effort only; the session results screen already shows
      // the score.
    }
  }

  void reset() {
    _subscription?.cancel();
    _currentAttemptId = null;
    state = const GenerationJobState();
    // Leaving the deck ends the open study session with its real
    // duration. Fire-and-forget: the reset itself never waits.
    unawaited(ref.read(studySessionTrackerProvider.notifier).end());
  }
}

final generationJobProvider =
    NotifierProvider<GenerationJobNotifier, GenerationJobState>(
      GenerationJobNotifier.new,
    );

/// The title for a generated deck or quiz: the user's topic when
/// one was picked, otherwise the source document's file name,
/// otherwise a neutral label — never the design's sample topic.
String generatedMaterialTitle({
  required GenerationConfig config,
  String? documentName,
}) {
  if (config.topic.isNotEmpty) return config.topic;
  if (documentName != null && documentName.isNotEmpty) {
    return documentName;
  }
  return 'Generated material';
}

/// The most recent completed generation result, held for the
/// results screens. Consumption (deck/quiz persistence and display)
/// is the flashcards/quizzes phase; until then the result lives
/// here, exactly as extraction's result lives in its state.
final lastGenerationResultProvider = Provider<GenerationResult?>((ref) {
  return ref.watch(generationJobProvider).result;
});
