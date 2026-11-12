import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/edge_ai_engine.dart';
import 'package:si_buddy/features/ai_generation/data/flutter_edge_ai_engine.dart';

/// The real engine's download is single-flight: while one install
/// runs, a second caller gets the same stream instead of starting a
/// second native install of the same file. The host has no platform
/// plugin, so listening fails the install at once — which is also
/// what proves the slot clears and a later call starts fresh.
void main() {
  test('model identity points at Qwen3 0.6B, not the legacy Gemma model',
      () {
    // The switch (2026-11-12): Qwen3 0.6B, dynamic INT4, 343 MB,
    // from the ungated litert-community repo. The file is the pinned
    // e6bb3e4a revision's gpu_composites build — the current main
    // file's external weights need LiteRT-LM 0.19.0+, while the
    // pinned litertlm 1.17.0 bundles 0.18.0 (whose GPU engine
    // SIGSEGVs on it). The id is the file name without extension,
    // which is also how the plugin names the active model spec.
    expect(
      FlutterEdgeAiEngine.modelFileName,
      'Qwen3-0.6B_dynamic_wi4b32_afp32_gpu_composites.litertlm',
    );
    expect(
      FlutterEdgeAiEngine.modelId,
      'Qwen3-0.6B_dynamic_wi4b32_afp32_gpu_composites',
    );
    expect(
      FlutterEdgeAiEngine.modelUrl,
      'https://huggingface.co/litert-community/Qwen3-0.6B/resolve/'
      'e6bb3e4a1eb3f663153f0c1c12b735d64be657a7/'
      'Qwen3-0.6B_dynamic_wi4b32_afp32_gpu_composites.litertlm',
    );
    expect(FlutterEdgeAiEngine.contextTokens, 4096);
    expect(
      FlutterEdgeAiEngine.legacyModelId,
      'Gemma3-1B-IT_multi-prefill-seq_q4_ekv4096',
    );
    expect(FlutterEdgeAiEngine.modelId, isNot(FlutterEdgeAiEngine.legacyModelId));
  });

  test('isModelReady and isModelInstalled read false with no plugin',
      () async {
    const engine = FlutterEdgeAiEngine();
    // Host: no platform plugin, so the probes catch and read as
    // "no model" — the honest routing signal for the missing-model
    // state. (On device, readiness now also requires the ACTIVE
    // model to be Qwen, so a still-active legacy Gemma reads false.)
    expect(await engine.isModelReady(), isFalse);
    expect(await engine.isModelInstalled(), isFalse);
  });

  test('downloadModel returns the same stream while one runs', () async {
    const engine = FlutterEdgeAiEngine();
    final first = engine.downloadModel();
    expect(engine.downloadModel(), same(first));

    await expectLater(first, emitsError(isA<EngineDownloadException>()));

    expect(engine.downloadModel(), isNot(same(first)));
  });
}
