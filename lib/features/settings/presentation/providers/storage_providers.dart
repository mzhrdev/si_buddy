import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../model_management/presentation/providers/model_providers.dart';
import '../../../study/presentation/providers/reminder_providers.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../../data/storage_service.dart';
import 'settings_providers.dart';

/// The storage measurement service (real bytes from the device's
/// own directories).
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Bumped after cache clears and data wipes so the Storage screen
/// re-reads its figures.
class StorageVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final storageVersionProvider = NotifierProvider<StorageVersionNotifier, int>(
  StorageVersionNotifier.new,
);

/// Every Storage-screen figure, measured from real state. Documents
/// from the library's live stream, the legacy model file and cache
/// from the device's directories, study counts from the persisted
/// decks and stats. All sizes are 0 (never estimates) when their
/// source does not exist.
class StorageFigures {
  const StorageFigures({
    required this.documentsBytes,
    required this.fileCount,
    required this.modelBytes,
    required this.modelInstalled,
    required this.cacheBytes,
    required this.databaseBytes,
    required this.deckCount,
    required this.quizCount,
    required this.cardCount,
  });

  /// Sum of the imported source files' sizes.
  final int documentsBytes;

  /// Number of imported files.
  final int fileCount;

  /// The retired on-device model file's bytes on disk (0 when no
  /// file is left). Generation never needs this file anymore.
  final int modelBytes;

  /// Whether a downloaded model file is present on disk (from the
  /// measured bytes, not the service state).
  final bool modelInstalled;

  /// Temporary cache bytes.
  final int cacheBytes;

  /// The drift database file's bytes.
  final int databaseBytes;

  /// Persisted flashcard decks.
  final int deckCount;

  /// Persisted quiz decks.
  final int quizCount;

  /// Generated flashcards across all decks.
  final int cardCount;

  /// The known-content total: documents + model + cache + database.
  int get totalBytes =>
      documentsBytes + modelBytes + cacheBytes + databaseBytes;
}

final storageFiguresProvider = FutureProvider<StorageFigures>((ref) async {
  // Re-read after a cache clear or a data wipe.
  ref.watch(storageVersionProvider);
  final storage = ref.watch(storageServiceProvider);
  final documents = await ref.watch(documentRepositoryProvider).listDocuments();
  final documentsBytes = documents.fold<int>(
    0,
    (sum, doc) => sum + doc.sizeBytes,
  );
  final decks = await ref.watch(studyRepositoryProvider).watchDecks().first;
  final stats = await ref.watch(studyRepositoryProvider).getStats();
  // The legacy model file, if one is still on disk — measured
  // directly, independent of the service state: a file can be
  // present while the service is not configured, and absent while
  // it is.
  final modelBytes = await storage.modelSizeBytes();
  return StorageFigures(
    documentsBytes: documentsBytes,
    fileCount: documents.length,
    modelBytes: modelBytes,
    modelInstalled: modelBytes > 0,
    cacheBytes: await storage.cacheSizeBytes(),
    databaseBytes: await storage.databaseSizeBytes(),
    deckCount: decks.where((deck) => !deck.isQuiz).length,
    quizCount: decks.where((deck) => deck.isQuiz).length,
    cardCount: stats.totalFlashcardsGenerated,
  );
});

/// Clears the temporary cache and re-reads the storage figures.
/// Returns the bytes freed.
Future<int> clearCache(WidgetRef ref) async {
  final freed = await ref.read(storageServiceProvider).clearCache();
  ref.read(storageVersionProvider.notifier).bump();
  return freed;
}

/// Wipes all local data: scheduled reminders are cancelled first,
/// then the model, every document (record, extracted text, stored
/// file), every study row, every setting and the temp cache. The
/// caller navigates afterwards (Home shows state A/B on empty
/// data). A model-delete failure never blocks the rest of the wipe.
Future<void> clearAllLocalData(WidgetRef ref) async {
  final notifications = ref.read(notificationServiceProvider);
  await notifications.cancelDailyReminder();
  await notifications.cancelAllRevisionReminders();
  try {
    await ref.read(modelProvider.notifier).deleteModel();
  } catch (_) {
    // The model may already be gone; the wipe continues.
  }
  final documents = ref.read(documentRepositoryProvider);
  for (final doc in await documents.listDocuments()) {
    await documents.delete(doc.id);
  }
  await ref.read(studyRepositoryProvider).deleteAllStudyData();
  await ref.read(settingsRepositoryProvider).clearAll();
  await ref.read(storageServiceProvider).clearCache();
  ref.read(storageVersionProvider.notifier).bump();
  ref.read(studyDataVersionProvider.notifier).bump();
  await ref.read(modelProvider.notifier).refresh();
}
