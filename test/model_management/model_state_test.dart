import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/features/model_management/domain/model_state.dart';

/// The AI service screen's labels follow the current service (Groq,
/// via the app's own backend proxy, since the 2026-11-13 migration);
/// they must not still name the retired on-device Qwen model.
void main() {
  test('AiModelInfo labels the Groq AI service', () {
    const info = AiModelInfo.current;
    expect(info.displayName, 'Groq AI Service');
    expect(info.versionLabel, 'gpt-oss-120b · Groq');
  });
}
