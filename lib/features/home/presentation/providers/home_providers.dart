import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../model_management/presentation/providers/model_providers.dart';
import '../../domain/home_models.dart';

/// Time-aware greeting shown above the dashboard headline,
/// e.g. "Good morning, study buddy".
final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  final part = hour < 12
      ? 'Good morning'
      : hour < 17
      ? 'Good afternoon'
      : 'Good evening';
  return '$part, study buddy';
});

/// Dashboard content, built from live sources where they exist.
///
/// - Recent documents: the real library stream, newest first.
/// - "Pick up where you left off": the most recent generation's
///   flashcards, when one exists this session. Decks ARE persisted
///   now (schema v2), but this provider still reads the session
///   result — Phase 3 wires Home to the persisted deck stream.
/// - Study progress: study sessions, minutes and streaks are now
///   tracked in the database (see `studyStatsProvider`), but this
///   provider still reports 0 until Phase 3 wires Home to it.
/// - Model status: the model provider's last known state. It is
///   probed once at startup and on every resume (see `MyApp`), so
///   a cold start reads the real state instead of "not installed".
final homeDashboardProvider = Provider<HomeDashboardData>((ref) {
  final documents = ref.watch(documentsStreamProvider).value ?? const [];
  final result = ref.watch(lastGenerationResultProvider);
  final config = ref.watch(generationConfigProvider);
  final modelReady = ref.watch(modelProvider).isReady;
  return HomeDashboardData(
    progress: StudyProgress(
      cardsReviewed: 0,
      minutesStudied: 0,
      dailyGoalMinutes: 20,
      streakDays: 0,
      modelReady: modelReady,
    ),
    documents: [
      for (final document in documents)
        DocumentSummary(
          id: document.id,
          format: document.format.label,
          title: documentDisplayName(document),
          details:
              '${document.format.label} · ${document.pageCount} ${document.format.unitLabel} · ${formatLibraryDate(document.createdAt)}',
        ),
    ],
    decks: result != null && result.flashcards.isNotEmpty
        ? [
            DeckSummary(
              title: generatedMaterialTitle(
                config: config,
                documentName: ref
                    .watch(generationJobProvider)
                    .source
                    ?.document
                    .originalFileName,
              ),
              cardCount: result.flashcards.length,
              dueCount: result.flashcards.length,
              lastStudied: 'Just generated',
            ),
          ]
        : const [],
  );
});
