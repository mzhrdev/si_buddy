import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// The 40×24 toggle from the Figma "SI Buddy / Toggle" component.
///
/// Off state (as designed): border-color track with radius 4 and a white
/// thumb on the left. On state fills the track with the primary color
/// and moves the thumb right.
///
/// The visual stays 40×24, but the hit area is 48×48 (the Android
/// touch-target minimum) and the control announces its [label] and
/// on/off state to screen readers — the bare 40×24 switch was too
/// small to tap reliably and invisible to assistive technology.
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Accessible name, e.g. the preference row's title.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      toggled: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: value ? context.appPrimary : context.appBorder,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: context.appCard,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
