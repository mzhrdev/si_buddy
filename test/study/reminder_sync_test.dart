import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/database/app_database.dart';
import 'package:si_buddy/core/database/settings_repository.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_config.dart';
import 'package:si_buddy/features/ai_generation/domain/generation_models.dart';
import 'package:si_buddy/features/study/data/notification_service.dart';
import 'package:si_buddy/features/study/data/study_repository.dart';
import 'package:si_buddy/features/study/domain/study_models.dart';
import 'package:si_buddy/features/study/presentation/providers/reminder_providers.dart';

/// An in-memory [NotificationService]: records what was scheduled
/// and cancelled instead of touching a platform channel.
class FakeNotificationService implements NotificationService {
  final scheduled = <int>{};
  final cancelled = <int>[];
  int? dailyTimeMinutes;
  int? dailyGoalMinutes;
  bool permissionGranted = true;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> areNotificationsEnabled() async => permissionGranted;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> scheduleDailyReminder({
    required int timeMinutes,
    required int dailyGoalMinutes,
  }) async {
    dailyTimeMinutes = timeMinutes;
    // `this.` is required here: the parameter shadows the field.
    this.dailyGoalMinutes = dailyGoalMinutes;
    scheduled.add(dailyReminderNotificationId);
  }

  @override
  Future<void> cancelDailyReminder() async {
    scheduled.remove(dailyReminderNotificationId);
  }

  @override
  Future<void> scheduleRevisionReminder({
    required RevisionRecord revision,
    required String deckTitle,
  }) async {
    scheduled.add(revisionNotificationId(revision.id));
  }

  @override
  Future<void> cancelRevisionReminder(int revisionId) async {
    final id = revisionNotificationId(revisionId);
    scheduled.remove(id);
    cancelled.add(id);
  }

  @override
  Future<void> cancelAllRevisionReminders() async {
    for (final id in scheduled.toList()) {
      if (isRevisionNotificationId(id)) {
        scheduled.remove(id);
        cancelled.add(id);
      }
    }
  }

  @override
  Future<Set<int>> pendingNotificationIds() async => Set.of(scheduled);
}

void main() {
  late AppDatabase db;
  late StudyRepositoryImpl repository;
  late SettingsRepository settings;
  late FakeNotificationService service;
  late int deckId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = StudyRepositoryImpl(db: db);
    settings = SettingsRepository(db: db);
    service = FakeNotificationService();
    final documentId = await db
        .into(db.dbDocuments)
        .insert(
          DbDocumentsCompanion.insert(
            title: 'Cells',
            originalFileName: 'cells.pdf',
            format: 'pdf',
            sizeBytes: 1024,
            pageCount: 3,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            storedPath: '/tmp/cells.pdf',
          ),
        );
    deckId = await repository.saveDeck(
      documentId: documentId,
      title: 'Cells',
      materialType: GenerationMaterialType.flashcards,
      flashcards: const [
        GeneratedFlashcard(front: 'What is a cell?', back: 'Basic unit.'),
      ],
      questions: const [],
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> sync({required bool remindersEnabled}) =>
      syncRevisionRemindersFor(
        service: service,
        studyRepository: repository,
        remindersEnabled: remindersEnabled,
      );

  group('syncRevisionRemindersFor', () {
    test(
      'schedules future revisions with reminders on, nothing else',
      () async {
        final futureId = await repository.scheduleRevision(
          deckId: deckId,
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
          note: 'Review the hard cards',
        );
        await repository.scheduleRevision(
          deckId: deckId,
          scheduledAt: DateTime.now().add(const Duration(hours: 3)),
          reminderEnabled: false,
        );
        await repository.scheduleRevision(
          deckId: deckId,
          scheduledAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        await sync(remindersEnabled: true);

        expect(service.scheduled, {revisionNotificationId(futureId)});
      },
    );

    test('cancels stale pending reminders', () async {
      // A notification for a revision that no longer exists.
      service.scheduled.add(revisionNotificationId(999));
      final futureId = await repository.scheduleRevision(
        deckId: deckId,
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      );

      await sync(remindersEnabled: true);

      expect(service.scheduled, {revisionNotificationId(futureId)});
      expect(service.cancelled, [revisionNotificationId(999)]);
    });

    test('cancels completed revisions’ reminders', () async {
      final revisionId = await repository.scheduleRevision(
        deckId: deckId,
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      );
      service.scheduled.add(revisionNotificationId(revisionId));
      await repository.completeRevision(revisionId);

      await sync(remindersEnabled: true);

      expect(service.scheduled, isEmpty);
      expect(service.cancelled, [revisionNotificationId(revisionId)]);
    });

    test('reminders off cancels every revision reminder', () async {
      final revisionId = await repository.scheduleRevision(
        deckId: deckId,
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      );
      service.scheduled.add(revisionNotificationId(revisionId));

      await sync(remindersEnabled: false);

      expect(service.scheduled, isEmpty);
      expect(service.cancelled, [revisionNotificationId(revisionId)]);
    });
  });

  group('initializeReminders', () {
    test('restores the daily reminder from the persisted settings', () async {
      await settings.setBool(SettingsKeys.dailyReminderEnabled, true);
      await settings.setInt(SettingsKeys.reminderTimeMinutes, 8 * 60);
      await settings.setInt(SettingsKeys.dailyGoalMinutes, 30);

      await initializeReminders(
        settings: settings,
        studyRepository: repository,
        service: service,
      );

      expect(service.dailyTimeMinutes, 8 * 60);
      expect(service.dailyGoalMinutes, 30);
      expect(service.scheduled, contains(dailyReminderNotificationId));
    });

    test('schedules nothing when everything is off', () async {
      await initializeReminders(
        settings: settings,
        studyRepository: repository,
        service: service,
      );
      expect(service.scheduled, isEmpty);
    });
  });
}
