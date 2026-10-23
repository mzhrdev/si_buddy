import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:si_buddy/app/app.dart';
import 'package:si_buddy/app/router.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/presentation/providers/generation_providers.dart';
import 'package:si_buddy/features/ai_generation/presentation/screens/generation_setup_screen.dart';

Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final name in [
    'Inter-400',
    'Inter-500',
    'Inter-600',
    'Inter-700',
    'Inter-800',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/$name.ttf'));
  }
  await loader.load();
}

/// Widget-level wiring checks for the generation setup screen: its
/// controls write the shared GenerationConfig, and its Generate
/// action — with no model runtime bound — routes to the
/// missing-model screen instead of pretending to generate.
void main() {
  setUpAll(_loadInter);

  testWidgets('setup controls write the config; Generate routes to '
      'missing model while no runtime is bound', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    appRouter.go(AppRoutes.generationSetup);
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    expect(find.byType(GenerationSetupScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(GenerationSetupScreen)),
    );
    GenerationConfig config() => container.read(generationConfigProvider);

    // Starts at the design defaults.
    expect(config(), equals(const GenerationConfig()));

    // Material-type chip.
    await tester.tap(find.text('MCQs'));
    await tester.pumpAndSettle();
    expect(config().materialType, GenerationMaterialType.mcqs);

    // Difficulty chip.
    await tester.tap(find.text('Hard'));
    await tester.pumpAndSettle();
    expect(config().difficulty, GenerationDifficulty.hard);

    // Count stepper: plus increments the shared config.
    final stepperRow = find
        .ancestor(of: find.text('20'), matching: find.byType(Row))
        .first;
    await tester.tap(
      find.descendant(of: stepperRow, matching: find.byType(InkWell)).last,
    );
    await tester.pumpAndSettle();
    expect(config().count, 21);
    expect(find.text('21'), findsOneWidget);

    // Explanations toggle: tap the 46×28 pill itself (the label text
    // is not part of its tap target).
    final togglePill = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.constraints?.maxWidth == 46 &&
          w.constraints?.maxHeight == 28,
    );
    expect(togglePill, findsOneWidget);
    await tester.tap(togglePill);
    await tester.pumpAndSettle();
    expect(config().includeExplanations, isFalse);

    // Generate: no runtime is bound, so instead of fake progress the
    // app shows the designed missing-model state.
    await tester.tap(find.text('Generate flashcards'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Install an AI model first'), findsOneWidget);
  });
}
