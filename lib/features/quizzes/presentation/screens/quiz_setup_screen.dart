import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/quiz_source_card.dart';

/// Quiz setup, implemented from the Figma frame
/// "SI Buddy · Quiz Setup" (5:5837): configure question count,
/// difficulty, question type, topics and an optional timer for the
/// source document. All controls work locally; the defaults match
/// the design (10 questions, Medium, Mixed, timer on, 10 minutes).
class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  static const _difficulties = ['Easy', 'Medium', 'Hard'];
  static const _types = ['MCQ', 'True/False', 'Short Answer', 'Mixed'];

  int _count = 10;
  String _difficulty = 'Medium';
  String _type = 'Mixed';
  bool _timerEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Quiz setup', onBack: () => context.pop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const QuizSourceCard(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question count',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                          ),
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
                              onTap: () => setState(
                                () => _difficulty = _difficulties[i],
                              ),
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
                                onTap: () => setState(
                                  () => _type = _types[row * 2 + col],
                                ),
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
                          child: Text('Edit', style: AppTextStyles.link),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Cell basics · Organelles · Membranes',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/figma/chevron_down.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.muted,
                              BlendMode.srcIn,
                            ),
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
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _timerEnabled,
                          onChanged: (value) =>
                              setState(() => _timerEnabled = value),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.chip,
                          inactiveThumbColor: AppColors.white,
                        ),
                      ],
                    ),
                    if (_timerEnabled) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Time limit',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              '10 minutes',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 18 / 13,
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/icons/figma/chevron_down.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                AppColors.muted,
                                BlendMode.srcIn,
                              ),
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
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '● Model installed · AI ready offline',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.successText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.mcq),
                    child: const Text('Generate Quiz'),
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

/// 13px semibold section label used across the setup form.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
      ),
    );
  }
}

/// Bordered minus / value / plus stepper for the question count.
class _CountStepper extends StatelessWidget {
  const _CountStepper({
    required this.count,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int count;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(asset: 'assets/icons/figma/minus.svg', onTap: onDecrease),
          SizedBox(
            width: 40,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: AppTextStyles.title,
            ),
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
        width: 44,
        height: 44,
        child: Center(
          child: SvgPicture.asset(
            asset,
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

/// 40px selection chip: white with a border when unselected, and
/// surface-selected with a primary border, check and label when
/// selected (per the Figma selection-option component).
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
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 40,
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
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  height: selected ? 16 / 12 : 18 / 12,
                  color: selected ? AppColors.primary : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
