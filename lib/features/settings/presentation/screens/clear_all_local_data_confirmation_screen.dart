import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/confirmation_dialog.dart';

/// Clear All Local Data confirmation, implemented from the Figma frame
/// "SI Buddy · Clear All Local Data Confirmation" (5:21325) — a
/// confirmation dialog overlaid on the Privacy screen.
class ClearAllLocalDataConfirmationScreen extends StatelessWidget {
  const ClearAllLocalDataConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      iconAsset: 'assets/icons/figma/trash_2.svg',
      indicatorColor: AppColors.dangerSurface,
      iconColor: AppColors.danger,
      title: 'Clear All Local Data?',
      messageParagraphs: const [
        'Permanently deletes all documents, extracted text, study '
            'materials, progress, preferences and the downloaded model '
            'from SI Buddy.',
        'This cannot be undone.',
        'To generate new study material afterward, you must download '
            'the model again using the internet.',
        'This does not cancel an active Google Play subscription or '
            'remove exported copies outside the app.',
      ],
      emphasizedParagraphs: const {1},
      confirmLabel: 'Clear All Local Data',
      confirmColor: AppColors.danger,
      // TODO(backend): wipe all local data, then return.
      onConfirm: () => context.pop(),
      onCancel: () => context.pop(),
    );
  }
}
