import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/core/database/settings_repository.dart';
import 'package:si_buddy/features/documents/presentation/providers/documents_providers.dart';
import 'package:si_buddy/features/settings/presentation/providers/settings_providers.dart';

void main() {
  group('themeModeProvider', () {
    test('maps the persisted setting, unset reads as System', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final settings = SettingsRepository(db: db);
      // A StreamProvider only runs its stream while something
      // listens: without this subscription the provider stays
      // paused and never emits.
      final subscription = container.listen(themeModeProvider, (_, _) {});
      addTearDown(subscription.close);

      /// Waits (bounded) for the provider's stream to re-emit after
      /// a write — the emission is asynchronous.
      Future<void> waitForMode(ThemeMode mode) async {
        for (var i = 0; i < 100; i++) {
          if (container.read(themeModeProvider).value == mode) return;
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        fail('themeModeProvider did not become $mode');
      }

      // Unset reads as System.
      await waitForMode(ThemeMode.system);

      await settings.setString(SettingsKeys.themeMode, 'dark');
      await waitForMode(ThemeMode.dark);

      await settings.setString(SettingsKeys.themeMode, 'light');
      await waitForMode(ThemeMode.light);

      await settings.setString(SettingsKeys.themeMode, 'system');
      await waitForMode(ThemeMode.system);
    });
  });

  group('setThemeMode', () {
    testWidgets('persists the choice the user taps', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                return Column(
                  children: [
                    TextButton(
                      onPressed: () => setThemeMode(ref, ThemeMode.dark),
                      child: const Text('dark'),
                    ),
                    TextButton(
                      onPressed: () => setThemeMode(ref, ThemeMode.light),
                      child: const Text('light'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      // Bounded pumps only: the provider's drift watch stream keeps
      // pumpAndSettle from ever settling (the Phase 5 lesson).
      await tester.pump();

      await tester.tap(find.text('dark'));
      await tester.pump();
      await tester.pump();
      expect(
        await SettingsRepository(db: db).getString(SettingsKeys.themeMode),
        'dark',
      );

      await tester.tap(find.text('light'));
      await tester.pump();
      await tester.pump();
      expect(
        await SettingsRepository(db: db).getString(SettingsKeys.themeMode),
        'light',
      );
    });
  });
}
