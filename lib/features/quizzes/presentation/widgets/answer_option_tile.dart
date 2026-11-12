import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Selectable answer row from the quiz question screens (MCQ and
/// True/False). The selected row uses the surface-selected fill, a
/// primary border and marker, and a primary semibold label with a
/// check; unselected rows are white with a bordered letter marker.
class AnswerOptionTile extends StatelessWidget {
  const AnswerOptionTile({
    required this.marker,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  /// Marker letter shown in the 28px box, e.g. "A" or "T".
  final String marker;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.appSurface : context.appCard,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? context.appPrimary : context.appBorder,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? context.appPrimary : context.appCard,
                  border: Border.all(
                    color: selected ? context.appPrimary : context.appBorder,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: selected
                    ? SvgPicture.asset(
                        'assets/icons/figma/check.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          context.appCard,
                          BlendMode.srcIn,
                        ),
                      )
                    : Text(
                        marker,
                        style: AppTextStyles.body(context).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 16 / 12,
                          color: context.appTextSecondary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: selected
                      ? AppTextStyles.body(context).copyWith(
                          fontWeight: FontWeight.w600,
                          height: 20 / 14,
                          color: context.appPrimary,
                        )
                      : AppTextStyles.body(context).copyWith(height: 22 / 14),
                ),
              ),
              if (selected)
                SvgPicture.asset(
                  'assets/icons/figma/check.svg',
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    context.appPrimary,
                    BlendMode.srcIn,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
