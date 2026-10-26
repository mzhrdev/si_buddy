// Typed failures thrown by the AI generation data layer.
//
// Each failure maps to one of the already-designed error screens, so
// the presentation layer can route on the type: missing model, low
// memory, generation failure. One designed state is deliberately not
// redefined here: too little source text surfaces the documents
// feature's `InsufficientTextException` (see
// `documents/domain/document_failures.dart`), which routes to this
// feature's insufficient-text screen.

/// Base type for all generation failures.
abstract class GenerationFailure implements Exception {
  const GenerationFailure();

  /// User-facing explanation of what went wrong.
  String get message;

  @override
  String toString() => message;
}

/// No on-device AI model is installed, so generation cannot start.
/// Routes to the missing-model screen ("Install an AI model first").
class ModelNotInstalledFailure extends GenerationFailure {
  const ModelNotInstalledFailure();

  @override
  String get message =>
      'No AI model is installed. SI Buddy needs a local model before '
      'it can generate study material.';
}

/// The device did not have enough free memory to load or run the
/// model. Routes to the low-memory screen ("Not enough free memory").
class LowMemoryFailure extends GenerationFailure {
  const LowMemoryFailure();

  @override
  String get message =>
      'There is not enough free memory on this device to run the AI '
      'model right now.';
}

/// The model ran but generation did not complete: malformed output,
/// an interrupted job, a runtime error. Routes to the generation
/// failure screen ("Generation didn't finish").
class GenerationFailedFailure extends GenerationFailure {
  const GenerationFailedFailure({this.reason});

  /// Optional technical detail for logs; not shown to the user.
  final String? reason;

  @override
  String get message =>
      'Generation did not finish. Your source document is unchanged — '
      'you can try again.';
}
