import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';

/// A tappable primary-colored entry row (label + chevron) linking to
/// another subscription screen, e.g. "Restore Purchases".
class SubscriptionEntryRow extends StatelessWidget {
  const SubscriptionEntryRow({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 18 / 13,
                  color: context.appPrimary,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/figma/chevron_right.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                context.appPrimary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
