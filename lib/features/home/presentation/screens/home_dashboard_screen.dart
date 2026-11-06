import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../domain/home_models.dart';
import '../providers/home_providers.dart';
import '../widgets/document_tile.dart';
import '../widgets/home_header.dart';
import '../widgets/section_header.dart';
import '../widgets/study_progress_card.dart';

/// Home dashboard, implemented from the Figma frame
/// "SI Buddy · Home Dashboard" (3:1849).
///
/// The screen is state-driven (production brief, Phase 3): it
/// renders exactly one of [HomeState] — welcome + Download Model
/// when no model is installed, Import Notes when nothing is
/// imported, Recent Documents + a generate next step when no study
/// sets exist yet, statistics + "Pick up where you left off" while
/// work is unfinished, or Recent Documents + study history once
/// everything is complete. Every number comes from
/// [homeDashboardProvider]; navigation uses the existing [AppRoutes]
/// paths. The three quick-action cards from the design (Generate
/// Flashcards / Create Quiz / View Study Sets) are deliberately
/// gone: document selection is the generation entry point.
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
            switch (data.state) {
              HomeState.noModel => _NoModelSection(),
              HomeState.noDocuments => _NoDocumentsSection(),
              HomeState.noStudySets => _NoStudySetsSection(data: data),
              HomeState.active => _ActiveSection(data: data),
              HomeState.completedOnly => _CompletedOnlySection(data: data),
            },
          ],
        ),
      ),
    );
  }
}

/// State A: no AI model installed. Only a download-model message —
/// no import button, no statistics, no documents.
class _NoModelSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Welcome to SI Buddy.', style: AppTextStyles.display),
        const SizedBox(height: 8),
        const Text(
          'Your personal study space. Download the AI model once, '
          'then everything works offline.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/figma/download_plain.svg',
                        width: 19,
                        height: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI model not downloaded',
                        style: AppTextStyles.itemTitle,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'One download. Then AI works offline.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Connect to the internet to download the model before '
                'generating study tools.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 18 / 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.push(AppRoutes.notInstalled),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Download AI Model'),
              SizedBox(width: 8),
              Icon(Icons.download, size: 19),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/figma/shield_check.svg',
              width: 13,
              height: 13,
            ),
            const SizedBox(width: 6),
            const Text(
              'No account. No cloud. Just your notes.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }
}

/// State B: model installed, nothing imported yet. Model status +
/// Import Notes — no documents, no statistics.
class _NoDocumentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/figma/ready_indicator.svg',
              width: 8,
              height: 8,
            ),
            const SizedBox(width: 6),
            const Text('AI Ready Offline', style: AppTextStyles.successLabel),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Big ideas start with\nyour first notes.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 34 / 28,
            letterSpacing: -0.56,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'No notes yet. Import a document to turn it into '
          'flashcards, quizzes and summaries.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () => context.push(AppRoutes.importFiles),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Import Notes'),
              const SizedBox(width: 12),
              SvgPicture.asset(
                'assets/icons/figma/arrow_right.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'PDF or PPTX · Stored on your device',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// State C: documents imported, no study sets yet. Import action +
/// real Recent Documents + a generate next step for the newest
/// document.
class _NoStudySetsSection extends ConsumerWidget {
  const _NoStudySetsSection({required this.data});

  final HomeDashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        if (data.nextStepDocument != null) ...[
          const SizedBox(height: 16),
          _NextStepCard(document: data.nextStepDocument!),
        ],
        const SizedBox(height: 16),
        SectionHeader(
          title: 'Recent documents',
          actionLabel: 'See all',
          onAction: () => context.go(AppRoutes.list),
        ),
        const SizedBox(height: 6),
        for (final document in data.documents)
          DocumentTile(
            document: document,
            onTap: () => _openDetails(context, ref, document.id),
          ),
      ],
    );
  }
}

/// State D/F: unfinished work exists. Genuine statistics, the Pick
/// Up card with real progress, and Recent Documents.
class _ActiveSection extends ConsumerWidget {
  const _ActiveSection({required this.data});

  final HomeDashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudyProgressCard(progress: data.progress),
        const SizedBox(height: 16),
        if (data.pickUp != null) ...[
          SectionHeader(
            title: 'Pick up where you left off',
            actionLabel: 'View all',
            onAction: () => context.go(AppRoutes.studyLibrary),
          ),
          const SizedBox(height: 6),
          _PickUpCard(pickUp: data.pickUp!),
          const SizedBox(height: 16),
        ],
        SectionHeader(
          title: 'Recent documents',
          actionLabel: 'See all',
          onAction: () => context.go(AppRoutes.list),
        ),
        const SizedBox(height: 6),
        for (final document in data.documents)
          DocumentTile(
            document: document,
            onTap: () => _openDetails(context, ref, document.id),
          ),
      ],
    );
  }
}

/// State E: only completed activity. Recent Documents + the genuine
/// study history (finished quiz attempts).
class _CompletedOnlySection extends ConsumerWidget {
  const _CompletedOnlySection({required this.data});

  final HomeDashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Recent documents',
          actionLabel: 'See all',
          onAction: () => context.go(AppRoutes.list),
        ),
        const SizedBox(height: 6),
        for (final document in data.documents)
          DocumentTile(
            document: document,
            onTap: () => _openDetails(context, ref, document.id),
          ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'Study history',
          actionLabel: 'View all',
          onAction: () => context.go(AppRoutes.history),
        ),
        const SizedBox(height: 6),
        if (data.history.isEmpty)
          const Text(
            'No finished quizzes yet.',
            style: TextStyle(color: AppColors.muted),
          ),
        for (final item in data.history) _HistoryRow(item: item),
      ],
    );
  }
}

void _openDetails(BuildContext context, WidgetRef ref, int? id) {
  if (id != null) {
    ref.read(selectedDocumentIdProvider.notifier).select(id);
  }
  context.push(AppRoutes.details);
}

/// The generate next step for state C: turn the newest document
/// into flashcards or a quiz.
class _NextStepCard extends ConsumerWidget {
  const _NextStepCard({required this.document});

  final DocumentSummary document;

  Future<void> _generate(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) async {
    final id = document.id;
    if (id == null) return;
    final bound = await bindDocumentAsGenerationSource(ref, id);
    if (!context.mounted) return;
    if (bound) {
      context.push(route);
    } else {
      _openDetails(context, ref, document.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next step: turn ${document.title} into study tools',
            style: AppTextStyles.itemTitle,
          ),
          const SizedBox(height: 4),
          Text(document.details, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      _generate(context, ref, AppRoutes.generationSetup),
                  child: const Text('Generate flashcards'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _generate(context, ref, AppRoutes.quizSetup),
                  child: const Text('Create quiz'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One unfinished deck with real progress and a Continue action.
class _PickUpCard extends ConsumerWidget {
  const _PickUpCard({required this.pickUp});

  final PickUpItem pickUp;

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    final loaded = await ref
        .read(generationJobProvider.notifier)
        .loadDeck(pickUp.deckId, resume: true);
    if (!context.mounted) return;
    if (!loaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That study set is no longer available.')),
      );
      return;
    }
    context.push(pickUp.isQuiz ? AppRoutes.mcq : AppRoutes.deck);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pickUp.title,
                  style: AppTextStyles.itemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(pickUp.kindLabel, style: AppTextStyles.badge),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(pickUp.progressText, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pickUp.fraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _continue(context, ref),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

/// One finished quiz attempt in the study history.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: AppTextStyles.itemTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(item.subtitle, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
