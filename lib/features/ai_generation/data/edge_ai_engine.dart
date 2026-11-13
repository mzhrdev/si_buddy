enum EngineDownloadErrorKind {
  // HTTP 401 — no token, or the token was rejected.
  unauthorized,
  // HTTP 403 — the token has not been granted access to the gated
  forbidden,
  // HTTP 404 — the model file was not found at the source URL.
  notFound,
  // HTTP 429 — rate limited by the host.
  rateLimited,
  // HTTP 5xx — the host failed.
  server,
  // No connectivity / transport failure.
  network,
  // The download was cancelled through the plugin's cancel token.
  cancelled,
  // Anything else.
  unknown,
}

/// A model download failed. Carries the mapped [kind] and the
/// plugin's detail for logs. Nothing in the app calls downloadModel
/// anymore (the proxy engine completes it immediately and the model
/// layer has no download flow left); the legacy engine still throws
/// this from its own download path.
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

/// Running generation failed. [isLowMemory] is the engine
/// implementation's best signal that the failure was memory pressure
/// — only the retired on-device engine ever sets it (native OOM
/// errors have no typed form in the plugin, so that implementation
/// recognises them from the error text — see
/// flutter_edge_ai_engine.dart). The proxy engine never sets it:
/// generation runs server-side, so there is no on-device memory
/// pressure to report. Maps to `LowMemoryFailure` when true,
/// `GenerationFailedFailure` otherwise.
class EngineGenerationException implements Exception {
  const EngineGenerationException(this.message, {this.isLowMemory = false});

  /// Technical detail from the plugin; not shown to the user.
  final String message;

  final bool isLowMemory;

  @override
  String toString() => 'EngineGenerationException: $message';
}

/// The AI runtime, reduced to the four operations the app needs:
/// service state, service setup (a no-op for the proxy — there is
/// nothing to download), legacy model removal, and streaming text
/// generation.
abstract class EdgeAiEngine {
  /// Whether the AI service is configured and answering — generation
  /// can start immediately. Never throws: a service that is missing,
  /// unconfigured or erroring reads as "not ready", so callers route
  /// to the missing-model state instead of crashing.
  Future<bool> isModelReady();

  /// Whether the AI service is configured. Never throws, like
  /// [isModelReady].
  Future<bool> isModelInstalled();

  /// Sets the service up, emitting progress as a 0.0–1.0 fraction.
  /// For the proxy engine there is nothing to download or install,
  /// so this completes immediately at 1.0; the legacy on-device
  /// engine used it for the real model download. Failures arrive on
  /// the error channel as [EngineDownloadException]. Cancelling the
  /// subscription cancels the setup.
  Stream<double> downloadModel();

  /// Removes a legacy downloaded model file, if one is still on
  /// this device. Throws [EngineGenerationException] on failure.
  Future<void> deleteModel();

  /// Streams the service's reply to [prompt].
  ///
  /// [maxOutputTokens] caps how much the service may generate.
  /// Cancelling the returned stream's subscription stops generation
  /// (the proxy request is aborted) and releases the connection.
  /// Throws [EngineNoActiveModelException] when no service is
  /// configured and [EngineGenerationException] for runtime
  /// failures, both on the stream's error channel.
  Stream<String> generateText(String prompt, {int maxOutputTokens = 1024});
}
