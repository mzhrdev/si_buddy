// Typed failures for AI service operations.
//
// The service is the app's backend proxy (Groq, via the app's own
// proxy); there is no model download anymore, so there is no
// download failure type. A health probe that fails reads as "not
// configured" in the state machine, not as a failure.

/// Base type for all AI service failures.
abstract class ModelFailure implements Exception {
  const ModelFailure();

  /// User-facing explanation of what went wrong.
  String get message;

  @override
  String toString() => message;
}

/// A non-probe service operation (delete) failed.
class ModelOperationFailure extends ModelFailure {
  const ModelOperationFailure(this.reason);

  /// Technical detail for logs; the user-facing text is generic.
  final String reason;

  @override
  String get message => 'Something went wrong with the AI service. Try again.';
}
