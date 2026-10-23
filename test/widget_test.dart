import 'package:flutter_test/flutter_test.dart';

import 'package:si_buddy/app/app.dart';

void main() {
  testWidgets('renders the SI Buddy splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Splash'), findsNWidgets(2));
    expect(find.textContaining('Onboarding'), findsNWidgets(2));
  });
}
