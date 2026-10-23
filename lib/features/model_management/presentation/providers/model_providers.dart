import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../data/model_repository_impl.dart';
import '../../domain/model_failures.dart';
import '../../domain/model_repository.dart';
import '../../domain/model_state.dart';

/// The model repository the model screens run on.
final modelRepositoryProvider = Provider<ModelRepository>((ref) {
  return ModelRepositoryImpl(engine: ref.watch(edgeAiEngineProvider));
});

// ---------------------------------------------------------------------------
// Model state: probes, the download, and deletion — mirroring the
// extraction job's notifier shape from the documents feature.
// ---------------------------------------------------------------------------

class ModelNotifier extends Notifier<ModelState> {
  StreamSubscription<double>? _downloadSubscription;

  @override
  ModelState build() {
    ref.onDispose(() => _downloadSubscription?.cancel());
    // Deliberately no engine probe here: building state must not
    // touch platform channels. Screens call [refresh] when opened.
    return const ModelState();
  }

  ModelRepository get _repository => ref.read(modelRepositoryProvider);

  /// Re-probes the runtime: ready when a model is active, not
  /// installed otherwise. A probe failure reads as not installed —
  /// the engine seam already treats runtime errors that way, and a
  /// state the UI can act on beats an error it cannot.
  /// Does nothing while a download is running.
  Future<void> refresh() async {
    if (state.isDownloading) return;
    try {
      final ready = await _repository.isReady();
      if (state.isDownloading) return; // a download started meanwhile
      state = ModelState(
        status: ready ? ModelStatus.ready : ModelStatus.notInstalled,
      );
    } catch (_) {
      if (!state.isDownloading) {
        state = const ModelState(status: ModelStatus.notInstalled);
      }
    }
  }

  /// Starts the model download (or restarts a failed one), driving
  /// [ModelState.downloadProgress] until the model is ready or the
  /// download fails into [ModelStatus.failed].
  void startDownload() {
    if (state.isDownloading) return;
    _downloadSubscription?.cancel();
    state = const ModelState(
      status: ModelStatus.downloading,
      downloadProgress: 0,
    );
    _downloadSubscription = _repository
        .download()
        .listen(
          (progress) {
            state = state.copyWith(
              status: ModelStatus.downloading,
              downloadProgress: progress,
              clearFailure: true,
            );
          },
          onError: (Object error) {
            state = ModelState(
              status: ModelStatus.failed,
              failure: error is ModelFailure
                  ? error
                  : ModelDownloadFailure(
                      ModelDownloadErrorKind.unknown,
                      reason: error.toString(),
                    ),
            );
          },
          onDone: () {
            // The engine's stream completes only after a successful
            // install; an error already moved the state to failed.
            if (state.isDownloading) {
              state = const ModelState(
                status: ModelStatus.ready,
                downloadProgress: 1,
              );
            }
          },
        );
  }

  /// Cancels the running download (the seam cancels it natively via
  /// the plugin's cancel token) and returns to not installed.
  void cancelDownload() {
    _downloadSubscription?.cancel();
    _downloadSubscription = null;
    if (state.isDownloading) {
      state = const ModelState(status: ModelStatus.notInstalled);
    }
  }

  /// Deletes the installed model, returning to not installed.
  Future<void> deleteModel() async {
    try {
      await _repository.delete();
      state = const ModelState(status: ModelStatus.notInstalled);
    } on ModelFailure catch (failure) {
      state = ModelState(status: ModelStatus.failed, failure: failure);
    }
  }
}

final modelProvider = NotifierProvider<ModelNotifier, ModelState>(
  ModelNotifier.new,
);
