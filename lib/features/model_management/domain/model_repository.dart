import 'model_failures.dart';

/// The model feature's gateway to the on-device runtime: probe the
/// model's state, download it, remove it.
///
/// Implementations throw the typed [ModelFailure]s from
/// model_failures.dart. The engine seam (ai_generation/data) sits
/// under the implementation, so no plugin or seam type crosses
/// into this feature.
abstract class ModelRepository {
  /// Whether the model is installed AND active (generation-ready).
  Future<bool> isReady();

  /// Whether the model file is installed on this device.
  Future<bool> isInstalled();

  /// Downloads, installs and activates the model, emitting progress
  /// as a 0.0–1.0 fraction. The stream completes when the model is
  /// ready; failures arrive on the error channel as
  /// [ModelDownloadFailure]. Cancelling the subscription cancels
  /// the download.
  Stream<double> download();

  /// Removes the installed model. Throws [ModelOperationFailure] on
  /// failure.
  Future<void> delete();
}
