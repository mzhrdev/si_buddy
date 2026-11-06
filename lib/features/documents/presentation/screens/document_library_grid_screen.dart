import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/documents_providers.dart';
import '../../../study/presentation/providers/study_providers.dart';
import '../widgets/library_document_cards.dart';
import '../widgets/library_header.dart';
import '../widgets/library_tools.dart';

/// Document library in grid view, implemented from the Figma frame
/// "SI Buddy · Document Library — Grid" (4:11537). Tab root: the bottom
/// navigation comes from the app shell.
///
/// Shares the live library stream with the list view, so both views
/// always show the same saved documents.
class DocumentLibraryGridScreen extends ConsumerWidget {
  const DocumentLibraryGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsStreamProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            LibraryHeader(
              subtitle: documentsAsync.when(
                data: (documents) =>
                    '${documents.length} document${documents.length == 1 ? '' : 's'} · Saved on this device',
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
                    style: AppTextStyles.body,
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load your library. Try reopening this tab.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                  ),
                ),
                data: (documents) {
                  if (documents.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No documents yet.',
                            style: AppTextStyles.title,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Import your first document to see it here.',
                            style: AppTextStyles.body,
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
                      LibraryTools(
                        gridView: true,
                        onSearchTap: () =>
                            context.push(AppRoutes.searchResults),
                        onOrganizeTap: () =>
                            context.push(AppRoutes.organize),
                        onSortTap: () => context.push(AppRoutes.filters),
                        onFiltersTap: () => context.push(AppRoutes.filters),
                        onShowList: () => context.go(AppRoutes.list),
                        onShowGrid: () {},
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('All documents', style: AppTextStyles.title),
                          GestureDetector(
                            // TODO(backend): multi-select mode for documents.
                            onTap: () {},
                            child: Text('Select', style: AppTextStyles.link),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 200,
                            ),
                        itemCount: items.length,
                        itemBuilder: (context, i) => DocumentGridCard(
                          document: items[i],
                          onTap: () {
                            ref
                                .read(selectedDocumentIdProvider.notifier)
                                .select(documents[i].id);
                            context.push(AppRoutes.details);
                          },
                          // TODO(backend): document overflow actions.
                          onMore: () {},
                        ),
                      ),
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
