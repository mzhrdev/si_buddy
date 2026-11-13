import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/layout/responsive_spacing.dart';
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
/// renders exactly one of [HomeState] — welcome + AI service setup
/// when no service is configured, Import Notes when nothing is
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
          padding: ResponsiveSpacing.page(context),
          children: [
            ResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeHeader(greeting: greeting),
                  ResponsiveSpacing.gap(context, 16),
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
          ],
        ),
      ),
    );
  }
}

/// State A: no AI service configured. Only a service message —
/// no import button, no statistics, no documents.
class _NoModelSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Welcome to SI Buddy.', style: AppTextStyles.display(context)),
        const SizedBox(height: 8),
        Text(
          'Your personal study space. AI generation uses your '
          'online AI service — your notes stay on your device.',
          style: AppTextStyles.body(context),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appCard,
            border: Border.all(color: context.appBorder),
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
                      color: context.appSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/svgs/figma/wifi_off.svg',
                        width: 19,
                        height: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI service not configured',
                        style: AppTextStyles.itemTitle(context),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Generation needs your online AI service.',
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'This build doesn’t have an AI service configured, '
                'so generation is unavailable. Your documents and '
                'study sets still work.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 18 / 12,
                  color: context.appMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.push(AppRoutes.aiService),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Open AI Model'),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/svgs/figma/arrow_right.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(context.appCard, BlendMode.srcIn),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No account. Your notes stay on your device.',
              style: AppTextStyles.caption(context),
            ),
          ],
        ),
      ],
    );
  }
}

/// State B: service configured, nothing imported yet. Service
/// status + Import Notes — no documents, no statistics.
class _NoDocumentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/svgs/figma/ready_indicator.svg',
              width: 8,
              height: 8,
            ),
            const SizedBox(width: 6),
            Text(
              'AI Service Ready',
              style: AppTextStyles.successLabel(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Big ideas start with\nyour first notes.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 34 / 28,
            letterSpacing: -0.56,
            color: context.appText,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'No notes yet. Import a document to turn it into '
          'flashcards, quizzes and summaries.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            color: context.appMuted,
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
                'assets/svgs/figma/arrow_right.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(context.appCard, BlendMode.srcIn),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'PDF or PPTX · Stored on your device',
          style: AppTextStyles.caption(context),
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
                'assets/svgs/figma/arrow_right.svg',
                width: 19,
                height: 19,
                colorFilter: ColorFilter.mode(context.appCard, BlendMode.srcIn),
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
            onAction: () => context.go(AppRoutes.planner),
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
          Text(
            'No finished quizzes yet.',
            style: TextStyle(color: context.appMuted),
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
        color: context.appCard,
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next step: turn ${document.title} into study tools',
            style: AppTextStyles.itemTitle(context),
          ),
          const SizedBox(height: 4),
          Text(document.details, style: AppTextStyles.caption(context)),
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
        color: context.appCard,
        border: Border.all(color: context.appBorder),
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
                  style: AppTextStyles.itemTitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appChip,
                  border: Border.all(color: context.appBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  pickUp.kindLabel,
                  style: AppTextStyles.badge(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(pickUp.progressText, style: AppTextStyles.caption(context)),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: context.appBorder,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pickUp.fraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: context.appPrimary,
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
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              style: AppTextStyles.itemTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(item.subtitle, style: AppTextStyles.caption(context)),
        ],
      ),
    );
  }
}
