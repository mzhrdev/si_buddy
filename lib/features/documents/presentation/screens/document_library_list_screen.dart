import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/documents_providers.dart';
import '../providers/library_providers.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../widgets/document_actions.dart';
import '../widgets/library_document_cards.dart';
import '../widgets/library_header.dart';
import '../widgets/library_search_panel.dart';
import '../widgets/library_tools.dart';

/// Document library in list view, implemented from the Figma frame
/// "SI Buddy · Document Library — List" (4:11433). Tab root: the bottom
/// navigation comes from the app shell.
///
/// The list is the live library from drift, after the active filters
/// and sort ([filteredDocumentsProvider]): every document persisted
/// by the import flow appears here. With no saved documents it shows
/// an honest empty state instead of the design's sample documents;
/// when the filters exclude everything it says so and offers a
/// reset. The search field above the list is inline — results open
/// in a dropdown panel on this screen, not on a separate search
/// screen.
class DocumentLibraryListScreen extends ConsumerWidget {
  const DocumentLibraryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsStreamProvider);
    final documents = ref.watch(filteredDocumentsProvider);
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            LibraryHeader(
              subtitle: documentsAsync.when(
                data: (all) {
                  final total = all.length;
                  final shown = documents.length;
                  final count = shown == total
                      ? '$total document${total == 1 ? '' : 's'}'
                      : '$shown of $total documents';
                  return '$count · Saved on this device';
                },
                loading: () => 'Saved on this device',
                error: (_, _) => 'Saved on this device',
              ),
              onImport: () => context.push(AppRoutes.importFiles),
            ),
            Expanded(
              child: documentsAsync.when(
                // A static label, not a spinner: a spinning indicator
                // animates forever, which would keep pumpAndSettle
                // (and any frame-quiet check) from ever settling
                // while the library stream is still loading.
                loading: () => Center(
                  child: Text(
                    'Loading your library…',
                    style: AppTextStyles.body(context),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load your library. Try reopening this tab.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(context),
                    ),
                  ),
                ),
                data: (all) {
                  if (all.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No documents yet.',
                            style: AppTextStyles.title(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Import your first document to see it here.',
                            style: AppTextStyles.body(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () =>
                                context.push(AppRoutes.importFiles),
                            child: const Text('Import Notes'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (documents.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No documents match your filters.',
                            style: AppTextStyles.title(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different filter, or reset them to see all ${all.length} document${all.length == 1 ? '' : 's'}.',
                            style: AppTextStyles.body(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            onPressed: () => ref
                                .read(libraryFilterProvider.notifier)
                                .reset(),
                            child: const Text('Reset filters'),
                          ),
                        ],
                      ),
                    );
                  }
                  final counts =
                      ref.watch(deckCountsByDocumentProvider).value ??
                      const <int, int>{};
                  final items = documents
                      .map(
                        (document) => documentToLibraryItem(
                          document,
                          studySets: counts[document.id] ?? 0,
                        ),
                      )
                      .toList();
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
                    children: [
                      const LibrarySearchPanel(),
                      const SizedBox(height: 12),
                      LibraryTools(
                        gridView: false,
                        onOrganizeTap: () => context.push(AppRoutes.organize),
                        onSortTap: () => context.push(AppRoutes.filters),
                        onFiltersTap: () => context.push(AppRoutes.filters),
                        onShowList: () {},
                        onShowGrid: () => context.go(AppRoutes.grid),
                      ),
                      const SizedBox(height: 12),
                      Text('All documents', style: AppTextStyles.title(context)),
                      const SizedBox(height: 12),
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        DocumentListCard(
                          document: items[i],
                          onTap: () {
                            ref
                                .read(selectedDocumentIdProvider.notifier)
                                .select(documents[i].id);
                            context.push(AppRoutes.details);
                          },
                          onMore: () =>
                              showDocumentMenu(context, ref, documents[i]),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
