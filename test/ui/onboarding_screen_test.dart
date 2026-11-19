import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  testWidgets('single onboarding screen pages forward and back',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    appRouter.go(AppRoutes.splash);
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();
    // Advance past the splash's 2.5s auto-advance timer.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    // Page 1 of the model.
    expect(find.textContaining('Your notes,'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Forward to page 2.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Less prep.'), findsOneWidget);

    // System back returns to page 1 instead of leaving onboarding.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.textContaining('Your notes,'), findsOneWidget);

    // Forward through pages 2 and 3, then finish.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Big ideas.'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('AI service not configured'), findsOneWidget);
  });
}
