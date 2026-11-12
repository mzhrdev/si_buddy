import 'dart:async';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';

import 'edge_ai_engine.dart';

/// The real [EdgeAiEngine]: a thin adapter over flutter_edge_ai
/// (core 2.5.2 + the LiteRT-LM engine), running Qwen3 0.6B.
///
/// This is the ONLY file in the app (besides `main.dart`'s engine
/// registration) that names plugin types; everything above the seam
/// sees plain Dart. Construction is pure — no plugin call happens
/// until a method is invoked — so providers can build this eagerly
/// without touching platform channels.
class FlutterEdgeAiEngine implements EdgeAiEngine {
  const FlutterEdgeAiEngine();

  /// The model file, from the package's documented catalogue entry
  /// for Qwen3 0.6B (dynamic INT4, `.litertlm`, 343 MB), hosted in
  /// the ungated `litert-community/Qwen3-0.6B` Hugging Face repo
  /// (Apache 2.0 — no license acceptance, no token).
  ///
  /// Which build: the pinned `e6bb3e4a` revision's
  /// `..._gpu_composites` file, whose weights sit inside the graph.
  /// The current `main` file of the same name moved its weights to
  /// an external TFLiteWeights section on 2026-10-31, and its GPU
  /// path needs LiteRT-LM 0.19.0+ — the pinned
  /// flutter_edge_ai_litertlm 1.17.0 bundles 0.18.0, whose GPU
  /// engine SIGSEGVs on such a file. The `e6bb3e4a` build runs on
  /// 0.17.1–0.19.0, GPU included, per the repo's README. The
  /// revision-pinned URL also makes the download immutable.
  static const String modelFileName =
      'Qwen3-0.6B_dynamic_wi4b32_afp32_gpu_composites.litertlm';

  /// Direct download URL for [modelFileName] (HF `/resolve/` form
  /// with the pinned revision, as the model repo's README documents
  /// for this exact file).
  static const String modelUrl =
      'https://huggingface.co/litert-community/Qwen3-0.6B/resolve/'
      'e6bb3e4a1eb3f663153f0c1c12b735d64be657a7/'
      'Qwen3-0.6B_dynamic_wi4b32_afp32_gpu_composites.litertlm';

  /// The plugin's model identity: the file name without extension.
  static const String modelId =
      'Qwen3-0.6B_dynamic_wi4b32_afp32_gpu_composites';

  /// The model this app installed before the 2026-11-12 switch
  /// (Gemma 3 1B IT). Any device that already downloaded it still
  /// has the ~584 MB file on disk; [downloadModel] removes it
  /// best-effort before installing Qwen, so the old file can neither
  /// waste storage nor stay the active model after the switch.
  static const String legacyModelId =
      'Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096';

  /// Context window for generation. The bundle's default context is
  /// 4096 tokens (repo README); `.litertlm` requires at least 1024.
  /// Prompt + reply must fit inside it — the prompt builders budget
  /// the source text accordingly.
  static const int contextTokens = 4096;

  /// Hugging Face token, supplied at build or run time via
  /// `--dart-define=HF_TOKEN=...`. NEVER hard-code a token here.
  /// The Qwen repo is ungated, so no token is needed — this is kept
  /// only so a future gated model can use the same path. Empty (the
  /// default) means anonymous download, which the ungated repo
  /// accepts.
  static const String _hfToken = String.fromEnvironment('HF_TOKEN');

  static String? get _tokenOrNull => _hfToken.isEmpty ? null : _hfToken;

