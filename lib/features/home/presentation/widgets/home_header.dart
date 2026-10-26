import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_text_styles.dart';

/// Dashboard header: greeting + headline on the left, the Buddy brand
/// mark on the right.
class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.greeting, super.key});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTextStyles.greeting),
              const SizedBox(height: 4),
              const Text("Let's make it stick.", style: AppTextStyles.display),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SvgPicture.asset(
          'assets/icons/figma/brand_mark.svg',
          width: 48,
          height: 48,
        ),
      ],
    );
  }
}
