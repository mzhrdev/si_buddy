import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/study_models.dart';
import 'notification_service.dart';

/// The real [NotificationService] over flutter_local_notifications
/// (Phase 5). Scheduling is deliberately inexact
/// ([AndroidScheduleMode.inexactAllowWhileIdle]): reminders do not
/// need to-the-minute exactness, and inexact scheduling needs no
/// exact-alarm permission. The POST_NOTIFICATIONS permission the
/// plugin declares in its own manifest is requested at runtime on
/// Android 13+ before any reminder is enabled.
///
/// This class is never constructed in tests — they override the
/// provider with a fake. On the host VM the plugin's platform
/// channel does not exist, so no test touches this class.
class FlutterLocalNotificationsService implements NotificationService {
  FlutterLocalNotificationsService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _dailyChannel = AndroidNotificationDetails(
    'si-buddy-daily',
    'Study reminders',
    channelDescription: 'Daily study goal reminder',
    importance: Importance.defaultImportance,
  );

  static const _revisionChannel = AndroidNotificationDetails(
    'si-buddy-revision',
    'Revision reminders',
    channelDescription: 'Reminders for scheduled revisions',
    importance: Importance.defaultImportance,
  );

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    try {
      // flutter_timezone 5.x returns a TimezoneInfo object; the IANA
      // identifier is what the timezone package needs.
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // The timezone package falls back to its local (UTC-based)
      // location; scheduling still works, only the offset may be
      // off until the device reports a known zone.
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> areNotificationsEnabled() async {
    final enabled = await _android?.areNotificationsEnabled();
    return enabled ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    final granted = await _android?.requestNotificationsPermission();
    return granted ?? false;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int timeMinutes,
    required int dailyGoalMinutes,
  }) async {
    await _ensureInitialized();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeMinutes ~/ 60,
      timeMinutes % 60,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      dailyReminderNotificationId,
      'Time to study',
      'Your daily goal is $dailyGoalMinutes minutes. A little every day adds up.',
      scheduled,
      const NotificationDetails(android: _dailyChannel),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(dailyReminderNotificationId);
  }

  @override
  Future<void> scheduleRevisionReminder({
    required RevisionRecord revision,
    required String deckTitle,
  }) async {
    await _ensureInitialized();
    final scheduled = tz.TZDateTime.from(revision.scheduledAt, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;
    final note = revision.note?.trim();
    await _plugin.zonedSchedule(
      revisionNotificationId(revision.id),
      'Time to revise',
      note == null || note.isEmpty ? deckTitle : '$deckTitle — $note',
      scheduled,
      const NotificationDetails(android: _revisionChannel),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelRevisionReminder(int revisionId) async {
    await _plugin.cancel(revisionNotificationId(revisionId));
  }

  @override
  Future<void> cancelAllRevisionReminders() async {
    final pending = await pendingNotificationIds();
    for (final id in pending) {
      if (isRevisionNotificationId(id)) {
        await _plugin.cancel(id);
      }
    }
  }

  @override
  Future<Set<int>> pendingNotificationIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((request) => request.id).toSet();
  }
}
