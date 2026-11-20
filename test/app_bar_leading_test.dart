import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

Widget host(Widget child) => PrimeApp(home: Scaffold(body: child));

void main() {
  group('AppBar.automaticallyImplyLeading', () {
    Future<void> pushPage(WidgetTester tester, {required bool imply}) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        PrimeApp(
          navigatorKey: navigator,
          home: const Scaffold(body: Text('home')),
        ),
      );
      navigator.currentState!.push(
        PrimePageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('second'), automaticallyImplyLeading: imply),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows a back button on a poppable route by default', (tester) async {
      await pushPage(tester, imply: true);
      expect(find.byIcon(PrimeIcons.chevronLeft), findsOneWidget);
    });

    testWidgets('hides it when false', (tester) async {
      await pushPage(tester, imply: false);
      expect(find.text('second'), findsOneWidget);
      expect(find.byIcon(PrimeIcons.chevronLeft), findsNothing);
    });
  });
}
