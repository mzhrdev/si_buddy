import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/model_state.dart';
import '../providers/model_providers.dart';
import '../widgets/model_management_layout.dart';
import '../../../settings/presentation/widgets/confirmation_dialog.dart';

/// AI Model — Ready Offline, implemented from the Figma frame
/// "SI Buddy · AI Model — Ready Offline" (5:15211).
///
/// Probes the runtime when opened: if the model is not actually
/// installed (deleted elsewhere, never downloaded), the screen
/// replaces itself with Not Installed instead of claiming a
/// readiness the device does not have.
class ReadyOfflineScreen extends ConsumerStatefulWidget {
  const ReadyOfflineScreen({super.key});

  @override
  ConsumerState<ReadyOfflineScreen> createState() => _ReadyOfflineScreenState();
}

class _ReadyOfflineScreenState extends ConsumerState<ReadyOfflineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModelState>(modelProvider, (previous, next) {
      if (next.status == ModelStatus.notInstalled &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        context.pushReplacement(AppRoutes.notInstalled);
      }
    });
    return ModelManagementLayout(
      statusLabel: 'AI Ready Offline',
      statusColor: context.appSuccessText,
      readinessIconAsset: 'assets/icons/figma/circle_check_outline.svg',
      readinessIconColor: context.appPrimary,
      readinessTitle: 'Installed and ready for offline AI',
      readinessBody:
          'Installation successful. Local generation works offline when enough device memory and storage are available.',
      generationAvailability: 'Works offline with sufficient device resources.',
      primaryLabel: 'Continue Studying',
      onPrimary: () => context.go(AppRoutes.home),
      secondaryLabel: 'Delete Model',
      onSecondary: () => _confirmDeleteModel(context, ref),
      secondaryColor: context.appDanger,
      secondaryBorderColor: context.appDanger,
      modelVersion: AiModelInfo.current.versionLabel,
      downloadSize: AiModelInfo.current.downloadSizeLabel,
    );
  }

  /// Deletes the model behind a confirmation dialog (the Figma
  /// delete-model confirmation, shown as a dialog over this screen
  /// instead of a separate route). The state listener above
  /// navigates to Not Installed once the deletion lands.
  Future<void> _confirmDeleteModel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      iconAsset: 'assets/icons/figma/trash_2.svg',
      indicatorColor: context.appDangerSurface,
      iconColor: context.appDanger,
      title: 'Delete Model?',
      messageParagraphs: const [
        'Removing this model frees its storage. Your existing documents and study sets stay intact.',
        'To generate new study material later, you’ll need to download the model again using the internet.',
      ],
      confirmLabel: 'Delete Model',
      confirmColor: AppColors.danger,
    );
    if (!confirmed) return;
    await ref.read(modelProvider.notifier).deleteModel();
  }
}
