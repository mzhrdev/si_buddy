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
  Stream<double> download() {
    return engine.downloadModel().handleError((Object error) {
      if (error is EngineDownloadException) {
        throw ModelDownloadFailure(
          _mapKind(error.kind),
          reason: error.message,
        );
      }
      throw ModelDownloadFailure(
        ModelDownloadErrorKind.unknown,
        reason: error.toString(),
      );
    });
  }

  @override
  Future<void> delete() async {
    try {
      await engine.deleteModel();
    } catch (error) {
      throw ModelOperationFailure(error.toString());
    }
  }

  ModelDownloadErrorKind _mapKind(EngineDownloadErrorKind kind) {
    return switch (kind) {
      EngineDownloadErrorKind.unauthorized ||
      EngineDownloadErrorKind.forbidden =>
        ModelDownloadErrorKind.authentication,
      EngineDownloadErrorKind.notFound => ModelDownloadErrorKind.notFound,
      EngineDownloadErrorKind.rateLimited =>
        ModelDownloadErrorKind.rateLimited,
      EngineDownloadErrorKind.server => ModelDownloadErrorKind.server,
      EngineDownloadErrorKind.network => ModelDownloadErrorKind.network,
      EngineDownloadErrorKind.cancelled => ModelDownloadErrorKind.cancelled,
      EngineDownloadErrorKind.unknown => ModelDownloadErrorKind.unknown,
    };
  }
}
