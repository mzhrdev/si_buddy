import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../widgets/library_document_cards.dart';
import '../widgets/library_documents.dart';
import '../widgets/library_header.dart';
import '../widgets/library_tools.dart';

/// Document library in grid view, implemented from the Figma frame
/// "SI Buddy · Document Library — Grid" (4:11537). Tab root: the bottom
/// navigation comes from the app shell.
class DocumentLibraryGridScreen extends StatelessWidget {
  const DocumentLibraryGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            LibraryHeader(
              subtitle: '4 documents · Saved on this device',
              onImport: () => context.push(AppRoutes.importFiles),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
                children: [
                  LibraryTools(
                    gridView: true,
                    onSearchTap: () => context.push(AppRoutes.searchResults),
                    onOrganizeTap: () => context.push(AppRoutes.organize),
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
                    itemCount: libraryDocuments.length,
                    itemBuilder: (context, i) => DocumentGridCard(
                      document: libraryDocuments[i],
                      onTap: () => context.push(AppRoutes.details),
                      // TODO(backend): document overflow actions.
                      onMore: () {},
                    ),
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
