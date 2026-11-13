import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/edge_ai_engine.dart';
import 'package:si_buddy/features/ai_generation/presentation/providers/generation_providers.dart';
import 'package:si_buddy/features/model_management/domain/model_failures.dart';
import 'package:si_buddy/features/model_management/domain/model_state.dart';
import 'package:si_buddy/features/model_management/presentation/providers/model_providers.dart';

/// A scripted [EdgeAiEngine] for the AI service state machine:
/// tests set the probe answers and whether the legacy delete runs.
class FakeEdgeAiEngine implements EdgeAiEngine {
  bool ready = false;
  bool installed = false;
  bool deleted = false;

  @override
  Future<bool> isModelReady() async => ready;

  @override
  Future<bool> isModelInstalled() async => installed;

  @override
  Stream<double> downloadModel() => Stream.value(1.0);

  @override
  Future<void> deleteModel() async {
    deleted = true;
    // Only the legacy file goes: the service itself stays
    // configured, so readiness is untouched (unlike the retired
    // on-device engine, where deleting the model meant not-ready).
    installed = false;
  }

  @override
  Stream<String> generateText(String prompt, {int maxOutputTokens = 1024}) {
    return const Stream.empty();
  }
}

/// Lets pending microtasks settle.
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

  test('refresh reports not installed when the service is not '
      'configured', () async {
    await notifier().refresh();
    expect(state().status, ModelStatus.notInstalled);
  });

  test('refresh reports ready when the service answers', () async {
    engine.ready = true;
    engine.installed = true;
    await notifier().refresh();
    expect(state().status, ModelStatus.ready);
  });

  test('delete removes the legacy file and the service stays ready', () async {
    engine.ready = true;
    engine.installed = true;
    await notifier().refresh();
    expect(state().status, ModelStatus.ready);
    await notifier().deleteModel();
    expect(engine.deleted, isTrue);
    // Deleting the legacy file does not unconfigure the service.
    expect(state().status, ModelStatus.ready);
  });

  test('delete failure lands failed', () async {
    // A delete that throws surfaces as a failed state.
    container = ProviderContainer(
      overrides: [
        edgeAiEngineProvider.overrideWithValue(_ThrowingDeleteEngine()),
      ],
    );
    addTearDown(container.dispose);
    await notifier().deleteModel();
    expect(state().status, ModelStatus.failed);
    expect(state().failure, isA<ModelOperationFailure>());
  });
}

/// An engine whose delete always fails, for the delete-failure test.
class _ThrowingDeleteEngine implements EdgeAiEngine {
  @override
  Future<bool> isModelReady() async => true;

  @override
  Future<bool> isModelInstalled() async => true;

  @override
  Stream<double> downloadModel() => Stream.value(1.0);

  @override
  Future<void> deleteModel() async {
    throw const EngineGenerationException('uninstall failed');
  }

  @override
  Stream<String> generateText(String prompt, {int maxOutputTokens = 1024}) {
    return const Stream.empty();
  }
}
