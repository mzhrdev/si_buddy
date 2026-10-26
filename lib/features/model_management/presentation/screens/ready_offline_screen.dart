import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/model_state.dart';
import '../providers/model_providers.dart';
import '../widgets/model_management_layout.dart';

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
  ConsumerState<ReadyOfflineScreen> createState() =>
      _ReadyOfflineScreenState();
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
      statusColor: AppColors.successText,
      readinessIconAsset: 'assets/icons/figma/circle_check_outline.svg',
      readinessIconColor: AppColors.primary,
      readinessTitle: 'Installed and ready for offline AI',
      readinessBody:
          'Installation successful. Local generation works offline when enough device memory and storage are available.',
      generationAvailability: 'Works offline with sufficient device resources.',
      primaryLabel: 'Continue Studying',
      onPrimary: () => context.go(AppRoutes.home),
      secondaryLabel: 'Delete Model',
      onSecondary: () => context.push(AppRoutes.deleteModel),
      secondaryColor: AppColors.danger,
      secondaryBorderColor: AppColors.danger,
      modelVersion: AiModelInfo.current.versionLabel,
      downloadSize: AiModelInfo.current.downloadSizeLabel,
    );
  }
}
