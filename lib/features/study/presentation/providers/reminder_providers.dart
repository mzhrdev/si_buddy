import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/settings_repository.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/flutter_local_notifications_service.dart';
import '../../data/notification_service.dart';
import '../../data/study_repository.dart';
import '../../domain/study_models.dart';
import 'study_providers.dart';

/// The reminder system's orchestration (Phase 5): the notification
/// service, the watched reminder settings, the enable/disable flows
/// (with the Android permission request), and the sync pass that
/// keeps the scheduled notifications equal to the persisted
/// revisions. Screens call the `set…` functions; `main()` calls
/// [initializeReminders] once at startup.

/// The design's default preferred reminder time: 7:00 PM.
const defaultReminderTimeMinutes = 19 * 60;

/// The notification service the reminders run on. Overridden in
/// tests with a fake.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return FlutterLocalNotificationsService();
});

/// Whether revision reminders are enabled (persisted).
final revisionRemindersEnabledProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchBool(SettingsKeys.remindersEnabled)
      .map((value) => value ?? false);
});

/// Whether the daily study reminder is enabled (persisted).
final dailyReminderEnabledProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchBool(SettingsKeys.dailyReminderEnabled)
      .map((value) => value ?? false);
});

/// The preferred reminder time, minutes after midnight (persisted).
/// Defaults to 7:00 PM.
final reminderTimeMinutesProvider = StreamProvider<int>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watchInt(SettingsKeys.reminderTimeMinutes)
      .map((value) => value ?? defaultReminderTimeMinutes);
});

Future<bool> _ensurePermission(NotificationService service) async {
  if (await service.areNotificationsEnabled()) return true;
  return service.requestPermission();
}

/// Enables or disables revision reminders. Enabling asks Android
/// for the notification permission first; when the user denies it,
/// the setting stays off and this returns false so the caller can
/// explain. Disabling cancels every scheduled revision reminder.
Future<bool> setRevisionRemindersEnabled(WidgetRef ref, bool enabled) async {
  final service = ref.read(notificationServiceProvider);
  final settings = ref.read(settingsRepositoryProvider);
  if (enabled && !await _ensurePermission(service)) return false;
  await settings.setBool(SettingsKeys.remindersEnabled, enabled);
  if (enabled) {
    await syncRevisionReminders(ref: ref);
  } else {
    await service.cancelAllRevisionReminders();
  }
  return true;
}

/// Enables or disables the daily study reminder at the preferred
/// time. Same permission flow as the revision reminders.
Future<bool> setDailyReminderEnabled(WidgetRef ref, bool enabled) async {
  final service = ref.read(notificationServiceProvider);
  final settings = ref.read(settingsRepositoryProvider);
  if (enabled && !await _ensurePermission(service)) return false;
  await settings.setBool(SettingsKeys.dailyReminderEnabled, enabled);
  if (enabled) {
    final time =
        await settings.getInt(SettingsKeys.reminderTimeMinutes) ??
        defaultReminderTimeMinutes;
    final goal = await settings.getInt(SettingsKeys.dailyGoalMinutes) ?? 20;
    await service.scheduleDailyReminder(
      timeMinutes: time,
      dailyGoalMinutes: goal,
    );
  } else {
    await service.cancelDailyReminder();
  }
  return true;
}

/// Changes the preferred reminder time. A scheduled daily reminder
/// is rescheduled at the new time; revision reminders fire at their
/// own scheduled time, so they are unaffected.
Future<void> setReminderTimeMinutes(WidgetRef ref, int minutes) async {
  final service = ref.read(notificationServiceProvider);
  final settings = ref.read(settingsRepositoryProvider);
  await settings.setInt(SettingsKeys.reminderTimeMinutes, minutes);
  final dailyEnabled =
      await settings.getBool(SettingsKeys.dailyReminderEnabled) ?? false;
  if (dailyEnabled) {
    final goal = await settings.getInt(SettingsKeys.dailyGoalMinutes) ?? 20;
    await service.scheduleDailyReminder(
      timeMinutes: minutes,
      dailyGoalMinutes: goal,
    );
  }
}

/// Changes the daily study goal in minutes. A scheduled daily
/// reminder is rescheduled so its message names the new goal.
Future<void> setDailyGoalMinutes(WidgetRef ref, int minutes) async {
  final service = ref.read(notificationServiceProvider);
  final settings = ref.read(settingsRepositoryProvider);
  await settings.setInt(SettingsKeys.dailyGoalMinutes, minutes);
  final dailyEnabled =
      await settings.getBool(SettingsKeys.dailyReminderEnabled) ?? false;
  if (dailyEnabled) {
    final time =
        await settings.getInt(SettingsKeys.reminderTimeMinutes) ??
        defaultReminderTimeMinutes;
    await service.scheduleDailyReminder(
      timeMinutes: time,
      dailyGoalMinutes: minutes,
    );
  }
}

