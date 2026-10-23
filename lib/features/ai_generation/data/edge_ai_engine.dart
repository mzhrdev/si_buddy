// The engine seam: everything above the data layer talks to the
// on-device AI runtime through this small interface, never through
// the flutter_edge_ai plugin directly. The real implementation is
// `FlutterEdgeAiEngine` (flutter_edge_ai_engine.dart); tests
// substitute a fake. No plugin types appear here or anywhere above
// this file.

/// Why a model download failed, in app terms. The plugin's typed
/// download errors (401/403/404/429/5xx/network) are mapped onto
/// these kinds by the engine implementation, so the model layer can
/// build its own user-facing failures without knowing the plugin.
enum EngineDownloadErrorKind {
  /// HTTP 401 — no token, or the token was rejected.
  unauthorized,

  /// HTTP 403 — the token has not been granted access to the gated
  /// model (the Gemma license has not been accepted for the account).
  forbidden,

  /// HTTP 404 — the model file was not found at the source URL.
  notFound,

  /// HTTP 429 — rate limited by the host.
  rateLimited,

  /// HTTP 5xx — the host failed.
  server,

  /// No connectivity / transport failure.
  network,

  /// The download was cancelled through the plugin's cancel token.
  cancelled,

  /// Anything else.
  unknown,
}

/// A model download failed. Carries the mapped [kind] and the
/// plugin's detail for logs; the model layer turns this into its
/// typed `ModelDownloadFailure`.
class EngineDownloadException implements Exception {
  const EngineDownloadException(this.kind, this.message);

  final EngineDownloadErrorKind kind;

  /// Technical detail from the plugin; not shown to the user.
  final String message;

  @override
  String toString() => 'EngineDownloadException(${kind.name}): $message';
}

/// Generation was requested but no model is installed/active. Maps
/// to the generation layer's `ModelNotInstalledFailure`.
class EngineNoActiveModelException implements Exception {
  const EngineNoActiveModelException();

  @override
  String toString() => 'EngineNoActiveModelException';
}

/// Running the model failed. [isLowMemory] is the engine
/// implementation's best signal that the failure was memory pressure
/// (native OOM/allocation errors have no typed form in the plugin, so
/// the implementation recognises them from the error text — see
/// flutter_edge_ai_engine.dart). Maps to `LowMemoryFailure` when
/// true, `GenerationFailedFailure` otherwise.
class EngineGenerationException implements Exception {
  const EngineGenerationException(this.message, {this.isLowMemory = false});

  /// Technical detail from the plugin; not shown to the user.
  final String message;

  final bool isLowMemory;

  @override
  String toString() => 'EngineGenerationException: $message';
}

/// The on-device AI runtime, reduced to the four operations the app
/// needs: model state, model download, model removal, and streaming
/// text generation.
abstract class EdgeAiEngine {
  /// Whether a model is installed AND set active — generation can
  /// start immediately. Never throws: a runtime that is missing,
  /// uninitialised or erroring reads as "not ready", so callers route
  /// to the missing-model state instead of crashing.
  Future<bool> isModelReady();

  /// Whether the model file is installed on this device (whether or
  /// not it is the active one). Never throws, like [isModelReady].
  Future<bool> isModelInstalled();

  /// Downloads, installs and activates the model, emitting progress
  /// as a 0.0–1.0 fraction. Completion of the stream means the model
  /// is installed and active. Failures arrive on the error channel as
  /// [EngineDownloadException]. Cancelling the subscription cancels
  /// the download through the plugin's cancel token; a cancelled
  /// download surfaces as an [EngineDownloadException] with kind
  /// [EngineDownloadErrorKind.cancelled] if it is observed at all.
  Stream<double> downloadModel();

  /// Removes the installed model and its stored file. Throws
  /// [EngineGenerationException] on failure.
  Future<void> deleteModel();

  /// Streams the model's reply to [prompt] token by token.
  ///
  /// [maxOutputTokens] caps how much the model may generate.
  /// Cancelling the returned stream's subscription stops generation
  /// natively (the chat's stop) and releases the model. Throws
  /// [EngineNoActiveModelException] when no model is active and
  /// [EngineGenerationException] for runtime failures, both on the
  /// stream's error channel.
  Stream<String> generateText(String prompt, {int maxOutputTokens = 1024});
}
