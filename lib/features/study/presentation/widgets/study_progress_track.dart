import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Slim 5px progress track used across the Study screens: a
/// surface-selected track with a primary filled portion, both fully
/// rounded (radius 100).
class StudyProgressTrack extends StatelessWidget {
  const StudyProgressTrack({required this.fraction, super.key});

  /// Filled portion of the track, from 0 to 1.
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 5,
        color: AppColors.surface,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fraction.clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
