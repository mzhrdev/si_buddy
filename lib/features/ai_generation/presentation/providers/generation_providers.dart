import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../documents/domain/document_models.dart';
import '../../data/edge_ai_engine.dart';
import '../../data/flutter_edge_ai_engine.dart';
import '../../data/generation_repository_impl.dart';
import '../../domain/generation_config.dart';
import '../../domain/generation_models.dart';
import '../../domain/generation_repository.dart';

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
/// (flutter_edge_ai + LiteRT-LM, Gemma 3 1B — see
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
        GenerationStage.localGeneration => 'Building $noun about $topic',
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
  }) {
    return GenerationJobState(
      status: status ?? this.status,
      config: config,
      source: source,
      currentStage: currentStage ?? this.currentStage,
      fraction: fraction ?? this.fraction,
      result: result ?? this.result,
      error: error ?? this.error,
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
      (progress) {
        state = state.copyWith(
          status: progress.isComplete
              ? GenerationJobStatus.completed
              : GenerationJobStatus.running,
          currentStage: progress.stage,
          fraction: progress.fraction,
          result: progress.result,
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

  void reset() {
    _subscription?.cancel();
    state = const GenerationJobState();
  }
}

final generationJobProvider =
    NotifierProvider<GenerationJobNotifier, GenerationJobState>(
      GenerationJobNotifier.new,
    );

/// The most recent completed generation result, held for the
/// results screens. Consumption (deck/quiz persistence and display)
/// is the flashcards/quizzes phase; until then the result lives
/// here, exactly as extraction's result lives in its state.
final lastGenerationResultProvider = Provider<GenerationResult?>((ref) {
  return ref.watch(generationJobProvider).result;
});
