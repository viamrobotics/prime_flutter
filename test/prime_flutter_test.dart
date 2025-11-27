import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

void main() {
  testWidgets('Badge renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const PrimeApp(
        home: PrimeScaffold(
          body: Badge(text: 'LIVE', variant: BadgeVariant.success),
        ),
      ),
    );

    expect(find.text('LIVE'), findsOneWidget);
  });

  testWidgets('Card renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const PrimeApp(
        home: PrimeScaffold(
          body: Card(title: 'Test Card', subtitle: 'Subtitle'),
        ),
      ),
    );

    expect(find.text('Test Card'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
  });
}
