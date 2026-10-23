import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// The 40×24 toggle from the Figma "SI Buddy / Toggle" component.
///
/// Off state (as designed): border-color track with radius 4 and a white
/// thumb on the left. On state fills the track with the primary color
/// and moves the thumb right.
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 3),
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
