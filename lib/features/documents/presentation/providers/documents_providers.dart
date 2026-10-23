import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/document_repository_impl.dart';
import '../../domain/document_failures.dart';
import '../../domain/document_models.dart';
import '../../domain/document_repository.dart';

/// The app-wide database instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
});

/// The documents repository the import/extraction flow runs on.
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

// ---------------------------------------------------------------------------
// Import job: the file the user picked, its editable title and subject,
// and the last validation failure.
// ---------------------------------------------------------------------------

class ImportJobState {
  const ImportJobState({
    this.file,
    this.title = '',
    this.subject = 'Biology',
    this.error,
    this.isPicking = false,
  });

  /// The validated picked file, or null before picking.
  final FileRef? file;

  /// The file name to import under (edited via the preview's rename).
  final String title;

  /// The chosen subject (folder) name.
  final String subject;

  /// The last validation failure, when picking failed.
  final DocumentFailure? error;

  /// Whether the platform picker is currently open.
  final bool isPicking;

  /// The name shown for the file on the preview screen.
  String get displayFileName {
    final picked = file;
    if (picked == null) return title;
    return title.isEmpty ? picked.name : title;
  }

  ImportJobState copyWith({
    FileRef? file,
    String? title,
    String? subject,
    DocumentFailure? error,
    bool clearError = false,
    bool? isPicking,
  }) {
    return ImportJobState(
      file: file ?? this.file,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      error: clearError ? null : (error ?? this.error),
      isPicking: isPicking ?? this.isPicking,
    );
  }
}

class ImportJobNotifier extends Notifier<ImportJobState> {
  @override
  ImportJobState build() => const ImportJobState();

  /// Opens the file picker. Returns true when a file was picked and
  /// validated; on failure the typed failure lands in
  /// [ImportJobState.error] so the caller can route to its error
  /// screen. Returns false without an error when the user cancels.
  Future<bool> pickFile() async {
    state = state.copyWith(isPicking: true, clearError: true);
    try {
      final file = await ref.read(documentRepositoryProvider).pickFile();
      if (file == null) {
        state = state.copyWith(isPicking: false);
        return false;
      }
      state = ImportJobState(
        file: file,
        title: file.name,
        subject: state.subject,
      );
      return true;
    } on DocumentFailure catch (failure) {
      state = state.copyWith(isPicking: false, error: failure);
      return false;
    }
  }

  void setTitle(String title) => state = state.copyWith(title: title);

  void setSubject(String subject) => state = state.copyWith(subject: subject);

  void clearError() => state = state.copyWith(clearError: true);

  void reset() => state = const ImportJobState();
}

final importJobProvider = NotifierProvider<ImportJobNotifier, ImportJobState>(
  ImportJobNotifier.new,
);

// ---------------------------------------------------------------------------
// Extraction job: consumes the repository's stage stream and exposes
// exactly the state the processing screen's checklist renders.
// ---------------------------------------------------------------------------

/// Where a stage sits relative to the job's current stage.
enum StageStatus { upcoming, active, complete }

/// Lifecycle of an extraction job.
enum ExtractionStatus { idle, running, completed, failed, cancelled }

class ExtractionState {
  const ExtractionState({
    this.status = ExtractionStatus.idle,
    this.file,
    this.title,
    this.subject,
    this.currentStage,
    this.currentPage = 0,
    this.totalPages = 0,
    this.fraction = 0,
    this.result,
    this.error,
  });

  final ExtractionStatus status;

  /// The file being extracted.
  final FileRef? file;

  /// The title chosen on the preview screen.
  final String? title;

  /// The subject (folder) chosen on the preview screen.
  final String? subject;

  /// The stage currently in progress.
  final ExtractionStage? currentStage;

  /// The page/slide being processed (1-based).
  final int currentPage;

  /// Total pages/slides.
  final int totalPages;

  /// Overall progress, 0.0–1.0.
  final double fraction;

  /// The finished extraction, once [status] is completed.
  final ExtractedDocument? result;

  /// The failure that ended the job, once [status] is failed.
  final Object? error;

