import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../providers/documents_providers.dart';
import '../providers/library_providers.dart';

/// The library's inline search: a real text field with a dropdown
/// results panel below it (Phase 4). Results are tagged Document,
/// Flashcard or Quiz and navigate to the right destination — a
/// document opens its details, a flashcard or quiz loads its deck
/// and opens the study screens. The query lives in
/// [librarySearchQueryProvider], so it survives the list/grid toggle.
///
/// The panel shows while a query is typed; clearing the query (or
/// tapping a result) closes it. An empty query shows nothing — the
/// full document list below stays the library.
class LibrarySearchPanel extends ConsumerStatefulWidget {
  const LibrarySearchPanel({super.key});

  @override
  ConsumerState<LibrarySearchPanel> createState() => _LibrarySearchPanelState();
}

class _LibrarySearchPanelState extends ConsumerState<LibrarySearchPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(librarySearchQueryProvider),
    );
    _controller.addListener(() {
      ref.read(librarySearchQueryProvider.notifier).set(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openResult(LibrarySearchResult result) async {
    switch (result.kind) {
      case LibrarySearchKind.document:
        if (result.documentId != null) {
          ref
              .read(selectedDocumentIdProvider.notifier)
              .select(result.documentId);
        }
        _clear();
        if (mounted) context.push(AppRoutes.details);
      case LibrarySearchKind.flashcard:
      case LibrarySearchKind.quiz:
        if (result.deckId == null) return;
        final loaded = await ref
            .read(generationJobProvider.notifier)
            .loadDeck(result.deckId!);
        if (!mounted) return;
        if (!loaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('That study set is no longer available.'),
            ),
          );
          return;
        }
        _clear();
        if (mounted) {
          context.push(
            result.kind == LibrarySearchKind.quiz
                ? AppRoutes.mcq
                : AppRoutes.deck,
          );
        }
    }
  }

  void _clear() {
    _controller.clear();
    ref.read(librarySearchQueryProvider.notifier).set('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(librarySearchQueryProvider);
    final resultsAsync = ref.watch(librarySearchResultsProvider);
    // The controller is the field's source of truth while typing;
    // keep it in sync when the query is cleared elsewhere.
    if (_controller.text != query) {
      _controller.text = query;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }

    return Column(
      children: [
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma/search.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.navInactive,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: AppTextStyles.body,
                  decoration: InputDecoration(
                    hintText: 'Search all your study material',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.muted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (query.isNotEmpty)
                IconButton(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear, size: 18),
                  color: AppColors.muted,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: 'Clear search',
                ),
            ],
          ),
        ),
        if (query.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: resultsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Searching…',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              error: (_, _) => const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Search is unavailable right now. Try again.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              data: (results) {
                if (results.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No results for \'${query.trim()}\'.',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < results.length; i++) ...[
                      if (i > 0)
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      _SearchResultRow(
                        result: results[i],
                        onTap: () => _openResult(results[i]),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// One inline-search result row: a kind tag, the title and the
/// matching text.
class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.result, required this.onTap});

  final LibrarySearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(result.tagLabel, style: AppTextStyles.badge),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: AppTextStyles.itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.subtitle,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                'assets/icons/figma/chevron_right.svg',
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  AppColors.muted,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
