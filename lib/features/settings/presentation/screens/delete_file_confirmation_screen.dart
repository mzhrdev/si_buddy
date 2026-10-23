import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/confirmation_dialog.dart';

/// Delete File confirmation, implemented from the Figma frame
/// "SI Buddy · Delete File Confirmation" (5:21215) — a confirmation
/// dialog overlaid on the Storage screen.
class DeleteFileConfirmationScreen extends StatelessWidget {
  const DeleteFileConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      iconAsset: 'assets/icons/figma/trash_2.svg',
      indicatorColor: AppColors.dangerSurface,
      iconColor: AppColors.danger,
      title: 'Delete File?',
      messageParagraphs: const [
        'Permanently remove this app’s copy of the document and its '
            'extracted text. This cannot be undone.',
        'Already generated study sets and progress remain. Files and '
            'exports outside SI Buddy are not removed.',
      ],
      confirmLabel: 'Delete File',
      confirmColor: AppColors.danger,
      // TODO(backend): delete the local file, then return.
      onConfirm: () => context.pop(),
      onCancel: () => context.pop(),
    );
  }
}
