import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/database/settings_repository.dart';
import 'features/documents/presentation/providers/documents_providers.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'features/study/data/flutter_local_notifications_service.dart';
import 'features/study/data/study_repository.dart';
import 'features/study/presentation/providers/reminder_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Register the LiteRT-LM engine once, at startup (flutter_edge_ai's
  // documented setup). This only registers the engine — no model is
  // loaded until generation runs. The Hugging Face token is NOT read
  // here: it is passed per download by the model data layer, from the
  // HF_TOKEN dart-define (see ai_generation/data/flutter_edge_ai_engine.dart).
  // The current Qwen model is ungated, so no token is needed.
  await FlutterEdgeAi.initialize(inferenceEngines: const [LiteRtLmEngine()]);
  // Open the database once, here: the splash screen needs the
  // persisted onboarding flag before the first frame, and the
  // provider scope reuses this same instance (a second connection
  // to the same file would trigger drift's multiple-databases
  // warning). A read failure reads as "not completed": onboarding
  // is the safe default, and startup must never stall on it.
  final database = AppDatabase.defaults();
  var onboardingCompleted = false;
  try {
    onboardingCompleted =
        await SettingsRepository(
          db: database,
        ).getBool(SettingsKeys.onboardingCompleted) ??
        false;
  } catch (_) {
    onboardingCompleted = false;
  }
  // Restore the scheduled reminders (revision + daily) from the
  // persisted settings and revisions. Fire-and-forget: reminders
  // must never stall startup, and initializeReminders swallows its
  // own failures.
  unawaited(
    initializeReminders(
      settings: SettingsRepository(db: database),
      studyRepository: StudyRepositoryImpl(db: database),
      service: FlutterLocalNotificationsService(),
    ),
  );
  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        onboardingCompletedProvider.overrideWithValue(onboardingCompleted),
      ],
      child: const MyApp(),
    ),
  );
}
