import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:si_buddy/app/app.dart';
import 'package:si_buddy/app/router.dart';

/// The shell's back-button contract (see AppShell):
/// at a tab root, system back first returns to the Home tab;
/// on the Home tab it exits the app. A pushed page still pops
/// normally. Uses bounded pumps, never pumpAndSettle: Home watches
/// drift streams that never settle.
void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// The Android system back button (not the in-app arrow):
  /// dispatches a pop route through the framework, which is what
  /// the shell's PopScope intercepts.
  Future<bool> systemBack(WidgetTester tester) =>
      tester.binding.handlePopRoute();

  testWidgets('back from a tab root goes Home first', (tester) async {
    appRouter.go(AppRoutes.splash);
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await settle(tester);

    appRouter.go(AppRoutes.settings);
    await settle(tester);
    expect(appRouter.state.matchedLocation, AppRoutes.settings);

    await systemBack(tester);
    await settle(tester);
    expect(
      appRouter.state.matchedLocation,
      AppRoutes.home,
      reason: 'back from the Settings tab root should land on Home',
    );
  });

  testWidgets('back on Home asks the system to exit', (tester) async {
    final popCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        popCalls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    appRouter.go(AppRoutes.splash);
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await settle(tester);

    appRouter.go(AppRoutes.home);
    await settle(tester);
    expect(appRouter.state.matchedLocation, AppRoutes.home);

    await systemBack(tester);
    await settle(tester);
    expect(
      popCalls.any((c) => c.method == 'SystemNavigator.pop'),
      isTrue,
      reason: 'back on the Home tab root should exit the app',
    );
  });

  testWidgets('back from a pushed page still pops it', (tester) async {
    appRouter.go(AppRoutes.splash);
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await settle(tester);

    appRouter.go(AppRoutes.home);
    await settle(tester);
    appRouter.push(AppRoutes.aiService);
    await settle(tester);
    expect(appRouter.state.matchedLocation, AppRoutes.aiService);

    await systemBack(tester);
    await settle(tester);
    expect(
      appRouter.state.matchedLocation,
      AppRoutes.home,
      reason: 'back from a pushed page should pop back to Home',
    );
  });
}
