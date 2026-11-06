import 'package:drift/drift.dart';

import 'app_database.dart';

/// Keys for the app-wide settings stored in [DbSettings]. Values are
/// plain strings; typed accessors below do the conversion so callers
/// never parse raw values.
abstract final class SettingsKeys {
  /// Whether the onboarding flow was completed (Skip counts).
  static const onboardingCompleted = 'onboarding_completed';

  /// Appearance: `light`, `dark` or `system`.
  static const themeMode = 'theme_mode';

  /// Daily study goal in minutes.
  static const dailyGoalMinutes = 'daily_goal_minutes';

  /// Whether revision reminders are enabled.
  static const remindersEnabled = 'reminders_enabled';

  /// Revision reminder time, minutes after midnight.
  static const reminderTimeMinutes = 'reminder_time_minutes';
}

/// App-wide key/value settings over [DbSettings]. One row per key;
/// new settings need no migration. This is the only settings store
/// in the app — there is no SharedPreferences usage anywhere.
class SettingsRepository {
  SettingsRepository({required this.db});

  final AppDatabase db;

  Future<String?> getString(String key) async {
    final row = await (db.select(db.dbSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setString(String key, String value) async {
    await db
        .into(db.dbSettings)
        .insert(
          DbSettingsCompanion.insert(key: key, value: value),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> setBool(String key, bool value) async {
    await setString(key, value ? 'true' : 'false');
  }

  Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  /// A setting's value, streamed as it changes.
  Stream<String?> watchString(String key) {
    final query = db.select(db.dbSettings)
      ..where((t) => t.key.equals(key));
    return query.watchSingleOrNull().map((row) => row?.value);
  }

  Future<void> remove(String key) async {
    await (db.delete(db.dbSettings)..where((t) => t.key.equals(key))).go();
  }
}