  /// Whether [FlutterEdgeAi.activeModelSpec] names [modelId]: the
  /// plugin derives the spec name from the installed file name
  /// (without extension), so this is true only when THIS model is
  /// the active one — not merely when any model is active. That
  /// distinction matters across a model switch: a device that still
  /// has the legacy Gemma model active must read as "not ready",
  /// or the app would show Qwen's screens while generating with
  /// Gemma and offer no way to download Qwen.
  bool _specIsCurrentModel() {
    try {
      final name = FlutterEdgeAi.activeModelSpec?.name;
      return name == modelId || name == modelFileName;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isModelReady() async {
    try {
      return _specIsCurrentModel();
    } catch (_) {
      // Plugin unregistered/uninitialised (e.g. widget tests, or a
      // platform without the engine): reads as "no model", which is
      // the honest routing signal for the missing-model state.
      return false;
    }
  }

  @override
  Future<bool> isModelInstalled() async {
    try {
      if (_specIsCurrentModel()) return true;
      final installed = await FlutterEdgeAi.listInstalledModels();
      return installed.contains(modelId);
    } catch (_) {
      return false;
    }
  }

  /// Downloads and installs the model, emitting progress 0.0–1.0.
  ///
  /// Single-flight: while a download is running, a second caller
  /// gets the SAME stream instead of starting a second native
  /// install of the same file. Re-entering the download screens
  /// (back, then Download again) used to start a parallel install,
  /// and cancelling the first subscription did not reliably stop
  /// its native WorkManager task — two installs of one model could
  /// run at once, and the abandoned one's cancel was logged after
  /// the surviving one installed the model.
  ///
  /// Model switch: before installing, the legacy Gemma model (if
  /// present) is uninstalled best-effort — it frees ~584 MB before
  /// the 343 MB download starts, and it guarantees the old model
  /// cannot stay active after the switch. A failure here (model
  /// absent, or the file locked) is swallowed: installing Qwen
  /// under its own id still works, and the stale file is then only
  /// wasted storage, not a wrong-model state.
  @override
  Stream<double> downloadModel() {
    final existing = _inFlightDownload;
    if (existing != null) return existing;
    late final Stream<double> shared;
    final cancelToken = CancelToken();
    late final StreamController<double> controller;

    void clearIfCurrent() {
      if (_inFlightDownload == shared) _inFlightDownload = null;
    }

    controller = StreamController<double>(
      onListen: () async {
        try {
          try {
            await FlutterEdgeAi.uninstallModel(legacyModelId);
          } catch (_) {
            // Legacy model absent or locked: proceed regardless —
            // see the doc comment above.
          }
          await FlutterEdgeAi.installModel(
                modelType: ModelType.qwen3,
                fileType: ModelFileType.litertlm,
              )
              .fromNetwork(modelUrl, token: _tokenOrNull)
              .withProgress((percent) {
                if (!controller.isClosed) controller.add(percent / 100);
              })
              .withCancelToken(cancelToken)
              .install();
          if (!controller.isClosed) {
            controller.add(1.0);
            await controller.close();
          }
        } on DownloadCancelledException catch (e) {
          if (!controller.isClosed) {
            controller.addError(
              EngineDownloadException(
                EngineDownloadErrorKind.cancelled,
                e.message,
              ),
            );
            await controller.close();
          }
        } catch (error) {
          if (!controller.isClosed) {
            controller.addError(_mapDownloadError(error));
            await controller.close();
          }
        } finally {
          clearIfCurrent();
        }
      },
      onCancel: () {
        cancelToken.cancel('Download abandoned by the UI');
        clearIfCurrent();
      },
    );
    shared = controller.stream.asBroadcastStream();
    _inFlightDownload = shared;
    return shared;
  }

  /// The download in flight right now, if any — see [downloadModel].
  static Stream<double>? _inFlightDownload;

  /// Maps the plugin's failures onto the seam's kinds. HTTP failures
  /// arrive as a [DownloadException] wrapping a sealed
  /// `DownloadError`; anything unrecognised keeps its text for logs.
  EngineDownloadException _mapDownloadError(Object error) {
    if (error is DownloadException) {
      final kind = switch (error.error) {
        UnauthorizedError() => EngineDownloadErrorKind.unauthorized,
        ForbiddenError() => EngineDownloadErrorKind.forbidden,
        NotFoundError() => EngineDownloadErrorKind.notFound,
        RateLimitedError() => EngineDownloadErrorKind.rateLimited,
        ServerError() => EngineDownloadErrorKind.server,
        NetworkError() => EngineDownloadErrorKind.network,
        CanceledError() => EngineDownloadErrorKind.cancelled,
        UnknownError() => EngineDownloadErrorKind.unknown,
      };
      return EngineDownloadException(kind, error.toString());
    }
    return EngineDownloadException(
      EngineDownloadErrorKind.unknown,
      error.toString(),
    );
  }

  @override
  Future<void> deleteModel() async {
    try {
      await FlutterEdgeAi.uninstallModel(modelId);
    } catch (error) {
      throw EngineGenerationException('Deleting the model failed: $error');
    }
  }

  @override
  Stream<String> generateText(String prompt, {int maxOutputTokens = 1024}) {
    late final StreamController<String> controller;
    InferenceModel? model;
    InferenceChat? chat;
    var cancelled = false;

    Future<void> run() async {
      try {
        model = await FlutterEdgeAi.getActiveModel(maxTokens: contextTokens);
        if (cancelled) return;
        // Greedy decoding (topK 1): a small model follows the
        // requested output format far more reliably without sampling
        // drift. Qwen3 is a thinking model, but the plugin appends
        // ` /no_think` for ModelType.qwen3, so no reasoning trace
        // is emitted and the reply stays parseable.
        chat = await model!.createChat(
          topK: 1,
          maxOutputTokens: maxOutputTokens,
        );
        await chat!.addQueryChunk(Message.text(text: prompt, isUser: true));
        await for (final response in chat!.generateChatResponseAsync()) {
          if (cancelled) break;
          if (response is TextResponse && !controller.isClosed) {
            controller.add(response.token);
          }
        }
        if (!controller.isClosed) await controller.close();
      } on NoActiveModelError {
        if (!controller.isClosed) {
          controller.addError(const EngineNoActiveModelException());
          await controller.close();
        }
      } catch (error) {
        if (!controller.isClosed) {
          controller.addError(
            EngineGenerationException(
              error.toString(),
              isLowMemory: _looksLikeMemoryFailure(error),
            ),
          );
          await controller.close();
        }
      } finally {
        // Release the model after each job (the evaluation's memory
        // guardrail): the next getActiveModel rebuilds it on demand.
        try {
          await model?.close();
        } catch (_) {
          // Already closed / never fully created: nothing to release.
        }
      }
    }

    controller = StreamController<String>(
      onListen: run,
      onCancel: () async {
        cancelled = true;
        // Stop native decoding; run()'s loop then unwinds and its
        // finally block releases the model.
        try {
          await chat?.stopGeneration();
        } catch (_) {
          // Generation may already be finished: stopping is a no-op.
        }
      },
    );
    return controller.stream;
  }

  /// The plugin surfaces native allocation failures as ordinary
  /// errors whose text names the memory problem; there is no typed
  /// OOM error. Recognising the known phrasings is the only signal
  /// available for the low-memory route.
  bool _looksLikeMemoryFailure(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('out of memory') ||
        text.contains('bad_alloc') ||
        text.contains('cannot allocate') ||
        text.contains('failed to allocate') ||
        text.contains('allocation failed') ||
        text.contains('insufficient memory') ||
        text.contains('low memory');
  }
}
