import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/layout/responsive_spacing.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../ai_generation/domain/generation_config.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/widgets/generation_source_card.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../../../model_management/presentation/providers/model_providers.dart';
import '../widgets/quiz_source_card.dart';

/// Quiz setup, implemented from the Figma frame
/// "SI Buddy · Quiz Setup" (5:5837): configure question count,
/// difficulty, question type, topics and an optional timer for the
/// source document. All controls work locally; the defaults match
/// the design (10 questions, Medium, Mixed, timer on, 10 minutes).
///
/// Generate is wired to the real generation pipeline, exactly like
/// the flashcards setup: it maps the chosen type/count/difficulty
/// onto the shared [GenerationConfig], checks the model and the
/// source document, starts a job and shows its progress. Mixed
/// generates MCQs (there is no mixed-question generation yet); the
/// timer setting is kept for the quiz session and is not part of
/// generation.
class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  static const _difficulties = ['Easy', 'Medium', 'Hard'];
  static const _types = ['MCQ', 'True/False', 'Short Answer', 'Mixed'];

  int _count = 10;
  String _difficulty = 'Medium';
  String _type = 'Mixed';
  bool _timerEnabled = true;

  @override
  void initState() {
    super.initState();
    // Probe the runtime once so the status line below reflects the
    // real model state instead of claiming a model is installed.
    Future.microtask(() => ref.read(modelProvider.notifier).refresh());
  }

  /// The Generate action: with a ready model and an extracted
  /// document, start a real quiz generation job and show its
  /// progress. Without them, route to the designed explainer for
  /// what is missing.
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
    final materialType = switch (_type) {
      'True/False' => GenerationMaterialType.trueFalse,
      'Short Answer' => GenerationMaterialType.shortAnswers,
      _ => GenerationMaterialType.mcqs,
    };
    final difficulty = switch (_difficulty) {
      'Easy' => GenerationDifficulty.easy,
      'Hard' => GenerationDifficulty.hard,
      _ => GenerationDifficulty.medium,
    };
    final configNotifier = ref.read(generationConfigProvider.notifier);
    configNotifier.setMaterialType(materialType);
    configNotifier.setDifficulty(difficulty);
    configNotifier.setCount(_count);
    configNotifier.setDocumentId(source.document.id);
    final config = ref.read(generationConfigProvider);
    ref.read(generationJobProvider.notifier).start(source: source, config: config);
    if (mounted) context.push(AppRoutes.generationProcessing);
  }

  @override
  Widget build(BuildContext context) {
    final extraction = ref.watch(extractionProvider);
    final source = extraction.result;
    final config = ref.watch(generationConfigProvider);
    final modelReady = ref.watch(modelProvider).isReady;
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Quiz setup', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: ResponsiveSpacing.page(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // The most recently extracted document, once
                    // one exists; an honest empty card until then —
                    // never the design's sample document.
                    QuizSourceCard(
                      title: source?.document.originalFileName,
                      subtitle: source == null
                          ? null
                          : generationSourceSubtitle(document: source.document, subject: extraction.subject),
                      formatLabel: source?.document.format.label,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question count',
                          style: AppTextStyles.body(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
                        ),
                        _CountStepper(
                          count: _count,
                          onDecrease: () => setState(() {
                            if (_count > 1) _count--;
                          }),
                          onIncrease: () => setState(() {
                            if (_count < 50) _count++;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionLabel('Difficulty'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 0; i < _difficulties.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _ChoiceChip(
                              label: _difficulties[i],
                              selected: _difficulty == _difficulties[i],
                              onTap: () => setState(() => _difficulty = _difficulties[i]),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionLabel('Question type'),
                    const SizedBox(height: 8),
                    for (var row = 0; row < 2; row++) ...[
                      if (row > 0) const SizedBox(height: 8),
                      Row(
                        children: [
                          for (var col = 0; col < 2; col++) ...[
                            if (col > 0) const SizedBox(width: 8),
                            Expanded(
                              child: _ChoiceChip(
                                label: _types[row * 2 + col],
                                selected: _type == _types[row * 2 + col],
                                onTap: () => setState(() => _type = _types[row * 2 + col]),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel('Topics'),
                        TextButton(
                          // TODO(backend): open the topic editor.
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Edit', style: AppTextStyles.link(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.appCard,
                        border: Border.all(color: context.appBorder),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              config.topic.isEmpty ? 'No topics set' : config.topic,
                              style: AppTextStyles.body(context).copyWith(fontSize: 12, height: 18 / 12),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/figma/chevron_down.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(context.appMuted, BlendMode.srcIn),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel('Optional timer'),
                              const SizedBox(height: 2),
                              Text(
                                _timerEnabled
                                    ? 'Enabled · Auto-submit at time limit'
                                    : 'Disabled · No time limit',
                                style: AppTextStyles.caption(context),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _timerEnabled,
                          onChanged: (value) => setState(() => _timerEnabled = value),
                          activeTrackColor: context.appPrimary,
                          inactiveTrackColor: context.appChip,
                          inactiveThumbColor: context.appCard,
                        ),
                      ],
                    ),
                    if (_timerEnabled) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.appBorder),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time limit',
                              style: AppTextStyles.body(
                                context,
                              ).copyWith(fontSize: 12, height: 18 / 12, color: context.appMuted),
                            ),
                            Text(
                              '10 minutes',
                              style: AppTextStyles.body(
                                context,
                              ).copyWith(fontSize: 13, fontWeight: FontWeight.w600, height: 18 / 13),
                            ),
                            SvgPicture.asset(
                              'assets/icons/figma/chevron_down.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(context.appMuted, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.appCard,
                border: Border(top: BorderSide(color: context.appBorder)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    modelReady
                        ? '● Model installed · AI ready offline'
                        : '● No model installed · Download the model to generate',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(
                      context,
                    ).copyWith(color: modelReady ? context.appSuccessText : context.appDanger),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(onPressed: _onGenerate, child: const Text('Generate Quiz')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 13px semibold section label used across the setup form.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600, height: 18 / 13),
    );
  }
}

/// Bordered minus / value / plus stepper for the question count.
class _CountStepper extends StatelessWidget {
  const _CountStepper({required this.count, required this.onDecrease, required this.onIncrease});

  final int count;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(asset: 'assets/icons/figma/minus.svg', onTap: onDecrease),
          SizedBox(
            width: 40,
            child: Text('$count', textAlign: TextAlign.center, style: AppTextStyles.title(context)),
          ),
          _StepButton(asset: 'assets/icons/figma/plus.svg', onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: 16,
            height: 16,
            colorFilter: ColorFilter.mode(context.appPrimary, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

/// 40px selection chip: white with a border when unselected, and
/// surface-selected with a primary border, check and label when
/// selected (per the Figma selection-option component).
class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.appSurface : context.appCard,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: selected ? context.appPrimary : context.appBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                SvgPicture.asset(
                  'assets/icons/figma/check.svg',
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(context.appPrimary, BlendMode.srcIn),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  height: selected ? 16 / 12 : 18 / 12,
                  color: selected ? context.appPrimary : context.appText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
