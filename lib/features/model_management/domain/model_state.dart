// The one on-device model this app installs, and the state of it on
// this device. The metadata values are the ones the model
// management screens display; they come from the runtime evaluation
// (the package's supported-models table), not from probing the
// device.

import 'model_failures.dart';

/// Identity and display metadata for the app's AI model.
class AiModelInfo {
  const AiModelInfo();

  /// Name shown on the model screens' package card.
  String get displayName => 'Gemma 3 1B IT';

  /// The card's "Model version" row.
  String get versionLabel => 'Gemma 3 1B IT · q4 (.litertlm)';

  /// The card's "Download size" row (the catalogue's rounded size).
  String get downloadSizeLabel => '0.5 GB';

  /// The single model the app manages.
  static const AiModelInfo current = AiModelInfo();
}

/// Where the model stands on this device.
enum ModelStatus {
  /// Not yet probed this session (the notifier has not refreshed).
  unknown,

  /// No model file is installed.
  notInstalled,

  /// A download is running; see [ModelState.downloadProgress].
  downloading,

  /// Installed and active — generation can run.
  ready,

  /// The last operation (download, delete, probe) failed; see
  /// [ModelState.failure].
  failed,
}

/// Immutable snapshot the model screens render.
class ModelState {
  const ModelState({
    this.status = ModelStatus.unknown,
    this.downloadProgress = 0,
    this.failure,
  });

  final ModelStatus status;

  /// Download completion, 0.0–1.0; meaningful only while
  /// [status] is [ModelStatus.downloading].
  final double downloadProgress;

  /// The failure that put the state at [ModelStatus.failed].
  final ModelFailure? failure;

  bool get isReady => status == ModelStatus.ready;
  bool get isDownloading => status == ModelStatus.downloading;

  ModelState copyWith({
    ModelStatus? status,
    double? downloadProgress,
    ModelFailure? failure,
    bool clearFailure = false,
  }) {
    return ModelState(
      status: status ?? this.status,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}
