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
