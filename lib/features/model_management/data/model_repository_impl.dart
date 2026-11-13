import '../../ai_generation/data/edge_ai_engine.dart';
import '../domain/model_failures.dart';
import '../domain/model_repository.dart';

/// The real [ModelRepository]: the model feature's operations,
/// delegated to the [EdgeAiEngine] seam and translated into this
/// feature's typed failures.
class ModelRepositoryImpl implements ModelRepository {
  const ModelRepositoryImpl({required this.engine});

  /// The runtime seam the operations run on.
  final EdgeAiEngine engine;

  @override
  Future<bool> isReady() => engine.isModelReady();

  @override
  Future<bool> isInstalled() => engine.isModelInstalled();

  @override
  Future<void> delete() async {
    try {
      await engine.deleteModel();
    } catch (error) {
      throw ModelOperationFailure(error.toString());
    }
  }
}
