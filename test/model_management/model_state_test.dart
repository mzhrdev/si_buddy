import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/model_management/domain/model_state.dart';

/// The model screens' labels follow the current model (Qwen3 0.6B
/// since the 2026-11-12 switch); they must not still name Gemma.
void main() {
  test('AiModelInfo labels the Qwen3 0.6B model', () {
    const info = AiModelInfo.current;
    expect(info.displayName, 'Qwen3 0.6B');
    expect(info.versionLabel, 'Qwen3 0.6B · q4 (.litertlm)');
    expect(info.downloadSizeLabel, '343 MB');
  });
}
