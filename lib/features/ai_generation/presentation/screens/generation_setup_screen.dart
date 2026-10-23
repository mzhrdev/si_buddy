import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../domain/generation_config.dart';
import '../providers/generation_providers.dart';
import '../widgets/generation_source_card.dart';

/// Generation setup, implemented from the Figma frame
/// "SI Buddy · Generation setup" (5:497): choose the material type,
/// count and difficulty for the source document, with topic, language
/// and explanation options. The controls read and write the shared
/// [GenerationConfig] held by `generationConfigProvider`; its
/// defaults match the design (Flashcards, 20, Medium, explanations
/// on).
class GenerationSetupScreen extends ConsumerStatefulWidget {
  const GenerationSetupScreen({super.key});

  @override
  ConsumerState<GenerationSetupScreen> createState() =>
      _GenerationSetupScreenState();
}

class _GenerationSetupScreenState extends ConsumerState<GenerationSetupScreen> {
  /// The Generate action: with a ready model and an extracted
  /// document, start a real generation job and show its progress.
  /// Without them, route to the designed explainer for what is
  /// missing — the missing-model screen when no model is ready, the
  /// insufficient-text screen when there is no extracted text to
  /// generate from. Progress and results are never faked.
  Future<void> _onGenerate() async {
    final repository = ref.read(boundGenerationRepositoryProvider);
    if (repository == null || !await repository.isModelReady()) {
      if (mounted) context.push(AppRoutes.missingModel);
      return;
    }
    final source = ref.read(extractionProvider).result;
    if (source == null || !source.hasText) {
      if (mounted) context.push(AppRoutes.insufficientText);
      return;
    }
    ref
        .read(generationConfigProvider.notifier)
        .setDocumentId(source.document.id);
    final config = ref.read(generationConfigProvider);
    ref
        .read(generationJobProvider.notifier)
        .start(source: source, config: config);
    if (mounted) context.push(AppRoutes.generationProcessing);
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(generationConfigProvider);
    final notifier = ref.read(generationConfigProvider.notifier);
    final extraction = ref.watch(extractionProvider);
    final source = extraction.result;
    const materialTypes = GenerationMaterialType.values;
    const difficulties = GenerationDifficulty.values;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Generation setup', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The most recently extracted document, once
                    // one exists; the design's sample until then.
                    GenerationSourceCard(
                      title:
                          source?.document.originalFileName ??
                          'Cell Biology - Chapter 4.pdf',
                      subtitle: source == null
                          ? 'Biology · 2.4 MB · 12 pages'
                          : generationSourceSubtitle(
                              document: source.document,
                              subject: extraction.subject,
                            ),
                      formatLabel: source?.document.format.label ?? 'PDF',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'What would you like to create?',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 0; i < 3; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _ChoiceChip(
                              label: materialTypes[i].label,
                              selected: config.materialType == materialTypes[i],
                              onTap: () =>
                                  notifier.setMaterialType(materialTypes[i]),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 3; i < 5; i++) ...[
                          if (i > 3) const SizedBox(width: 8),
                          Expanded(
                            child: _ChoiceChip(
                              label: materialTypes[i].label,
                              selected: config.materialType == materialTypes[i],
                              onTap: () =>
                                  notifier.setMaterialType(materialTypes[i]),
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Count',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Cards / questions',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StepperButton(
                                iconAsset: 'assets/icons/figma/minus.svg',
                                onTap: notifier.decrementCount,
                              ),
                              SizedBox(
                                width: 44,
                                child: Text(
                                  '${config.count}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.title,
                                ),
                              ),
                              _StepperButton(
                                iconAsset: 'assets/icons/figma/plus.svg',
                                onTap: notifier.incrementCount,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Difficulty', style: AppTextStyles.itemTitle),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        for (var i = 0; i < difficulties.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _ChoiceChip(
                              label: difficulties[i].label,
                              selected: config.difficulty == difficulties[i],
                              onTap: () =>
                                  notifier.setDifficulty(difficulties[i]),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _SelectionField(
                            label: 'Topic',
                            value: config.topic,
                            onTap: () {
                              // TODO(backend): open the topic picker.
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SelectionField(
                            label: 'Language',
                            value: config.language,
                            onTap: () {
                              // TODO(backend): open the language picker.
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Include explanations',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 20 / 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add context to each answer',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          _Toggle(
                            value: config.includeExplanations,
                            onChanged: notifier.setIncludeExplanations,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/figma/info.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.navInactive,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'For summaries, choose content length instead of count and difficulty.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/figma/ready_indicator.svg',
                        width: 6,
                        height: 6,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Model installed · AI ready offline',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.successText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _onGenerate,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Generate flashcards'),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One selectable option in the material-type and difficulty rows:
/// white with a border when idle, surface-selected with a primary
/// border, check and primary label when selected.
class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surface : AppColors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                SvgPicture.asset(
                  'assets/icons/figma/check.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 16 / 12,
                    color: selected ? AppColors.primary : AppColors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One half of the count stepper (44×44 minus / plus button).
class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.iconAsset, required this.onTap});

  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: SvgPicture.asset(
            iconAsset,
            width: 16,
            height: 16,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled dropdown-look field (topic, language): 13px semibold
/// label above a 44px bordered value box with a chevron.
class _SelectionField extends StatelessWidget {
  const _SelectionField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.itemTitle),
        const SizedBox(height: 7),
        Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.muted.copyWith(
                        color: AppColors.text,
                        height: 20 / 13,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/figma/chevron_down.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.navInactive,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The 46×28 pill switch used for "Include explanations".
class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.chip,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
