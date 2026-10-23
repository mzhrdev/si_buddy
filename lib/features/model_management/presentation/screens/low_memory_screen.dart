import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/model_state.dart';
import '../providers/model_providers.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Low Memory, implemented from the Figma frame
/// "SI Buddy · AI Model — Low Memory" (5:15363).
///
/// "Check Again" re-probes the runtime: if the model activates
/// cleanly now, the screen replaces itself with Ready Offline. (The
/// probe is model activation itself — the approved runtime exposes
/// no separate free-memory reading.)
class ModelLowMemoryScreen extends ConsumerWidget {
  const ModelLowMemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModelManagementLayout(
      statusLabel: 'Installed · Low memory',
      statusColor: AppColors.danger,
      readinessBackground: AppColors.dangerSurface,
      readinessIconAsset: 'assets/icons/figma/circle_alert.svg',
      readinessIconColor: AppColors.danger,
      readinessTitle: 'Not enough free memory',
      readinessBody:
          'Generation is temporarily unavailable. Close other apps or reduce generation size, then check again.',
      generationAvailability:
          'Model installed; waiting for enough free resources.',
      primaryLabel: 'Check Again',
      onPrimary: () async {
        await ref.read(modelProvider.notifier).refresh();
        if (context.mounted &&
            ref.read(modelProvider).status == ModelStatus.ready) {
          context.pushReplacement(AppRoutes.readyOffline);
        }
      },
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
      modelVersion: AiModelInfo.current.versionLabel,
      downloadSize: AiModelInfo.current.downloadSizeLabel,
    );
  }
}
