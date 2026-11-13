import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';

/// Shared layout for the AI service screen: the service package
/// card (identity, connection status, AI model metadata), the
/// status card, the "What works offline" availability list, and the
/// pinned primary/secondary actions.
///
/// There is no model download anymore: generation runs through the
/// app's backend proxy (Groq, via the app's own proxy), so the
/// screen reports whether the service is configured and answers,
/// and offers to delete a legacy downloaded model file.
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
    this.readinessBackground,
    this.readinessChild,
    this.secondaryColor,
    this.secondaryBorderColor,
    this.modelVersion = 'To be confirmed',
    super.key,
  });

  final String statusLabel;
  final Color statusColor;
  final String readinessIconAsset;
  final Color readinessIconColor;
  final String readinessTitle;
  final String readinessBody;

  /// Null reads as the card color.
  final Color? readinessBackground;

  /// Optional extra content under the readiness body.
  final Widget? readinessChild;

  /// Description for the "New AI generation" availability row.
  final String generationAvailability;

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  /// Null reads as the primary color.
  final Color? secondaryColor;

  /// Null reads as the border color.
  final Color? secondaryBorderColor;

  /// Package card metadata. Defaults keep the design's placeholder;
  /// the wired screen passes the real service's values.
  final String modelVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'AI Model', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  _ModelPackageCard(
                    statusLabel: statusLabel,
                    statusColor: statusColor,
                    modelVersion: modelVersion,
                  ),
                  const SizedBox(height: 16),
                  _ReadinessCard(
                    iconAsset: readinessIconAsset,
                    iconColor: readinessIconColor,
                    title: readinessTitle,
                    body: readinessBody,
                    background: readinessBackground ?? context.appCard,
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
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.appBorder)),
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
                          colorFilter: ColorFilter.mode(
                            context.appCard,
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
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: secondaryBorderColor ?? context.appBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: AppTextStyles.body(context).copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                        color: secondaryColor ?? context.appPrimary,
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
  });

  final String statusLabel;
  final Color statusColor;
  final String modelVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appCard,
        border: Border.all(color: context.appBorder),
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
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SvgPicture.asset(
                  'assets/icons/figma/cpu.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    context.appPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Groq AI Service',
                      style: AppTextStyles.screenTitle(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Online AI generation',
                      style: AppTextStyles.caption(context),
                    ),
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
          _MetadataRow(label: 'AI model', value: modelVersion),
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
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 18 / 12,
            color: context.appMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
            color: context.appText,
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
                  style: AppTextStyles.body(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.muted(context).copyWith(height: 20 / 13),
          ),
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
          style: AppTextStyles.body(
            context,
          ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
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
          description: 'AI generation, purchases and restoring purchases.',
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
          colorFilter: ColorFilter.mode(context.appPrimary, BlendMode.srcIn),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 16 / 12,
                  color: context.appText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 18 / 12,
                  color: context.appMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
