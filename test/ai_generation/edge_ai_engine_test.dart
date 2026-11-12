import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/ai_generation/data/edge_ai_engine.dart';
import 'package:si_buddy/features/ai_generation/data/flutter_edge_ai_engine.dart';

/// The real engine's download is single-flight: while one install
/// runs, a second caller gets the same stream instead of starting a
/// second native install of the same file. The host has no platform
/// plugin, so listening fails the install at once — which is also
/// what proves the slot clears and a later call starts fresh.
void main() {
  test('downloadModel returns the same stream while one runs', () async {
    const engine = FlutterEdgeAiEngine();
    final first = engine.downloadModel();
    expect(engine.downloadModel(), same(first));

    await expectLater(first, emitsError(isA<EngineDownloadException>()));

    expect(engine.downloadModel(), isNot(same(first)));
  });
}
