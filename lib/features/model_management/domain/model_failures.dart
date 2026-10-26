// Typed failures for model management operations.
//
// The download failure kinds are the app-level shape of the engine
// seam's download error kinds (ai_generation/data/edge_ai_engine
// .dart): the data layer maps one onto the other, so presentation
// code never sees plugin or seam types.

/// Base type for all model management failures.
abstract class ModelFailure implements Exception {
  const ModelFailure();

  /// User-facing explanation of what went wrong.
  String get message;

  @override
  String toString() => message;
}

/// Why a model download failed, in user terms.
enum ModelDownloadErrorKind {
  /// 401/403: the model is license-gated and the download had no
  /// accepted token (none supplied, or the Gemma license has not
  /// been accepted for the token's account).
  authentication,

  /// The connection failed or dropped mid-download.
  network,

  /// The model file was not found at its source.
  notFound,

  /// The host rate-limited the download.
  rateLimited,

  /// The host returned a server error.
  server,

  /// The user cancelled the download.
  cancelled,

  /// Anything else.
  unknown,
}

/// Downloading the model failed. Routes the UI to the download
/// failed screen; [kind] lets it explain the auth case, where
/// retrying without a token can never succeed.
class ModelDownloadFailure extends ModelFailure {
  const ModelDownloadFailure(this.kind, {this.reason});

  final ModelDownloadErrorKind kind;

  /// Optional technical detail for logs; not shown to the user.
  final String? reason;

  @override
  String get message => switch (kind) {
    ModelDownloadErrorKind.authentication =>
      'The AI model is license-gated. Accept the Gemma license on '
          'Hugging Face and provide an access token (HF_TOKEN) to '
          'download it.',
    ModelDownloadErrorKind.network =>
      'The model download was interrupted. Check your internet '
          'connection and try again.',
    ModelDownloadErrorKind.notFound =>
      'The model file could not be found at its source.',
    ModelDownloadErrorKind.rateLimited =>
      'The download host is limiting requests. Wait a few minutes '
          'and try again.',
    ModelDownloadErrorKind.server =>
      'The download host had a problem. Try again later.',
    ModelDownloadErrorKind.cancelled => 'The model download was cancelled.',
    ModelDownloadErrorKind.unknown =>
      'The model download did not finish. Try again.',
  };
}

/// A non-download model operation (probe, delete) failed.
class ModelOperationFailure extends ModelFailure {
  const ModelOperationFailure(this.reason);

  /// Technical detail for logs; the user-facing text is generic.
  final String reason;

  @override
  String get message => 'Something went wrong with the AI model. Try again.';
}
