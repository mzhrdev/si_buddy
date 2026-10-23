import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:si_buddy/app/app.dart';
import 'package:si_buddy/app/router.dart';

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

      // The app router is a top-level singleton: reset it to the splash
      // route so each size run starts from a cold launch.
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
      expect(find.text('Import Notes'), findsWidgets);

      await tester.tap(find.text('Import Notes'));
      await tester.pumpAndSettle();
      check('home Import Notes');
      await back('back from import files');

      await tester.tap(find.text('Generate Flashcards'));
      await tester.pumpAndSettle();
      check('home Generate Flashcards');
      await back('back from generation setup');

      await tester.tap(find.text('Create Quiz'));
      await tester.pumpAndSettle();
      check('home Create Quiz');
      await back('back from quiz setup');

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
