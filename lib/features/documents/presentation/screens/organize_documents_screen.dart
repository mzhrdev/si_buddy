import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';

/// Organize documents, implemented from the Figma frame
/// "SI Buddy · Organize Documents" (4:12019).
///
/// Folders do not exist yet (no folder persistence), so there is
/// nothing to organize into. The screen says so honestly instead
/// of the design's sample folders and a save button that saved
/// nothing. It returns when folder organization lands.
class OrganizeDocumentsScreen extends StatelessWidget {
  const OrganizeDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Organize documents', onBack: () => context.pop()),
            const Expanded(
              child: EmptyState(
                icon: Icons.folder_outlined,
                title: 'Folders aren\'t available yet',
                message:
                    'Your documents live in the library for now. Folders arrive with organization.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
