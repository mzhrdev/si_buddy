import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/core/database/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('clearAll removes every key', () async {
    await settings.setString(SettingsKeys.themeMode, 'dark');
    await settings.setBool(SettingsKeys.onboardingCompleted, true);
    await settings.setInt(SettingsKeys.dailyGoalMinutes, 30);
    await settings.setBool(SettingsKeys.remindersEnabled, true);

    await settings.clearAll();

    expect(await settings.getString(SettingsKeys.themeMode), isNull);
    expect(await settings.getBool(SettingsKeys.onboardingCompleted), isNull);
    expect(await settings.getInt(SettingsKeys.dailyGoalMinutes), isNull);
    expect(await settings.getBool(SettingsKeys.remindersEnabled), isNull);
  });
}
