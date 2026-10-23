import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';

/// Shared layout for the AI Model management frames: the model package
/// card (identity, installation status, package metadata), the readiness
/// card, the "What works offline" availability list, and the pinned
/// primary/secondary actions.
///
/// The individual frames differ only in status, readiness content,
/// availability copy for new AI generation, and action labels/colors.
class ModelManagementLayout extends StatelessWidget {
  const ModelManagementLayout({
    required this.statusLabel,
    required this.statusColor,
    required this.readinessIconAsset,
    required this.readinessIconColor,
    required this.readinessTitle,
    required this.readinessBody,
    required this.generationAvailability,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.readinessBackground = AppColors.white,
    this.readinessChild,
    this.secondaryColor = AppColors.primary,
    this.secondaryBorderColor = AppColors.border,
    this.modelVersion = 'To be confirmed',
    this.downloadSize = 'To be confirmed',
    super.key,
  });

  final String statusLabel;
  final Color statusColor;
  final String readinessIconAsset;
  final Color readinessIconColor;
  final String readinessTitle;
  final String readinessBody;
  final Color readinessBackground;

  /// Optional extra content under the readiness body (download progress).
  final Widget? readinessChild;

  /// Description for the "New AI generation" availability row.
  final String generationAvailability;

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
  final Color secondaryColor;
  final Color secondaryBorderColor;

  /// Package card metadata. Defaults keep the design's placeholder;
  /// wired screens pass the real model's values.
  final String modelVersion;
  final String downloadSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'AI Model', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                children: [
                  _ModelPackageCard(
                    statusLabel: statusLabel,
                    statusColor: statusColor,
                    modelVersion: modelVersion,
                    downloadSize: downloadSize,
                  ),
                  const SizedBox(height: 16),
                  _ReadinessCard(
                    iconAsset: readinessIconAsset,
                    iconColor: readinessIconColor,
                    title: readinessTitle,
                    body: readinessBody,
                    background: readinessBackground,
                    child: readinessChild,
                  ),
                  const SizedBox(height: 16),
                  _OfflineAvailability(
                    generationAvailability: generationAvailability,
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: onPrimary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(primaryLabel),
                        const SizedBox(width: 12),
                        SvgPicture.asset(
                          'assets/icons/figma/arrow_right.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(color: secondaryBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelPackageCard extends StatelessWidget {
  const _ModelPackageCard({
    required this.statusLabel,
    required this.statusColor,
    required this.modelVersion,
    required this.downloadSize,
  });

  final String statusLabel;
  final Color statusColor;
  final String modelVersion;
  final String downloadSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(
                  'assets/icons/figma/cpu.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gemma 3 1B IT', style: AppTextStyles.screenTitle),
                    const SizedBox(height: 4),
                    Text('On-device AI model', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetadataRow(label: 'Model version', value: modelVersion),
          const SizedBox(height: 6),
          _MetadataRow(label: 'Download size', value: downloadSize),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 18 / 12,
            color: AppColors.muted,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({
    required this.iconAsset,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.background,
    this.child,
  });

  final String iconAsset;
  final Color iconColor;
  final String title;
  final String body;
  final Color background;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 130),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconAsset,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 20 / 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.muted.copyWith(height: 20 / 13)),
          if (child != null) ...[const SizedBox(height: 8), child!],
        ],
      ),
    );
  }
}

class _OfflineAvailability extends StatelessWidget {
  const _OfflineAvailability({required this.generationAvailability});

  final String generationAvailability;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What works offline',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 12),
        const _AvailabilityRow(
          iconAsset: 'assets/icons/figma/check.svg',
          title: 'Saved study material · Available offline',
          description:
              'Documents & extracted text, flashcards, quizzes, summaries and study progress.',
        ),
        const SizedBox(height: 12),
        _AvailabilityRow(
          iconAsset: 'assets/icons/figma/cpu.svg',
          title: 'New AI generation',
          description: generationAvailability,
        ),
        const SizedBox(height: 12),
        const _AvailabilityRow(
          iconAsset: 'assets/icons/figma/wifi.svg',
          title: 'Internet required',
          description: 'Model downloads, purchases and restoring purchases.',
        ),
      ],
    );
  }
}

class _AvailabilityRow extends StatelessWidget {
  const _AvailabilityRow({
    required this.iconAsset,
    required this.title,
    required this.description,
  });

  final String iconAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconAsset,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 18 / 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Download progress shown in the readiness card of the Downloading
/// frame (5:15129): label, percentage, and the progress track. The
/// defaults render the design's static 42%; the wired downloading
/// screen passes the download's live [fraction].
class ModelDownloadProgress extends StatelessWidget {
  const ModelDownloadProgress({super.key, this.fraction = 0.42});

  /// Download progress, 0.0–1.0.
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Model download', style: AppTextStyles.caption),
            Text(
              '${(fraction * 100).round()}%',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(100),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraction.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
