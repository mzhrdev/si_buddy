import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:si_buddy/app/app.dart';
import 'package:si_buddy/app/router.dart';
import 'package:si_buddy/features/model_management/domain/model_state.dart';
import 'package:si_buddy/features/model_management/presentation/providers/model_providers.dart';

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

/// A model that reports ready and never re-probes, so the
/// model-installed Home states can be exercised without a real
/// model file.
class _ReadyModelNotifier extends ModelNotifier {
  @override
  ModelState build() => const ModelState(status: ModelStatus.ready);

  @override
  Future<void> refresh() async {}
}

void main() {
  setUpAll(_loadInter);

  for (final size in [const Size(393, 852), const Size(360, 800)]) {
    testWidgets('tap-through flow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final problems = <String>[];
      void check(String step) {
        final e = tester.takeException();
        if (e != null) problems.add('$step -> $e');
      }

      Future<void> back(String step) async {
        final b = find.byIcon(Icons.arrow_back);
        if (b.evaluate().isNotEmpty) {
          await tester.tap(b.first);
          await tester.pumpAndSettle();
        } else {
          problems.add('$step -> no back button found');
        }
        check(step);
      }

      Future<void> advancePastSplashAndOnboarding() async {
        // The app router is a top-level singleton: reset it to the
        // splash route so each size run starts from a cold launch.
        appRouter.go(AppRoutes.splash);
        await tester.pumpWidget(const ProviderScope(child: MyApp()));
        await tester.pumpAndSettle();
        check('initial pump (splash)');

        final mark = find.byType(SvgPicture);
        if (mark.evaluate().isNotEmpty) {
          final c = tester.getCenter(mark.first);
          // ignore: avoid_print
          print(
            'SPLASH @$size mark center: dx=${c.dx} dy=${c.dy} '
            '(screen center ${size.width / 2}, ${size.height / 2})',
          );
        }

        // Advance fake time past the splash's 2.5s auto-advance timer.
        await tester.pump(const Duration(milliseconds: 2600));
        await tester.pumpAndSettle();

        // No tap: the splash must auto-advance to onboarding.
        expect(
          find.text('Next'),
          findsWidgets,
          reason: 'splash should auto-advance to onboarding',
        );
        check('auto-advance');

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        check('onboarding Next #1');

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        check('onboarding Next #2');

        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
        check('onboarding Get Started');
      }

      // State A: no model installed, so Home shows only the
      // download-model message — no Import Notes, no quick actions.
      await advancePastSplashAndOnboarding();
      expect(find.text('AI model not downloaded'), findsOneWidget);
      expect(find.text('Download AI Model'), findsOneWidget);
      expect(find.text('Import Notes'), findsNothing);

      await tester.tap(find.text('Download AI Model'));
      await tester.pumpAndSettle();
      check('home Download AI Model');
      expect(find.text('Download once. Generate offline.'), findsOneWidget);
      await back('back from model not-installed');

      expect(problems, isEmpty, reason: problems.join('\n\n'));
    });

    testWidgets('model-installed flow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final problems = <String>[];
      void check(String step) {
        final e = tester.takeException();
        if (e != null) problems.add('$step -> $e');
      }

      Future<void> back(String step) async {
        final b = find.byIcon(Icons.arrow_back);
        if (b.evaluate().isNotEmpty) {
          await tester.tap(b.first);
          await tester.pumpAndSettle();
        } else {
          problems.add('$step -> no back button found');
        }
        check(step);
      }

      // State B: a model is installed and nothing is imported, so
      // Home shows Import Notes (and no quick-action cards — the
      // document is the generation entry point).
      appRouter.go(AppRoutes.splash);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [modelProvider.overrideWith(_ReadyModelNotifier.new)],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      check('onboarding Get Started');
      expect(find.text('Import Notes'), findsWidgets);
      expect(find.text('Generate Flashcards'), findsNothing);
      expect(find.text('Create Quiz'), findsNothing);

      await tester.tap(find.text('Import Notes'));
      await tester.pumpAndSettle();
      check('home Import Notes');
      await back('back from import files');

      for (final tab in ['Library', 'Study', 'Settings']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
        check('tab $tab');
      }

      await tester.tap(find.text('Appearance').first);
      await tester.pumpAndSettle();
      check('settings -> Preferences');
      await back('back from Preferences');

      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();
      check('tab Home');

      expect(problems, isEmpty, reason: problems.join('\n\n'));
    });
  }
}
