import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../widgets/confirmation_dialog.dart';

/// Delete File confirmation, implemented from the Figma frame
/// "SI Buddy · Delete File Confirmation" (5:21215) — a confirmation
/// dialog overlaid on the Storage screen.
///
/// When a library document is selected, confirming really deletes
/// it (record, extracted text and the app's stored copy) and clears
/// the selection; opened without a selection it just closes, as
/// before.
class DeleteFileConfirmationScreen extends ConsumerWidget {
  const DeleteFileConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      onConfirm: () async {
        final id = ref.read(selectedDocumentIdProvider);
        if (id != null) {
          await ref.read(documentRepositoryProvider).delete(id);
          ref.read(selectedDocumentIdProvider.notifier).clear();
        }
        if (context.mounted) context.pop();
      },
      onCancel: () => context.pop(),
    );
  }
}
