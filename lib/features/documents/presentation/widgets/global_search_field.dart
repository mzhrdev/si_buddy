import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// The 46px global search field shared by the library and search screens.
///
/// In display mode ([controller] null) it renders the [hintText] as muted
/// placeholder copy and reports taps through [onTap]. In edit mode it hosts
/// a real [TextField] bound to [controller], with the design's primary
/// border and a clear (x) button shown while text is present.
class GlobalSearchField extends StatefulWidget {
  const GlobalSearchField({
    this.controller,
    this.hintText,
    this.focused = false,
    this.onTap,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final String? hintText;

  /// Whether to use the primary (focused) border instead of the default.
  final bool focused;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  State<GlobalSearchField> createState() => _GlobalSearchFieldState();
}

class _GlobalSearchFieldState extends State<GlobalSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final editing = controller != null;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: editing ? null : widget.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.focused ? AppColors.primary : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/figma/search.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.navInactive,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: editing
                    ? TextField(
                        controller: controller,
                        onChanged: widget.onChanged,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          height: 20 / 13,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      )
                    : Text(
                        widget.hintText ?? '',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          height: 20 / 13,
                          color: AppColors.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              if (editing && controller.text.isNotEmpty)
                InkWell(
                  onTap: () {
                    controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: SvgPicture.asset(
                    'assets/icons/figma/x.svg',
                    width: 17,
                    height: 17,
                    colorFilter: const ColorFilter.mode(
                      AppColors.navInactive,
                      BlendMode.srcIn,
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
