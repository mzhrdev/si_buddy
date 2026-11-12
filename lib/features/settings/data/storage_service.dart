import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../ai_generation/data/flutter_edge_ai_engine.dart';

/// Real storage figures for the Storage screen, measured from the
/// device's own directories — nothing here is estimated.
///
/// - The model is the flutter_edge_ai install: the plugin stores it
///   under the app documents directory in a folder named after the
///   model id (with a flat-file layout as a fallback).
/// - Temporary cache is everything under the platform temp
///   directory (staged cloud picks, extraction scratch files).
/// - The local database is the drift file `si_buddy.sqlite` in the
///   app documents directory.
///
/// Directory overrides exist only so tests can point the service at
/// throwaway folders instead of the real app directories.
class StorageService {
  StorageService({this.tempDirectory, this.documentsDirectory});

  final Directory? tempDirectory;
  final Directory? documentsDirectory;

  Future<Directory> _tempDir() async =>
      tempDirectory ?? await getTemporaryDirectory();

  Future<Directory> _documentsDir() async =>
      documentsDirectory ?? await getApplicationDocumentsDirectory();

  /// The installed model's bytes on disk, or 0 when it is not
  /// installed (or the plugin's layout differs from the one this
  /// method knows). Never throws: a measurement failure reads as 0.
  Future<int> modelSizeBytes() async {
    try {
      final docs = await _documentsDir();
      final modelDir = Directory('${docs.path}/${FlutterEdgeAiEngine.modelId}');
      if (await modelDir.exists()) {
        return await _directorySize(modelDir);
      }
      final flatFile = File(
        '${docs.path}/${FlutterEdgeAiEngine.modelFileName}',
      );
      if (await flatFile.exists()) {
        return await flatFile.length();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Temporary cache bytes (the whole temp directory, recursively).
  /// Never throws: a measurement failure reads as 0.
  Future<int> cacheSizeBytes() async {
    try {
      return await _directorySize(await _tempDir());
    } catch (_) {
      return 0;
    }
  }

  /// Deletes everything under the temp directory and returns the
  /// bytes freed. The temp directory itself is kept. A file that
  /// cannot be deleted is skipped, never fatal.
  Future<int> clearCache() async {
    final dir = await _tempDir();
    var freed = 0;
    if (!await dir.exists()) return 0;
    await for (final entity in dir.list()) {
      try {
        freed += await _entitySize(entity);
        await entity.delete(recursive: true);
      } catch (_) {
        // A file in use by an ongoing import stays put; the rest
        // is still cleared.
      }
    }
    return freed;
  }

  /// The drift database file's bytes, or 0 when it does not exist
  /// yet. Never throws.
  Future<int> databaseSizeBytes() async {
    try {
      final docs = await _documentsDir();
      final file = File('${docs.path}/si_buddy.sqlite');
      if (!await file.exists()) return 0;
      return await file.length();
    } catch (_) {
      return 0;
    }
  }

  /// Bytes under [dir], recursively. Missing directories read as 0;
  /// unreadable entries are skipped.
  Future<int> _directorySize(Directory dir) async {
    var total = 0;
    if (!await dir.exists()) return 0;
    await for (final entity in dir.list(recursive: true)) {
      total += await _entitySize(entity);
    }
    return total;
  }

  Future<int> _entitySize(FileSystemEntity entity) async {
    try {
      if (entity is File) return await entity.length();
    } catch (_) {
      // Vanished or unreadable mid-scan: contributes nothing.
    }
    return 0;
  }
}
