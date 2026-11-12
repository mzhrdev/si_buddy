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
    final modelState = ref.watch(modelProvider);
    final failure = modelState.failure;
    // A download already running is rejoined, never restarted (see
    // the not-installed screen): a second install of the same file
    // while the first was still running downloaded the model twice.
    final downloading = modelState.isDownloading;
    return ModelManagementLayout(
      statusLabel: 'Download failed · Not installed',
      statusColor: context.appDanger,
      readinessBackground: context.appDangerSurface,
      readinessIconAsset: 'assets/icons/figma/circle_alert.svg',
      readinessIconColor: context.appDanger,
      readinessTitle: 'Model download interrupted',
      readinessBody:
          failure?.message ??
          'The internet connection was lost. The model is not installed. Reconnect to the internet and try again.',
      generationAvailability:
          'Requires an installed model and enough free device resources.',
      primaryLabel: downloading
          ? 'Downloading… ${(modelState.downloadProgress * 100).round()}%'
          : 'Retry',
      onPrimary: () {
        if (!downloading) {
          ref.read(modelProvider.notifier).startDownload();
        }
        context.push(AppRoutes.downloading);
      },
      secondaryLabel: 'Continue Studying',
      onSecondary: () => context.go(AppRoutes.home),
      modelVersion: AiModelInfo.current.versionLabel,
      downloadSize: AiModelInfo.current.downloadSizeLabel,
    );
  }
}
