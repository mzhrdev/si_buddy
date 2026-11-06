import '../domain/study_models.dart';

/// Notification ids: 1 is the daily study reminder; revision
/// reminders are 100000 + revision id, so the two kinds never
/// collide and a revision's notification can be found from its id.
const dailyReminderNotificationId = 1;

/// The notification id for one revision's reminder.
int revisionNotificationId(int revisionId) => 100000 + revisionId;

/// True when [notificationId] belongs to a revision reminder.
bool isRevisionNotificationId(int notificationId) => notificationId >= 100000;

/// The reminder system's seam (Phase 5): scheduling and cancelling
/// the daily study reminder and the per-revision reminders, and the
/// Android notification permission. The real implementation over
/// flutter_local_notifications lives in
/// `flutter_local_notifications_service.dart`; tests override this
/// provider with a fake. Nothing here touches a platform channel.
abstract class NotificationService {
  /// Prepares the plugin (timezone data + local timezone). Safe to
  /// call more than once; scheduling also initializes lazily.
  Future<void> initialize();

  /// Whether notifications are currently allowed for the app
  /// (Android 13+ permission state).
  Future<bool> areNotificationsEnabled();

  /// Asks Android for the notification permission (Android 13+).
  /// Returns true when the user granted it.
  Future<bool> requestPermission();

  /// Schedules the daily study reminder at [timeMinutes] (minutes
  /// after midnight, local time), repeating every day. Replaces any
  /// previously scheduled daily reminder.
  Future<void> scheduleDailyReminder({
    required int timeMinutes,
    required int dailyGoalMinutes,
  });

  /// Cancels the daily study reminder, if one is scheduled.
  Future<void> cancelDailyReminder();

  /// Schedules the reminder for one revision at its own scheduled
  /// time. A no-op when that time is already past.
  Future<void> scheduleRevisionReminder({
    required RevisionRecord revision,
    required String deckTitle,
  });

  /// Cancels one revision's reminder, if one is scheduled.
  Future<void> cancelRevisionReminder(int revisionId);

  /// Cancels every revision reminder, leaving the daily reminder
  /// alone.
  Future<void> cancelAllRevisionReminders();

  /// The ids of the notifications currently scheduled (used by the
  /// sync pass to find stale revision reminders).
  Future<Set<int>> pendingNotificationIds();
}
