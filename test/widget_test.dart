import 'package:flutter_test/flutter_test.dart';
import 'package:fade_finder/main.dart';

void main() {
  testWidgets('app launches smoke test', (WidgetTester tester) async {
    // verify root application initializes cleanly
    await tester.pumpWidget(const FadeFinderApp());
    expect(find.byType(FadeFinderApp), findsOneWidget);
  });
}