import 'package:flutter_test/flutter_test.dart';

import 'package:si_buddy/app/app.dart';

void main() {
  testWidgets('renders the SI Buddy splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('SI Buddy'), findsOneWidget);
    expect(find.text('Your notes. Your AI. Your exam prep.'), findsOneWidget);
  });
}
