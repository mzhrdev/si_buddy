import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_buddy/core/widgets/app_header.dart';
import 'package:si_buddy/features/settings/presentation/widgets/settings_toggle.dart';
import 'package:si_buddy/features/study/presentation/widgets/study_destinations_bar.dart';

/// Phase 7 locks in the touch-target and accessibility fixes:
/// toggles keep their Figma visuals but expose a 48×48 hit area
/// with a spoken label and state, the Study destinations bar is
/// 48 tall, and the header back button is 48×48 with a tooltip.
void main() {
  group('SettingsToggle', () {
    testWidgets('has a 48x48 hit area and announces label and state', (
      tester,
    ) async {
      var value = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsToggle(
              value: value,
              onChanged: (v) => value = v,
              label: 'Daily study reminder',
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(SettingsToggle)), const Size(48, 48));
      expect(find.bySemanticsLabel('Daily study reminder'), findsOneWidget);

      await tester.tap(find.byType(SettingsToggle));
      expect(value, isTrue);
    });
  });

  group('StudyDestinationsBar', () {
    testWidgets('is 48 tall and marks the current destination selected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: StudyDestinationsBar(currentIndex: 0)),
        ),
      );

      expect(tester.getSize(find.byType(StudyDestinationsBar)).height, 48);
      final semantics = tester.getSemantics(find.text('Statistics'));
      expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
    });
  });

  group('AppHeader', () {
    testWidgets('back button is 48x48 with a Back tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(title: 'Storage', onBack: () {}),
          ),
        ),
      );

      expect(find.byTooltip('Back'), findsOneWidget);
      expect(tester.getSize(find.byType(IconButton)), const Size(48, 48));
    });
  });
}
