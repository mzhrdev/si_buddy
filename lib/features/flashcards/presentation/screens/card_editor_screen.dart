import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../ai_generation/presentation/providers/generation_providers.dart';
import '../../../ai_generation/presentation/providers/study_session_providers.dart';
import '../../../ai_generation/presentation/widgets/generation_source_card.dart';
import '../../../documents/presentation/providers/documents_providers.dart';
import '../widgets/source_document_card.dart';

/// Card editor, implemented from the Figma frame
/// "SI Buddy · Card Editor" (5:2702).
///
/// Edits the current card of this session's generated deck (the
/// card the study flow is on). Without a deck it shows an honest
/// empty state — never the design's sample card. Save updates the
/// card in the session result; nothing is persisted yet, so the edit
/// resets when the app restarts.
class CardEditorScreen extends ConsumerStatefulWidget {
  const CardEditorScreen({super.key});

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  int _index = 0;
  String? _explanation;

  @override
  void initState() {
    super.initState();
    final cards =
        ref.read(lastGenerationResultProvider)?.flashcards ?? const [];
    _index = cards.isEmpty
        ? 0
        : ref.read(studyCardIndexProvider).clamp(0, cards.length - 1);
    final card = cards.isEmpty ? null : cards[_index];
    _questionController = TextEditingController(text: card?.front ?? '');
    _answerController = TextEditingController(text: card?.back ?? '');
    _explanation = card?.explanation;
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

  void _save() {
    ref
        .read(generationJobProvider.notifier)
        .updateFlashcard(
          _index,
          _questionController.text,
          _answerController.text,
        );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cards =
        ref.watch(lastGenerationResultProvider)?.flashcards ?? const [];
    if (cards.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'Edit card', onBack: () => context.pop()),
              Expanded(
                child: EmptyState(
                  icon: Icons.style_outlined,
                  title: 'No cards to edit',
                  message:
                      'Generate flashcards from a document to edit them here.',
                  actionLabel: 'Generate flashcards',
                  onAction: () => context.push(AppRoutes.generationSetup),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final config = ref.watch(generationConfigProvider);
    final job = ref.watch(generationJobProvider);
    final source = job.source;
    // The controllers were bound to _index in initState; the counter
    // shows that same card.
    final index = _index.clamp(0, cards.length - 1);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'Edit card', onBack: () => context.pop()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              generatedMaterialTitle(
                                config: config,
                                documentName:
                                    source?.document.originalFileName,
                              ),
                              style: AppTextStyles.screenTitle(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Card ${index + 1} of ${cards.length} · Flashcards',
                              style: AppTextStyles.body(context).copyWith(
                                fontSize: 12,
                                height: 18 / 12,
                                color: context.appMuted,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SourceDocumentCard(
                              title: source?.document.originalFileName,
                              subtitle: source == null
                                  ? null
                                  : generationSourceSubtitle(
                                      document: source.document,
                                      subject: ref
                                          .watch(extractionProvider)
                                          .subject,
                                    ),
                              formatLabel: source?.document.format.label,
                            ),
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
                            if (_explanation != null &&
                                _explanation!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Explanation: $_explanation',
                                style: AppTextStyles.caption(context),
                              ),
                            ],
                            const SizedBox(height: 18),
                            Text(
                              'Changes apply to this card only. Your original document stays unchanged.',
                              style: AppTextStyles.caption(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _save,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Save'),
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
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.appBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.body(context).copyWith(
                            fontWeight: FontWeight.w600,
                            height: 20 / 14,
                            color: context.appPrimary,
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
          style: AppTextStyles.body(context).copyWith(
            fontWeight: FontWeight.w600,
            height: 20 / 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: context.appBorder),
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
                  style: AppTextStyles.body(context).copyWith(height: 22 / 14),
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
                  style: AppTextStyles.badge(context).copyWith(color: context.appMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