/// Schedules the reminder for one revision (called after creating
/// or editing it). A no-op when revision reminders are off or the
/// revision's time is past.
Future<void> scheduleRevisionNotification(
  WidgetRef ref,
  RevisionRecord revision,
) async {
  final service = ref.read(notificationServiceProvider);
  final settings = ref.read(settingsRepositoryProvider);
  final enabled =
      await settings.getBool(SettingsKeys.remindersEnabled) ?? false;
  if (!enabled) return;
  final deck = await ref.read(studyRepositoryProvider).getDeck(revision.deckId);
  await service.scheduleRevisionReminder(
    revision: revision,
    deckTitle: deck?.title ?? 'Study set',
  );
}

/// Cancels one revision's reminder (called after deleting or
/// completing it).
Future<void> cancelRevisionNotification(WidgetRef ref, int revisionId) async {
  await ref
      .read(notificationServiceProvider)
      .cancelRevisionReminder(revisionId);
}

/// The sync pass: the scheduled revision reminders are made to
/// match the persisted upcoming revisions — stale ones (deleted,
/// completed, past, or reminder turned off) are cancelled, missing
/// ones are scheduled. Runs at startup and whenever revision
/// reminders are enabled.
Future<void> syncRevisionReminders({required WidgetRef ref}) async {
  await syncRevisionRemindersFor(
    service: ref.read(notificationServiceProvider),
    studyRepository: ref.read(studyRepositoryProvider),
    remindersEnabled:
        await ref
            .read(settingsRepositoryProvider)
            .getBool(SettingsKeys.remindersEnabled) ??
        false,
  );
}

/// The ref-free core of [syncRevisionReminders], so `main()` and
/// tests can run it without a widget tree.
Future<void> syncRevisionRemindersFor({
  required NotificationService service,
  required StudyRepository studyRepository,
  required bool remindersEnabled,
}) async {
  final revisions = await studyRepository.watchUpcomingRevisions().first;
  final pending = await service.pendingNotificationIds();
  final wanted = <int, RevisionRecord>{};
  for (final revision in revisions) {
    if (!revision.reminderEnabled) continue;
    if (revision.scheduledAt.isBefore(DateTime.now())) continue;
    wanted[revisionNotificationId(revision.id)] = revision;
  }
  if (!remindersEnabled) {
    // Reminders off: cancel every scheduled revision reminder.
    await service.cancelAllRevisionReminders();
    return;
  }
  for (final id in pending) {
    // A pending revision notification with no matching upcoming
    // revision is stale (deleted, completed, past, or switched
    // off): cancel it. The service takes a revision id, so the
    // notification id is converted back first.
    if (isRevisionNotificationId(id) && !wanted.containsKey(id)) {
      await service.cancelRevisionReminder(id - 100000);
    }
  }
  for (final entry in wanted.entries) {
    if (pending.contains(entry.key)) continue;
    final deck = await studyRepository.getDeck(entry.value.deckId);
    await service.scheduleRevisionReminder(
      revision: entry.value,
      deckTitle: deck?.title ?? 'Study set',
    );
  }
}

/// Startup hook, called from `main()` after the database opens:
/// initializes the plugin and restores the reminders that should
/// be scheduled (revisions + daily). Never throws — reminders must
/// never break startup.
Future<void> initializeReminders({
  required SettingsRepository settings,
  required StudyRepository studyRepository,
  required NotificationService service,
}) async {
  try {
    await service.initialize();
    final revisionEnabled =
        await settings.getBool(SettingsKeys.remindersEnabled) ?? false;
    await syncRevisionRemindersFor(
      service: service,
      studyRepository: studyRepository,
      remindersEnabled: revisionEnabled,
    );
    final dailyEnabled =
        await settings.getBool(SettingsKeys.dailyReminderEnabled) ?? false;
    if (dailyEnabled) {
      final time =
          await settings.getInt(SettingsKeys.reminderTimeMinutes) ??
          defaultReminderTimeMinutes;
      final goal = await settings.getInt(SettingsKeys.dailyGoalMinutes) ?? 20;
      await service.scheduleDailyReminder(
        timeMinutes: time,
        dailyGoalMinutes: goal,
      );
    }
  } catch (_) {
    // Reminders are best-effort at startup; the app works without
    // them and the next enable/sync restores them.
  }
}
