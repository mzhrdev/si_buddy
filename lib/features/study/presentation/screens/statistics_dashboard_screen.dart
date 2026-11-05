import 'package:flutter/material.dart';

import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../widgets/study_destinations_bar.dart';

/// Statistics Dashboard, implemented from the Figma frame
/// "SI Buddy · Statistics Dashboard" (5:11802): weekly totals, the
/// daily study-time chart, and per-topic strengths from the latest
/// quiz.
///
/// Study sessions are not tracked yet (no session tracking or
/// persistence), so there are no real numbers to show. The screen
/// says so honestly instead of the design's sample metrics — the
/// dashboard returns when study tracking lands.
class StatisticsDashboardScreen extends StatelessWidget {
  const StatisticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Statistics'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                children: [
                  const StudyDestinationsBar(currentIndex: 2),
                  const SizedBox(height: 16),
                  const EmptyState(
                    icon: Icons.bar_chart_outlined,
                    title: 'No statistics yet',
                    message:
                        'Your study time, cards reviewed and quiz scores will appear here once you start studying.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
