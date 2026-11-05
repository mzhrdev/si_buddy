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
///   flashcards, when one exists this session (decks are not
///   persisted yet, so nothing shows here after a restart).
/// - Study progress: study sessions, minutes and streaks are not
///   tracked anywhere yet, so they honestly read 0 instead of the
///   design's sample 24 cards / 15 minutes / 3-day streak.
/// - Model status: the model provider's last known state. It only
///   becomes "ready" after a model screen has probed or a download
///   has completed in this session; on a cold start it reads as
///   not installed until the AI Model screen is visited.
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
