import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

// A Prime flow inside an app that is not a PrimeApp: the only PrimeTheme is local to the flow, below the Navigator.
// What the flow opens is built above that PrimeTheme, so it must carry the theme across.
Widget nonPrimeHost(Widget child) => WidgetsApp(
  color: const Color(0xFF000000),
  pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(settings: settings, pageBuilder: (context, _, _) => builder(context)),
  home: PrimeTheme(data: PrimeThemeData.dark(), child: child),
);

void main() {
  late BuildContext flowContext;
  final flow = Builder(
    builder: (context) {
      flowContext = context;
      return const SizedBox.expand();
    },
  );

  PrimeThemeData? themeOf(WidgetTester tester, Finder finder) => PrimeTheme.maybeOf(tester.element(finder));

  testWidgets('Dialog.show carries the caller\'s PrimeTheme into its overlay', (tester) async {
    await tester.pumpWidget(nonPrimeHost(flow));
    Dialog.show<void>(context: flowContext, title: const Text('Title'), child: const Text('Body'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(themeOf(tester, find.text('Body'))?.brightness, Brightness.dark);
  });

  testWidgets('Modal.show carries the caller\'s PrimeTheme into its route', (tester) async {
    await tester.pumpWidget(nonPrimeHost(flow));
    Modal.show<void>(context: flowContext, title: const Text('Title'), child: const Text('Body'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(themeOf(tester, find.text('Body'))?.brightness, Brightness.dark);
  });

  testWidgets('Takeover.show carries the caller\'s PrimeTheme into its route', (tester) async {
    await tester.pumpWidget(nonPrimeHost(flow));
    Takeover.show<void>(
      context: flowContext,
      builder: (_) => const Takeover(child: Text('Body')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(themeOf(tester, find.text('Body'))?.brightness, Brightness.dark);
  });

  testWidgets('Toast.show carries the caller\'s PrimeTheme into its overlay', (tester) async {
    await tester.pumpWidget(nonPrimeHost(flow));
    Toast.show(flowContext, message: 'Saved');
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(themeOf(tester, find.text('Saved'))?.brightness, Brightness.dark);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
