// The AI service this app generates through, and the state of it
// on this device. There is no on-device model anymore: generation
// runs through the app's backend proxy (Groq, via the app's own
// proxy), configured at build time with --dart-define=PROXY_URL /
// APP_TOKEN. The metadata values are the ones the AI service
// screen displays.

import 'model_failures.dart';

/// Identity and display metadata for the app's AI service.
class AiModelInfo {
  const AiModelInfo();

  /// Name shown on the AI service screen's package card.
  String get displayName => 'Groq AI Service';

  /// The card's "AI model" row.
  String get versionLabel => 'gpt-oss-120b · Groq';

  /// The single service the app generates through.
  static const AiModelInfo current = AiModelInfo();
}

/// Where the AI service stands for this build.
enum ModelStatus {
  /// Not yet probed this session (the notifier has not refreshed).
  unknown,

  /// The build has no AI service configured, or the health probe
  /// did not answer.
  notInstalled,

  /// The service answered the health probe — generation can run.
  ready,

  /// The last operation (probe, delete) failed; see
  /// [ModelState.failure].
  failed,
}

/// Immutable snapshot the AI service screen renders.
class ModelState {
  const ModelState({this.status = ModelStatus.unknown, this.failure});

  final ModelStatus status;

  /// The failure that put the state at [ModelStatus.failed].
  final ModelFailure? failure;

  bool get isReady => status == ModelStatus.ready;

  ModelState copyWith({ModelStatus? status, ModelFailure? failure}) {
    return ModelState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
