import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/settings_repository.dart';
import '../../../documents/presentation/providers/documents_providers.dart';

/// The app-wide settings repository (onboarding completion, theme,
/// daily goal, reminders) over the app database. Settings are the
/// only cross-feature state stored here — screens in onboarding,
/// study and settings all read and write through this provider.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(db: ref.watch(appDatabaseProvider));
});

/// Whether onboarding was completed, resolved once at startup in
/// `main()` and provided here so the splash screen can route
/// synchronously. Defaults to false (first launch) when no override
/// is provided — tests pump `MyApp` without `main()`, so they always
/// see onboarding.
final onboardingCompletedProvider = Provider<bool>((ref) => false);

/// The persisted appearance, streamed from [SettingsKeys.themeMode]
/// (`light`, `dark` or `system`; unset reads as System). Screens
/// read it with `.value ?? ThemeMode.system` — the database never
/// answers in widget tests, so a loading spinner would hang them
/// (the Phase 5 lesson).
final themeModeProvider = StreamProvider<ThemeMode>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchString(SettingsKeys.themeMode)
      .map(
        (value) => switch (value) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        },
      );
});

/// Persists the appearance choice. Fire-and-forget from the UI: the
/// stream above re-emits and the app re-themes.
Future<void> setThemeMode(WidgetRef ref, ThemeMode mode) async {
  final value = switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
  await ref
      .read(settingsRepositoryProvider)
      .setString(SettingsKeys.themeMode, value);
}
