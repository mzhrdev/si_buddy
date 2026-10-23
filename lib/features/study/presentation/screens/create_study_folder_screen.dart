import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Create Study Folder dialog, implemented from the Figma frame
/// "SI Buddy · Create Study Folder" (5:11436). In Figma the dialog
/// overlays the Study Library; here it is a dimmed scaffold with a
/// centered white card holding the folder name field, the subject
/// selector, and the Cancel / Create actions.
class CreateStudyFolderScreen extends StatefulWidget {
  const CreateStudyFolderScreen({super.key});

  @override
  State<CreateStudyFolderScreen> createState() =>
      _CreateStudyFolderScreenState();
}

class _CreateStudyFolderScreenState extends State<CreateStudyFolderScreen> {
  final _nameController = TextEditingController(text: 'Exam revision');
  String _subject = 'Biology';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x99172033), // Figma: color/overlay
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create study folder',
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Keep related study materials together.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 20 / 13,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Folder name', style: _labelStyle),
                const SizedBox(height: 7),
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _nameController,
                    style: AppTextStyles.body,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      enabledBorder: _fieldBorder(AppColors.primary),
                      focusedBorder: _fieldBorder(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Subject', style: _labelStyle),
                const SizedBox(height: 7),
                Builder(
                  builder: (selectorContext) => InkWell(
                    onTap: () => _pickSubject(selectorContext),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _subject,
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
                const SizedBox(height: 7),
                Text(
                  'New study items in this folder use $_subject by default.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.pop(),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        // TODO(backend): create the folder, then pop.
                        onPressed: () => context.pop(),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickSubject(BuildContext selectorContext) async {
    final box = selectorContext.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(selectorContext).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final value = await showMenu<String>(
      context: selectorContext,
      position: position,
      initialValue: _subject,
      items: const [
        PopupMenuItem<String>(value: 'Biology', child: Text('Biology')),
      ],
    );
    if (value != null) setState(() => _subject = value);
  }

  static OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide(color: color),
  );
}

/// Field labels in the dialog (12, SemiBold, lh 16).
const _labelStyle = TextStyle(
  fontFamily: 'Inter',
  fontSize: 12,
  fontWeight: FontWeight.w600,
  height: 16 / 12,
  color: AppColors.text,
);