  /// Progress within the extraction stage, for its linear bar.
  double get stageFraction {
    if (totalPages == 0) return 0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  /// The document card title (the original file name).
  String get documentTitle =>
      result?.document.originalFileName ?? file?.name ?? '';

  /// The document card subtitle, in the design's format:
  /// `PDF · 2.4 MB · 12 pages`.
  String get documentSubtitle {
    final picked = file;
    if (picked == null) return '';
    final parts = <String>[
      picked.format.label,
      picked.sizeLabel,
      if (totalPages > 0) '$totalPages ${picked.format.unitLabel}',
    ];
    return parts.join(' · ');
  }

  StageStatus statusOf(ExtractionStage stage) {
    if (status == ExtractionStatus.completed) return StageStatus.complete;
    final current = currentStage;
    if (current == null) {
      return stage == ExtractionStage.readingDocument &&
              status == ExtractionStatus.running
          ? StageStatus.active
          : StageStatus.upcoming;
    }
    if (stage.index < current.index) return StageStatus.complete;
    if (stage == current) return StageStatus.active;
    return StageStatus.upcoming;
  }

  /// The checklist subtitle for a stage, following the processing
  /// screen's copy patterns (`Complete · 12 pages found`,
  /// `Processing page 7 of 12`, `Up next · organize text for review`).
  String subtitleFor(ExtractionStage stage) {
    final unit = file?.format.unitLabel ?? 'pages';
    return switch (statusOf(stage)) {
      StageStatus.complete => switch (stage) {
        ExtractionStage.readingDocument =>
          'Complete · $totalPages $unit found',
        _ => 'Complete',
      },
      StageStatus.active => switch (stage) {
        ExtractionStage.readingDocument => 'Reading your document',
        ExtractionStage.extractingText =>
          'Processing page $currentPage of $totalPages',
        ExtractionStage.preparingContent => 'Organizing text for review',
      },
      StageStatus.upcoming => switch (stage) {
        ExtractionStage.readingDocument => 'Up next · read the document',
        ExtractionStage.extractingText => 'Up next · extract the text',
        ExtractionStage.preparingContent =>
          'Up next · organize text for review',
      },
    };
  }

  ExtractionState copyWith({
    ExtractionStatus? status,
    ExtractionStage? currentStage,
    int? currentPage,
    int? totalPages,
    double? fraction,
    ExtractedDocument? result,
    Object? error,
  }) {
    return ExtractionState(
      status: status ?? this.status,
      file: file,
      title: title,
      subject: subject,
      currentStage: currentStage ?? this.currentStage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      fraction: fraction ?? this.fraction,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class ExtractionNotifier extends Notifier<ExtractionState> {
  StreamSubscription<ExtractionUpdate>? _subscription;

  @override
  ExtractionState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const ExtractionState();
  }

  /// Starts extracting [file] under [title] into the [subject] folder,
  /// replacing any job already in progress.
  void start({required FileRef file, String? title, String? subject}) {
    _subscription?.cancel();
    state = ExtractionState(
      status: ExtractionStatus.running,
      file: file,
      title: title,
      subject: subject,
      currentStage: ExtractionStage.readingDocument,
      totalPages: file.pageCount ?? 0,
    );
    _subscription = ref
        .read(documentRepositoryProvider)
        .extractText(file, title: title, folderName: subject)
        .listen(
          (update) {
            state = state.copyWith(
              status: update.document != null
                  ? ExtractionStatus.completed
                  : ExtractionStatus.running,
              currentStage: update.stage,
              currentPage: update.currentPage,
              totalPages: update.totalPages > 0
                  ? update.totalPages
                  : state.totalPages,
              fraction: update.fraction,
              result: update.document,
            );
          },
          onError: (Object error) {
            state = state.copyWith(
              status: ExtractionStatus.failed,
              error: error,
            );
          },
          onDone: () {
            // A stream that ends without a result or an error was
            // aborted upstream (e.g. cancellation reached the source).
            if (state.status == ExtractionStatus.running) {
              state = state.copyWith(status: ExtractionStatus.cancelled);
            }
          },
        );
  }

  /// Cancels the running job. The repository aborts before anything
  /// is persisted.
  void cancel() {
    _subscription?.cancel();
    if (state.status == ExtractionStatus.running) {
      state = state.copyWith(status: ExtractionStatus.cancelled);
    }
  }

  void reset() {
    _subscription?.cancel();
    state = const ExtractionState();
  }
}

final extractionProvider =
    NotifierProvider<ExtractionNotifier, ExtractionState>(
      ExtractionNotifier.new,
    );
