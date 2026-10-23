import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Dashboard content. Currently mock data mirroring the Figma design;
/// this provider is the seam where the documents/study repositories
/// will plug in without the UI changing.
final homeDashboardProvider = Provider<HomeDashboardData>((ref) {
  return const HomeDashboardData(
    progress: StudyProgress(
      cardsReviewed: 24,
      minutesStudied: 15,
      dailyGoalMinutes: 20,
      streakDays: 3,
      modelReady: true,
    ),
    documents: [
      DocumentSummary(
        format: 'PDF',
        title: 'Cell Biology · Chapter 4',
        details: 'PDF · 12 pages · Today',
      ),
      DocumentSummary(
        format: 'PPTX',
        title: 'Organic Chemistry',
        details: 'PPTX · 28 slides · Yesterday',
      ),
    ],
    decks: [
      DeckSummary(
        title: 'Cell structures',
        cardCount: 20,
        dueCount: 8,
        lastStudied: 'Studied 20 min ago',
      ),
      DeckSummary(
        title: 'Chemical bonds',
        cardCount: 24,
        dueCount: 6,
        lastStudied: 'Studied yesterday',
      ),
    ],
  );
});
