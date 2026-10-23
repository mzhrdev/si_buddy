import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/generation_config.dart';
import '../../domain/generation_repository.dart';

/// The generation repository generation jobs run on.
///
/// No implementation is bound yet: the on-device model runtime has
/// not been chosen (see `MODEL_RUNTIME_EVALUATION.md` at the project
/// root), so this provider's creation throws an [UnimplementedError]
/// instead of silently substituting a fake. Code paths that require
/// an implementation read this provider and fail loudly; availability
/// checks (the generation setup screen's Generate action) should
/// read [boundGenerationRepositoryProvider] instead. When the
/// runtime is chosen, this provider is the only line that changes:
/// it will return the real implementation.
final generationRepositoryProvider = Provider<GenerationRepository>((ref) {
  throw UnimplementedError(
    'No GenerationRepository implementation is bound: the on-device '
    'model runtime has not been chosen yet.',
  );
});

/// The bound generation repository, or null while no runtime is
/// bound.
///
/// This is the lenient companion to [generationRepositoryProvider]:
/// Riverpod wraps errors thrown while creating a provider, and the
/// wrapper type is not part of Riverpod's public API, so the
/// "unbound" signal cannot be caught by type at call sites. The
/// catch lives here instead — the one place that owns the throwing
/// provider, whose only failure mode today is its deliberate
/// [UnimplementedError]. When the provider above is bound to a real
/// implementation, revisit this: creation failures of a real
/// implementation should surface, not be read as "unbound".
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
