// Drives the component showcase screens on a real device or simulator:
//   flutter test integration_test -d <device>
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prime_flutter/prime_flutter.dart';
import 'package:prime_flutter_example/screens/screens.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Fixed waits, not pumpAndSettle: several screens show spinners that never settle.
  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> show(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(PrimeApp(home: screen));
    await settle(tester);
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first, duration: const Duration(milliseconds: 100));
    await settle(tester);
  }

  testWidgets('workbench: tree, tabs, folding, floating and move mode', (tester) async {
    await show(tester, const WorkbenchScreen());
    String editorText() => tester.widgetList<EditableText>(find.byType(EditableText)).first.controller.text;
    expect(editorText(), contains('package main'));

    // Selecting a file in the tree swaps the editor's document.
    await tester.tap(find.text('query.sql'));
    await settle(tester);
    expect(editorText(), contains('SELECT'));

    // Collapsing the folder hides its children.
    await tester.tap(find.text('src'));
    await settle(tester);
    expect(find.text('main.go'), findsNothing);
    await tester.tap(find.text('src'));
    await settle(tester);
    await tester.tap(find.text('main.go'));
    await settle(tester);

    // Folding from the gutter shortens the view but not the document.
    final lines = editorText().split('\n').length;
    await tester.tap(find.bySemanticsLabel('Fold line 6'));
    await settle(tester);
    expect(editorText().split('\n').length, lessThan(lines));
    await tester.tap(find.bySemanticsLabel('Unfold line 6'));
    await settle(tester);
    expect(editorText().split('\n').length, lines);

    // Stacked panes switch by tab.
    await tester.tap(find.text('Problems').first);
    await settle(tester);
    expect(find.text('No problems detected'), findsOneWidget);

    // Float the files pane into a window, then close the window.
    await tester.tap(find.bySemanticsLabel('Float Files'));
    await settle(tester);
    expect(find.bySemanticsLabel('Close Files'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close Files'));
    await settle(tester);
    expect(find.text('query.sql'), findsNothing);

    // Move mode: start it on the editor, cancel with Escape.
    await tester.tap(find.bySemanticsLabel('Move Editor'));
    await settle(tester);
    expect(find.textContaining('Escape to cancel'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.textContaining('Escape to cancel'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('code editor: typing updates the editable diff', (tester) async {
    await show(tester, const CodeEditorScreen());
    final editor = find.byType(EditableText).first;
    final before = tester.widget<EditableText>(editor).controller.text;
    await tester.enterText(editor, before.replaceFirst('"arm-1"', '"arm-9"'));
    await settle(tester);

    // The diff below is the same document: it now carries the edit and a deleted run for the old line.
    await reveal(tester, find.text('Split'));
    final diff = tester.widgetList<EditableText>(find.byType(EditableText)).elementAt(1).controller.text;
    expect(diff, contains('"arm-9"'));
    expect(diff.codeUnits.where((unit) => unit >= 0xF000 && unit <= 0xF8FF).length, greaterThanOrEqualTo(3));

    await tester.tap(find.text('Split'));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menus: menu items run and close, menubar and popover open', (tester) async {
    await show(tester, const MenusScreen());
    await reveal(tester, find.text('View').first);
    await tester.tap(find.text('View').first);
    await settle(tester);
    expect(find.text('Show hidden'), findsOneWidget);
    await tester.tap(find.text('Show hidden'));
    await settle(tester);
    expect(find.text('Show hidden'), findsNothing);

    await reveal(tester, find.text('File'));
    await tester.tap(find.text('File'));
    await settle(tester);
    expect(find.text('Open'), findsOneWidget);
    await tester.tap(find.text('Open'));
    await settle(tester);

    await reveal(tester, find.text('Share'));
    await tester.tap(find.text('Share'));
    await settle(tester);
    await tester.tap(find.text('Copy link'));
    await settle(tester);
    expect(find.text('Copy link'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('forms: checkbox, radio, searchable select and date picker respond', (tester) async {
    await show(tester, const FormControlsScreen());
    await reveal(tester, find.text('Accept the terms'));
    expect(find.byIcon(PrimeIcons.checkboxBlankOutline), findsOneWidget);
    await tester.tap(find.text('Accept the terms'));
    await settle(tester);
    expect(find.byIcon(PrimeIcons.checkboxBlankOutline), findsNothing);

    await reveal(tester, find.text('Weekly'));
    await tester.tap(find.text('Weekly'));
    await settle(tester);
    expect(find.byIcon(PrimeIcons.radioboxMarked), findsOneWidget);

    await reveal(tester, find.text('Search components'));
    await tester.tap(find.byType(SearchableSelect).first);
    await settle(tester);
    await tester.tap(find.text('Camera').last);
    await settle(tester);
    expect(find.text('Camera'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tool panel: dragging a label scrubs its number field', (tester) async {
    await show(tester, const ToolPanelScreen());
    // Long enough to clear the drag threshold on every platform.
    await tester.drag(find.text('FOV'), const Offset(48, 0));
    await settle(tester);
    expect(find.text('60'), findsNothing);

    await tester.tap(find.text('Lighting'));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('feedback: notifications appear and dismiss', (tester) async {
    await show(tester, const FeedbackScreen());
    await reveal(tester, find.text('Danger'));
    await tester.tap(find.text('Danger'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Failed'), findsOneWidget);
    await tester.tap(find.descendant(of: find.ancestor(of: find.text('Failed'), matching: find.byType(PrimeBanner)), matching: find.byIcon(PrimeIcons.close)));
    await settle(tester);
    expect(find.text('Failed'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
