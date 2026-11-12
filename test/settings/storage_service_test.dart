import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/flutter_edge_ai_engine.dart';
import 'package:si_buddy/features/settings/data/storage_service.dart';

void main() {
  late Directory docs;
  late Directory temp;
  late StorageService service;

  setUp(() async {
    docs = await Directory.systemTemp.createTemp('si_buddy_docs');
    temp = await Directory.systemTemp.createTemp('si_buddy_temp');
    service = StorageService(documentsDirectory: docs, tempDirectory: temp);
  });

  tearDown(() async {
    if (await docs.exists()) await docs.delete(recursive: true);
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('measures model, cache and database from real files', () async {
    final modelDir = Directory('${docs.path}/${FlutterEdgeAiEngine.modelId}');
    await modelDir.create(recursive: true);
    await File(
      '${modelDir.path}/model.litertlm',
    ).writeAsBytes(List.filled(500, 0));
    await File('${temp.path}/scratch.bin').writeAsBytes(List.filled(100, 0));
    await File(
      '${docs.path}/si_buddy.sqlite',
    ).writeAsBytes(List.filled(200, 0));

    expect(await service.modelSizeBytes(), 500);
    expect(await service.cacheSizeBytes(), 100);
    expect(await service.databaseSizeBytes(), 200);

    final freed = await service.clearCache();
    expect(freed, 100);
    expect(await service.cacheSizeBytes(), 0);
    // The model and the database are untouched by a cache clear.
    expect(await service.modelSizeBytes(), 500);
    expect(await service.databaseSizeBytes(), 200);
  });

  test('reads 0 for the model and database when they do not exist', () async {
    expect(await service.modelSizeBytes(), 0);
    expect(await service.cacheSizeBytes(), 0);
    expect(await service.databaseSizeBytes(), 0);
    expect(await service.clearCache(), 0);
  });

  test('measures a flat model file when there is no model folder', () async {
    await File(
      '${docs.path}/${FlutterEdgeAiEngine.modelFileName}',
    ).writeAsBytes(List.filled(42, 0));
    expect(await service.modelSizeBytes(), 42);
  });
}
