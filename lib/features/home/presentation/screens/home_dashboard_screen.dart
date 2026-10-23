import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/home_providers.dart';
import '../widgets/deck_card.dart';
import '../widgets/document_tile.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/study_progress_card.dart';

/// Home dashboard, implemented from the Figma frame
/// "SI Buddy · Home Dashboard" (3:1849).
///
/// Content comes from [homeDashboardProvider]; navigation uses the
/// existing [AppRoutes] paths.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(homeDashboardProvider);
    final greeting = ref.watch(greetingProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            HomeHeader(greeting: greeting),
            const SizedBox(height: 16),
            StudyProgressCard(progress: data.progress),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push(AppRoutes.importFiles),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Import Notes'),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/figma/arrow_right.svg',
                    width: 19,
                    height: 19,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: QuickActionTile(
                    iconAsset: 'assets/icons/figma/gallery_vertical_end.svg',
                    label: 'Generate Flashcards',
                    onTap: () => context.push(AppRoutes.generationSetup),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: QuickActionTile(
                    iconAsset: 'assets/icons/figma/list_checks.svg',
                    label: 'Create Quiz',
                    onTap: () => context.push(AppRoutes.quizSetup),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: QuickActionTile(
                    iconAsset: 'assets/icons/figma/layers.svg',
                    label: 'View Study Sets',
                    onTap: () => context.go(AppRoutes.studyLibrary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionHeader(
              title: 'Recent documents',
              actionLabel: 'See all',
              onAction: () => context.go(AppRoutes.list),
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < data.documents.length; i++)
              DocumentTile(
                document: data.documents[i],
                onTap: () => context.push(AppRoutes.details),
              ),
            const SizedBox(height: 16),
            SectionHeader(
              title: 'Pick up where you left off',
              actionLabel: 'View all',
              onAction: () => context.go(AppRoutes.studyLibrary),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < data.decks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(
                    child: DeckCard(
                      deck: data.decks[i],
                      onTap: () => context.push(AppRoutes.deck),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
