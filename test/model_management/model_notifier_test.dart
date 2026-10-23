import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/edge_ai_engine.dart';
import 'package:si_buddy/features/ai_generation/presentation/providers/generation_providers.dart';
import 'package:si_buddy/features/model_management/domain/model_failures.dart';
import 'package:si_buddy/features/model_management/domain/model_state.dart';
import 'package:si_buddy/features/model_management/presentation/providers/model_providers.dart';

/// A scripted [EdgeAiEngine] for the model state machine: tests set
/// the probe answers and either the download's progress script or
/// the error it fails with.
class FakeEdgeAiEngine implements EdgeAiEngine {
  bool ready = false;
  bool installed = false;
  List<double> downloadScript = const [0.25, 0.5, 1.0];
  EngineDownloadException? downloadError;
  bool deleted = false;

  @override
  Future<bool> isModelReady() async => ready;

  @override
  Future<bool> isModelInstalled() async => installed;

  @override
  Stream<double> downloadModel() async* {
    final error = downloadError;
    if (error != null) {
      // Some progress, then the failure — like a real download.
      yield 0.25;
      throw error;
    }
    for (final progress in downloadScript) {
      await Future<void>.delayed(const Duration(milliseconds: 15));
      yield progress;
    }
    installed = true;
    ready = true;
  }

  @override
  Future<void> deleteModel() async {
    deleted = true;
    installed = false;
    ready = false;
  }

  @override
  Stream<String> generateText(String prompt, {int maxOutputTokens = 1024}) {
    return const Stream.empty();
  }
}

/// Lets pending microtasks and timed stream events settle.
Future<void> settle() async {
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late FakeEdgeAiEngine engine;
  late ProviderContainer container;

  setUp(() {
    engine = FakeEdgeAiEngine();
    container = ProviderContainer(
      overrides: [edgeAiEngineProvider.overrideWithValue(engine)],
    );
    addTearDown(container.dispose);
  });

  ModelState state() => container.read(modelProvider);
  ModelNotifier notifier() => container.read(modelProvider.notifier);

  test('starts unknown and probes nothing until refreshed', () async {
    expect(state().status, ModelStatus.unknown);
    await settle();
    expect(state().status, ModelStatus.unknown);
  });

  test('refresh reports not installed when no model is present', () async {
    await notifier().refresh();
    expect(state().status, ModelStatus.notInstalled);
  });

  test('refresh reports ready when a model is active', () async {
    engine.ready = true;
    engine.installed = true;
    await notifier().refresh();
    expect(state().status, ModelStatus.ready);
  });

  test('download streams progress and lands ready', () async {
    notifier().startDownload();
    expect(state().status, ModelStatus.downloading);
    await settle();
    expect(state().status, ModelStatus.ready);
    expect(state().downloadProgress, 1.0);
    expect(engine.installed, isTrue);
  });

  test('an auth failure lands failed with the authentication kind', () async {
    engine.downloadError = const EngineDownloadException(
      EngineDownloadErrorKind.unauthorized,
      '401 from Hugging Face',
    );
    notifier().startDownload();
    await settle();
    expect(state().status, ModelStatus.failed);
    final failure = state().failure;
    expect(failure, isA<ModelDownloadFailure>());
    expect(
      (failure! as ModelDownloadFailure).kind,
      ModelDownloadErrorKind.authentication,
    );
    // The message explains the license gate a user must satisfy.
    expect(failure.message, contains('Gemma license'));
  });

  test('a network failure lands failed with the network kind', () async {
    engine.downloadError = const EngineDownloadException(
      EngineDownloadErrorKind.network,
      'socket closed',
    );
    notifier().startDownload();
    await settle();
    expect(state().status, ModelStatus.failed);
    expect(
      (state().failure! as ModelDownloadFailure).kind,
      ModelDownloadErrorKind.network,
    );
  });

  test('cancel returns to not installed', () async {
    engine.downloadScript = const [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8];
    notifier().startDownload();
    // A couple of steps in (8 steps x 15ms), still downloading.
    await Future<void>.delayed(const Duration(milliseconds: 35));
    expect(state().status, ModelStatus.downloading);
    notifier().cancelDownload();
    expect(state().status, ModelStatus.notInstalled);
    // And it stays cancelled — no late completion revives it.
    await settle();
    expect(state().status, ModelStatus.notInstalled);
  });

  test('delete removes the model and returns to not installed', () async {
    engine.ready = true;
    engine.installed = true;
    await notifier().refresh();
    expect(state().status, ModelStatus.ready);
    await notifier().deleteModel();
    expect(engine.deleted, isTrue);
    expect(state().status, ModelStatus.notInstalled);
  });
}
