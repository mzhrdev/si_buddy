import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/document_repository_impl.dart';
import '../widgets/library_documents.dart';
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
// Library: the live list of saved documents, and the document the
// details screen is showing. The library screens watch this stream,
// so an import that persists a document appears in the library
// without any manual refresh.
// ---------------------------------------------------------------------------

/// Live list of saved documents, newest first (the repository's
/// ordering), as an async value so library screens can render
/// loading / error / empty states honestly.
final documentsStreamProvider = StreamProvider<List<Document>>((ref) {
  return ref.watch(documentRepositoryProvider).watchDocuments();
});

/// The library document id the details screen should show, or null
/// when it was opened without a document (it then keeps the design's
/// sample content, as before). Set by library/home taps before
/// navigating to the details route.
class SelectedDocumentNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? id) => state = id;
  void clear() => state = null;
}

final selectedDocumentIdProvider =
    NotifierProvider<SelectedDocumentNotifier, int?>(
      SelectedDocumentNotifier.new,
    );

/// The selected library document, or null when none is selected or
/// it is no longer in the library (e.g. it was deleted).
final selectedDocumentProvider = Provider<Document?>((ref) {
  final id = ref.watch(selectedDocumentIdProvider);
  if (id == null) return null;
  final documents = ref.watch(documentsStreamProvider).value;
  if (documents == null) return null;
  for (final document in documents) {
    if (document.id == id) return document;
  }
  return null;
});

/// The selected document's extracted text, for the details screen's
/// preview. Null while loading, when nothing is selected, or when
/// the document has no saved extraction.
final selectedExtractedDocumentProvider =
    FutureProvider<ExtractedDocument?>((ref) async {
      final id = ref.watch(selectedDocumentIdProvider);
      if (id == null) return null;
      return ref.watch(documentRepositoryProvider).getExtractedDocument(id);
    });

/// Formats a date the way the library cards do: `16 Oct 2026`.
String formatLibraryDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

/// The name a saved document is shown under: its (possibly renamed)
/// title, with the format extension re-attached when the title does
/// not already carry it, so renaming stays visible in the library.
String documentDisplayName(Document document) {
  final title = document.title.trim();
  if (title.isEmpty) return document.originalFileName;
  final suffix = '.${document.format.extension}';
  return title.toLowerCase().endsWith(suffix) ? title : '$title$suffix';
}

/// Maps a saved [Document] onto the library cards' item shape.
/// Study-set counts are real in the only sense available today:
/// no deck/quiz persistence exists yet, so every document honestly
/// reports 0 study sets until that phase lands.
LibraryDocumentItem documentToLibraryItem(Document document) {
  return LibraryDocumentItem(
    format: document.format.label,
    title: documentDisplayName(document),
    date: formatLibraryDate(document.createdAt),
    studySets: '0 study sets',
    subject:
        'Saved on this device · ${document.pageCount} ${document.format.unitLabel}',
  );
}

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
    this.ocrActive = false,
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

  /// True while the current page is being read with OCR (a scanned,
  /// image-only page). See [ExtractionUpdate.ocrActive].
  final bool ocrActive;

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
        ExtractionStage.extractingText => ocrActive
            ? 'Reading scanned page $currentPage of $totalPages'
            : 'Processing page $currentPage of $totalPages',
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
    bool? ocrActive,
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
      ocrActive: ocrActive ?? this.ocrActive,
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
              ocrActive: update.ocrActive,
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

  /// Shows an already-persisted extraction (e.g. opened from the
  /// library details screen) in the review/success screens, which
  /// otherwise only know the in-progress import job's result.
  void loadExisting(ExtractedDocument extracted) {
    _subscription?.cancel();
    final document = extracted.document;
    state = ExtractionState(
      status: ExtractionStatus.completed,
      file: FileRef(
        path: document.storedPath,
        name: document.originalFileName,
        format: document.format,
        sizeBytes: document.sizeBytes,
        pageCount: document.pageCount,
      ),
      title: document.title,
      currentStage: ExtractionStage.preparingContent,
      totalPages: document.pageCount,
      fraction: 1,
      result: extracted,
    );
  }
}

final extractionProvider =
    NotifierProvider<ExtractionNotifier, ExtractionState>(
      ExtractionNotifier.new,
    );
