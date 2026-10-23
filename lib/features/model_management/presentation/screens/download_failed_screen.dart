import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/model_state.dart';
import '../providers/model_providers.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Download Failed, implemented from the Figma frame
/// "SI Buddy · AI Model — Download Failed" (5:15287).
///
/// The readiness body shows the typed failure's message when a
/// download actually failed (a lost connection, an unauthorized
/// model request, …); opened directly it keeps the frame's copy.
/// Retry restarts the download.
class ModelDownloadFailedScreen extends ConsumerWidget {
  const ModelDownloadFailedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failure = ref.watch(modelProvider).failure;
    return ModelManagementLayout(
      statusLabel: 'Download failed · Not installed',
      statusColor: AppColors.danger,
      readinessBackground: AppColors.dangerSurface,
      readinessIconAsset: 'assets/icons/figma/circle_alert.svg',
      readinessIconColor: AppColors.danger,
      readinessTitle: 'Model download interrupted',
      readinessBody:
          failure?.message ??
          'The internet connection was lost. The model is not installed. Reconnect to the internet and try again.',
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: 'Retry',
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
