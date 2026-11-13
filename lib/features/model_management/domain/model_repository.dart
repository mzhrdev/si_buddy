import 'model_failures.dart';

/// The model feature's gateway to the AI service: probe its state
/// and remove a legacy on-device model file.
///
/// Implementations throw the typed [ModelFailure]s from
/// model_failures.dart. The engine seam (ai_generation/data) sits
/// under the implementation, so no plugin or seam type crosses
/// into this feature.
abstract class ModelRepository {
  /// Whether the AI service is configured and answered the health
  /// probe (generation-ready).
  Future<bool> isReady();

  /// Whether the AI service is configured (same as [isReady]: there
  /// is no on-device file anymore; the concept is now "service
  /// configured").
  Future<bool> isInstalled();

  /// Removes a legacy downloaded model file, if one is still on
  /// this device. Throws [ModelOperationFailure] on failure.
  Future<void> delete();
}
