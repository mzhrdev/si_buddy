import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../data/model_repository_impl.dart';
import '../../domain/model_failures.dart';
import '../../domain/model_repository.dart';
import '../../domain/model_state.dart';

/// The model repository the AI service screen runs on.
final modelRepositoryProvider = Provider<ModelRepository>((ref) {
  return ModelRepositoryImpl(engine: ref.watch(edgeAiEngineProvider));
});

// ---------------------------------------------------------------------------
// AI service state: probes and deletion — mirroring the extraction
// job's notifier shape from the documents feature. There is no
// download anymore: the service is either configured (its health
// probe answers) or it is not.
// ---------------------------------------------------------------------------

class ModelNotifier extends Notifier<ModelState> {
  @override
  ModelState build() {
    // Deliberately no engine probe here: building state must not
    // touch the network. Screens call [refresh] when opened.
    return const ModelState();
  }

  ModelRepository get _repository => ref.read(modelRepositoryProvider);

  /// Re-probes the service: ready when the health probe answers,
  /// not installed otherwise. A probe failure reads as not
  /// installed — the engine seam already treats errors that way,
  /// and a state the UI can act on beats an error it cannot.
  Future<void> refresh() async {
    try {
      final ready = await _repository.isReady();
      state = ModelState(
        status: ready ? ModelStatus.ready : ModelStatus.notInstalled,
      );
    } catch (_) {
      state = const ModelState(status: ModelStatus.notInstalled);
    }
  }

  /// Deletes a legacy downloaded model file, if one is still on
  /// this device, and re-probes: the service state is unchanged
  /// by the deletion (generation never needed the file).
  Future<void> deleteModel() async {
    try {
      await _repository.delete();
      await refresh();
    } on ModelFailure catch (failure) {
      state = ModelState(status: ModelStatus.failed, failure: failure);
    }
  }
}

final modelProvider = NotifierProvider<ModelNotifier, ModelState>(
  ModelNotifier.new,
);
