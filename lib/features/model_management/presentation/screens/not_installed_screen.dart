import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/model_state.dart';
import '../providers/model_providers.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Not Installed, implemented from the Figma frame
/// "SI Buddy · AI Model — Not Installed" (5:15053).
///
/// Probes the runtime when opened: if a model turns out to be
/// installed and active after all, the screen replaces itself with
/// Ready Offline instead of offering a redundant download.
class ModelNotInstalledScreen extends ConsumerStatefulWidget {
  const ModelNotInstalledScreen({super.key});

  @override
  ConsumerState<ModelNotInstalledScreen> createState() =>
      _ModelNotInstalledScreenState();
}

class _ModelNotInstalledScreenState
    extends ConsumerState<ModelNotInstalledScreen> {
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
      if (next.status == ModelStatus.ready &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        context.pushReplacement(AppRoutes.readyOffline);
      }
    });
    return ModelManagementLayout(
      statusLabel: 'Not installed',
      statusColor: AppColors.primary,
      readinessIconAsset: 'assets/icons/figma/download_plain.svg',
      readinessIconColor: AppColors.primary,
      readinessTitle: 'Download once. Generate offline.',
      readinessBody:
          'The initial model download requires internet. AI generation is unavailable until installation completes.',
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: 'Download Model',
      onPrimary: () {
        ref.read(modelProvider.notifier).startDownload();
        context.push(AppRoutes.downloading);
      },
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
      modelVersion: AiModelInfo.current.versionLabel,
      downloadSize: AiModelInfo.current.downloadSizeLabel,
    );
  }
}
