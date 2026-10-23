import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/source_document_card.dart';

/// Card editor, implemented from the Figma frame
/// "SI Buddy · Card Editor" (5:2702).
class CardEditorScreen extends StatefulWidget {
  const CardEditorScreen({super.key});

  @override
  State<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends State<CardEditorScreen> {
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: 'What is the basic unit of life?',
    );
    _answerController = TextEditingController(
      text:
          'The cell.\n\nEach cell contains structures that work together to support its functions.',
    );
    _questionController.addListener(_refresh);
    _answerController.addListener(_refresh);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Edit card', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cell structures',
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Card 4 of 20 · Flashcards',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const SourceDocumentCard(),
                            const SizedBox(height: 18),
                            _EditableField(
                              label: 'Question',
                              controller: _questionController,
                              height: 110,
                            ),
                            const SizedBox(height: 18),
                            _EditableField(
                              label: 'Answer',
                              controller: _answerController,
                              height: 180,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Source: page 1 · Changes apply to this card only. Your original document stays unchanged.',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      // TODO(backend): save the edited card.
                      onPressed: () => context.pop(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Save'),
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
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One labelled editable field: a bordered text input with the live
/// character count in its footer, as in the design.
class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.height,
  });

  final String label;
  final TextEditingController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTextStyles.body.copyWith(height: 22 / 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${controller.text.length} characters',
                  style: AppTextStyles.badge.copyWith(color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
