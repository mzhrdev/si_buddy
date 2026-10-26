import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/model_state.dart';
import '../providers/model_providers.dart';
import '../widgets/model_management_layout.dart';

/// AI Model — Downloading, implemented from the Figma frame
/// "SI Buddy · AI Model — Downloading" (5:15129).
///
/// While a download is running, the progress child shows the live
/// fraction from the model state; completion replaces this screen
/// with Ready Offline, failure with Download Failed. Opened with
/// no download running, it keeps the design's static progress.
class ModelDownloadingScreen extends ConsumerWidget {
  const ModelDownloadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ModelState>(modelProvider, (previous, next) {
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      if (next.status == ModelStatus.ready) {
        context.pushReplacement(AppRoutes.readyOffline);
      } else if (next.status == ModelStatus.failed) {
        context.pushReplacement(AppRoutes.downloadFailed);
      }
    });
    final state = ref.watch(modelProvider);
    return ModelManagementLayout(
      statusLabel: 'Downloading · Not installed',
      statusColor: AppColors.primary,
      readinessIconAsset: 'assets/icons/figma/download_plain.svg',
      readinessIconColor: AppColors.primary,
      readinessTitle: 'Downloading model…',
      readinessBody:
          'Keep your internet connection on. AI generation becomes available only after installation completes.',
      readinessChild: state.isDownloading
          ? ModelDownloadProgress(fraction: state.downloadProgress)
          : const ModelDownloadProgress(),
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: 'Cancel Download',
      onPrimary: () {
        ref.read(modelProvider.notifier).cancelDownload();
        context.push(AppRoutes.notInstalled);
      },
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
      modelVersion: AiModelInfo.current.versionLabel,
      downloadSize: AiModelInfo.current.downloadSizeLabel,
    );
  }
}
