import 'dart:async';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';

import 'edge_ai_engine.dart';

/// The real [EdgeAiEngine]: a thin adapter over flutter_edge_ai
/// (core 2.5.2 + the LiteRT-LM engine), running Gemma 3 1B IT.
///
/// This is the ONLY file in the app (besides `main.dart`'s engine
/// registration) that names plugin types; everything above the seam
/// sees plain Dart. Construction is pure — no plugin call happens
/// until a method is invoked — so providers can build this eagerly
/// without touching platform channels.
class FlutterEdgeAiEngine implements EdgeAiEngine {
  const FlutterEdgeAiEngine();

  /// The model file, from the package's documented catalogue entry
  /// for Gemma 3 1B IT (q4, `.litertlm`, ~0.5 GB), hosted in the
  /// gated `litert-community/Gemma3-1B-IT` Hugging Face repo.
  static const String modelFileName =
      'Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096.litertlm';

  /// Direct download URL for [modelFileName] (HF `/resolve/` form,
  /// as the plugin's README uses for this exact model).
  static const String modelUrl =
      'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/'
      'Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096.litertlm';

  /// The plugin's model identity: the file name without extension.
  static const String modelId = 'Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096';

  /// Context window for generation. The bundle is the ekv4096
  /// variant (4096 tokens); `.litertlm` requires at least 1024.
  /// Prompt + reply must fit inside it — the prompt builders budget
  /// the source text accordingly.
  static const int contextTokens = 4096;

  /// Hugging Face token for the gated Gemma repo, supplied at build
  /// or run time via `--dart-define=HF_TOKEN=...`. NEVER hard-code a
  /// token here. Empty (the default) means anonymous download, which
  /// the gated repo rejects with 401/403 — surfaced as a typed
  /// [EngineDownloadException] so the UI can explain it.
  static const String _hfToken = String.fromEnvironment('HF_TOKEN');

  static String? get _tokenOrNull => _hfToken.isEmpty ? null : _hfToken;

  @override
  Future<bool> isModelReady() async {
    try {
      return FlutterEdgeAi.hasActiveModel();
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
      if (FlutterEdgeAi.hasActiveModel()) return true;
      final installed = await FlutterEdgeAi.listInstalledModels();
      return installed.contains(modelId);
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<double> downloadModel() {
    final cancelToken = CancelToken();
    late final StreamController<double> controller;
    controller = StreamController<double>(
      onListen: () async {
        try {
          await FlutterEdgeAi.installModel(
                modelType: ModelType.gemmaIt,
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
        }
      },
      onCancel: () => cancelToken.cancel('Download abandoned by the UI'),
    );
    return controller.stream;
  }

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
        model = await FlutterEdgeAi.getActiveModel(
          maxTokens: contextTokens,
        );
        if (cancelled) return;
        // Greedy decoding (topK 1): a 1B model follows the requested
        // output format far more reliably without sampling drift.
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
