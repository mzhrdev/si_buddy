import 'package:flutter/material.dart';

/// Responsive values used by screens and shared chrome.
///
/// The scale is based on the available width rather than the device pixel
/// ratio, so the same layout remains usable on phones, tablets and split
/// screens. Values are clamped to keep touch targets and readable gutters
/// usable at the smallest sizes.
abstract final class ResponsiveSpacing {
  static double scale(BuildContext context, double value) {
    final width = MediaQuery.sizeOf(context).width;
    final factor = (width / 390).clamp(.82, 1.18);
    return value * factor;
  }

  static double horizontal(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return (width * .0615).clamp(16, 32);
  }

  static EdgeInsets page(
    BuildContext context, {
    double top = 12,
    double bottom = 24,
  }) {
    final horizontal = ResponsiveSpacing.horizontal(context);
    return EdgeInsets.fromLTRB(
      horizontal,
      scale(context, top),
      horizontal,
      scale(context, bottom),
    );
  }

  static SizedBox gap(BuildContext context, double value) {
    return SizedBox(height: scale(context, value));
  }

  static SizedBox gapHorizontal(BuildContext context, double value) {
    return SizedBox(width: scale(context, value));
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    this.maxWidth = 720,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
