// The test suites of the TypeScript Prime library (`prime-core`), translated
// to Flutter. Each group is named after the spec file it comes from and each
// test after the case or cases it covers.
//
// Cases with no meaning outside a browser are left out: "renders with the
// passed cx classes" (there are no CSS classes), ARIA attribute and element-id
// wiring, binding the underlying DOM element, password-manager attributes,
// body scroll locking, and the `unique-id`, `use-timeout`, `prevent-handler`
// and `in-viewport` helpers, which have no Flutter counterpart to test.
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

Widget host(Widget child) => PrimeApp(
  home: Scaffold(
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child),
  ),
);

Color? textColorOf(WidgetTester tester, String text) =>
    tester.widget<DefaultTextStyle>(find.ancestor(of: find.text(text), matching: find.byType(DefaultTextStyle)).first).style.color;

BoxDecoration decorationOf(WidgetTester tester, Finder within) {
  final container = tester
      .widgetList<Container>(find.descendant(of: within, matching: find.byType(Container)))
      .firstWhere((container) => container.decoration is BoxDecoration && (container.decoration! as BoxDecoration).color != null);
  return container.decoration! as BoxDecoration;
}

Future<void> pressEscape(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  await tester.pumpAndSettle();
}

void main() {
  final scheme = PrimeColorScheme.light();

  group('ag-grid-table.spec', () {
    testWidgets('each header is visible; renders headers without row data', (tester) async {
      await tester.pumpWidget(
        host(
          const AGGridTable<Map<String, Object?>>(
            height: 200,
            columnDefs: [
              ColDef(field: 'id', headerName: 'ID'),
              ColDef(field: 'name', headerName: 'First name'),
              ColDef(field: 'ip', headerName: 'IP address'),
            ],
            rowData: [],
          ),
        ),
      );
      for (final header in ['ID', 'First name', 'IP address']) {
        expect(find.text(header), findsOneWidget);
      }
    });
  });

  group('breadcrumbs.spec', () {
    testWidgets('renders the list of values specified in crumbs', (tester) async {
      await tester.pumpWidget(host(const Breadcrumbs(crumbs: ['Chocolate Chip', 'Oatmeal Raisin'])));
      expect(find.text('Chocolate Chip'), findsOneWidget);
      expect(find.text('Oatmeal Raisin'), findsOneWidget);
      // One separator between two crumbs.
      expect(find.byIcon(PrimeIcons.chevronRight), findsOneWidget);
    });
  });

  group('click-outside.spec', () {
    Future<List<String>> pump(WidgetTester tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(
          Column(
            children: [
              Floating(
                visible: true,
                onTapOutside: () => log.add('outside'),
                floatingBuilder: (context) => const SizedBox(width: 120, height: 60, child: Text('Popup')),
                child: const SizedBox(width: 120, height: 40, child: Text('Anchor')),
              ),
              const SizedBox(height: 300),
              const SizedBox(width: 120, height: 40, child: Text('Elsewhere')),
            ],
          ),
        ),
      );
      await tester.pump();
      return log;
    }

    testWidgets('triggers a callback only when clicked outside', (tester) async {
      final log = await pump(tester);
      await tester.tap(find.text('Anchor'));
      await tester.tap(find.text('Popup'));
      expect(log, isEmpty);
      await tester.tap(find.text('Elsewhere'));
      expect(log, ['outside']);
    });

    testWidgets('does not trigger if the press starts inside and moves out', (tester) async {
      final log = await pump(tester);
      final gesture = await tester.startGesture(tester.getCenter(find.text('Popup')));
      await gesture.moveTo(tester.getCenter(find.text('Elsewhere')));
      await gesture.up();
      expect(log, isEmpty);
    });
  });

  group('code-snippet.spec', () {
    testWidgets('renders the code; with and without the copy button; with a caption', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              CodeSnippet(code: '{ "a": 1 }', language: CodeEditorLanguage.json, caption: Text('This text captions the code snippet.')),
              CodeSnippet(code: 'no button', showCopyButton: false),
            ],
          ),
        ),
      );
      expect(find.textContaining('"a"', findRichText: true), findsOneWidget);
      expect(find.text('This text captions the code snippet.'), findsOneWidget);
      expect(find.byIcon(PrimeIcons.contentCopy), findsOneWidget);
    });

    testWidgets('re-renders the code block when the code changes', (tester) async {
      await tester.pumpWidget(host(const CodeSnippet(code: 'first')));
      expect(find.textContaining('first', findRichText: true), findsOneWidget);
      await tester.pumpWidget(host(const CodeSnippet(code: 'second')));
      expect(find.textContaining('first', findRichText: true), findsNothing);
      expect(find.textContaining('second', findRichText: true), findsOneWidget);
    });

    testWidgets('copies to the clipboard and reports it', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
        return null;
      });
      final reports = <bool>[];
      await tester.pumpWidget(host(CodeSnippet(code: 'copy me', onCopy: (succeeded, message) => reports.add(succeeded))));
      await tester.tap(find.byIcon(PrimeIcons.contentCopy));
      await tester.pump();
      expect(copied, 'copy me');
      expect(reports, [true]);
      expect(find.byIcon(PrimeIcons.check), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.byIcon(PrimeIcons.contentCopy), findsOneWidget);
    });
  });

  group('dialog.spec', () {
    Widget app(void Function(Object?) onResult) => PrimeApp(
      home: Builder(
        builder: (context) => Button(
          label: const Text('Open'),
          onPressed: () async => onResult(
            await Dialog.show<String>(
              context: context,
              title: const Text('My Dialog'),
              child: const Text('Dialog content'),
              actions: const [
                DialogAction(label: Text('Cancel'), value: 'cancel'),
                DialogAction(label: Text('OK'), value: 'ok', variant: ButtonVariant.primary),
              ],
              showCloseButton: true,
            ),
          ),
        ),
      ),
    );

    testWidgets('not rendered until opened; renders title, content and footer when open', (tester) async {
      await tester.pumpWidget(app((_) {}));
      expect(find.text('My Dialog'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pump();
      expect(find.text('My Dialog'), findsOneWidget);
      expect(find.text('Dialog content'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      // Let the button's press feedback finish.
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('closes from the close button and from a footer action', (tester) async {
      final results = <Object?>[];
      await tester.pumpWidget(app(results.add));
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.tap(find.byIcon(PrimeIcons.close));
      await tester.pump();
      expect(find.text('My Dialog'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(results, [null, 'ok']);
    });
  });

  group('expandable.spec', () {
    testWidgets('renders closed by default, renders open, and toggles on click', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: [
              Expandable(triggerBuilder: (context, isOpen) => Text(isOpen ? 'A open' : 'A closed'), content: const Text('A content')),
              Expandable(
                initiallyOpen: true,
                triggerBuilder: (context, isOpen) => Text(isOpen ? 'B open' : 'B closed'),
                content: const Text('B content'),
              ),
            ],
          ),
        ),
      );
      double heightOf(String text) =>
          tester.getSize(find.ancestor(of: find.text(text), matching: find.byType(SizeTransition)).first).height;
      expect(heightOf('A content'), 0);
      expect(heightOf('B content'), greaterThan(0));
      await tester.tap(find.text('A closed'));
      await tester.pumpAndSettle();
      expect(find.text('A open'), findsOneWidget);
      expect(heightOf('A content'), greaterThan(0));
      await tester.tap(find.text('A open'));
      await tester.pumpAndSettle();
      expect(heightOf('A content'), 0);
    });
  });

  group('modal.spec', () {
    Widget app() => PrimeApp(
      home: Builder(
        builder: (context) => Button(
          label: const Text('Open'),
          onPressed: () =>
              Modal.show<void>(context: context, title: const Text('This is the modal demo'), message: const Text('Are you sure?')),
        ),
      ),
    );

    Future<void> open(WidgetTester tester) async {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('not visible until opened; visible with its name and description', (tester) async {
      await tester.pumpWidget(app());
      expect(find.text('This is the modal demo'), findsNothing);
      await open(tester);
      expect(find.text('This is the modal demo'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('closes from the close icon, from a click outside, and on Escape', (tester) async {
      await tester.pumpWidget(app());
      await open(tester);
      await tester.tap(find.byIcon(PrimeIcons.close));
      await tester.pumpAndSettle();
      expect(find.text('This is the modal demo'), findsNothing);

      await open(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('This is the modal demo'), findsNothing);

      await open(tester);
      await pressEscape(tester);
      expect(find.text('This is the modal demo'), findsNothing);
    });

    testWidgets('Escape does nothing once the modal is closed', (tester) async {
      await tester.pumpWidget(app());
      await pressEscape(tester);
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('navigation-breadcrumb.spec', () {
    testWidgets('renders the complete structure: links, separators, ellipsis and the current page', (tester) async {
      final visited = <String>[];
      await tester.pumpWidget(
        host(
          NavigationBreadcrumb(
            children: [
              NavigationBreadcrumbLink(onTap: () => visited.add('home'), child: const Text('Home')),
              const NavigationBreadcrumbSeparator(),
              const NavigationBreadcrumbEllipsis(),
              const NavigationBreadcrumbSeparator(child: Text('/')),
              NavigationBreadcrumbLink(child: const Text('No link')),
              const NavigationBreadcrumbSeparator(),
              const NavigationBreadcrumbPage(child: Text('Current Page')),
            ],
          ),
        ),
      );
      // Default chevron, custom separator content, default dots.
      expect(find.byIcon(PrimeIcons.chevronRight), findsNWidgets(2));
      expect(find.text('/'), findsOneWidget);
      expect(find.byIcon(PrimeIcons.dotsHorizontal), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.tap(find.text('No link'));
      await tester.tap(find.text('Current Page'));
      expect(visited, ['home']);
      // The current page is drawn in the primary text color; links are muted.
      expect(
        tester
            .widget<DefaultTextStyle>(find.ancestor(of: find.text('Current Page'), matching: find.byType(DefaultTextStyle)).first)
            .style
            .color,
        scheme.textPrimary,
      );
    });
  });

  group('pill.spec', () {
    testWidgets('renders its text, removable by default, and reports removal', (tester) async {
      final removed = <String>[];
      await tester.pumpWidget(host(Pill(value: 'Chocolate chip', onRemove: removed.add)));
      expect(find.text('Chocolate chip'), findsOneWidget);
      await tester.tap(find.byIcon(PrimeIcons.close));
      expect(removed, ['Chocolate chip']);
    });

    testWidgets('readonly has no remove button; disabled keeps it but ignores clicks', (tester) async {
      final removed = <String>[];
      await tester.pumpWidget(
        host(
          Column(
            children: [
              Pill(value: 'read', readOnly: true, onRemove: removed.add),
              Pill(value: 'off', disabled: true, onRemove: removed.add),
              Pill(value: 'fixed', removable: false, onRemove: removed.add),
            ],
          ),
        ),
      );
      expect(find.byIcon(PrimeIcons.close), findsOneWidget);
      await tester.tap(find.byIcon(PrimeIcons.close));
      expect(removed, isEmpty);
    });

    testWidgets('acts as a link when given a tap handler; shows its icon tooltip on hover', (tester) async {
      int opened = 0;
      await tester.pumpWidget(host(Pill(value: 'camera', icon: PrimeIcons.cameraOutline, iconTooltip: 'Component', onTap: () => opened++)));
      await tester.tap(find.text('camera'));
      expect(opened, 1);
      expect(find.text('Component'), findsNothing);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byIcon(PrimeIcons.cameraOutline)));
      await tester.pump();
      await tester.pump();
      expect(find.text('Component'), findsOneWidget);
      await mouse.removePointer();
    });
  });

  group('radio.spec', () {
    Widget radio({
      String? selected,
      bool disabled = false,
      Axis direction = Axis.vertical,
      ValueChanged<String>? onChanged,
      bool required = false,
    }) => host(
      Radio<String>(
        legend: const Text('Legend'),
        required: required,
        options: const [
          RadioOption(label: 'Opt 1', value: '1'),
          RadioOption(label: 'Opt 2', value: '2', disabled: true),
          RadioOption(label: 'Opt 3', value: '3'),
        ],
        selected: selected,
        disabled: disabled,
        direction: direction,
        onChanged: onChanged,
      ),
    );

    testWidgets('renders options and the legend; marks the selected option', (tester) async {
      await tester.pumpWidget(radio(selected: '1'));
      for (final label in ['Opt 1', 'Opt 2', 'Opt 3', 'Legend']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byIcon(PrimeIcons.radioboxMarked), findsOneWidget);
      expect(find.byIcon(PrimeIcons.radioboxBlank), findsNWidgets(2));
      expect(find.text(' *'), findsNothing);
    });

    testWidgets('renders the legend as required', (tester) async {
      await tester.pumpWidget(radio(required: true));
      expect(find.text(' *'), findsOneWidget);
    });

    testWidgets('allows input when enabled; prevents it when disabled; disables a single option', (tester) async {
      final picked = <String>[];
      await tester.pumpWidget(radio(onChanged: picked.add));
      await tester.tap(find.text('Opt 3'));
      await tester.tap(find.text('Opt 2'));
      expect(picked, ['3']);
      await tester.pumpWidget(radio(disabled: true, onChanged: picked.add));
      await tester.tap(find.text('Opt 1'));
      expect(picked, ['3']);
    });

    testWidgets('lays out in a column by default and in a row when asked', (tester) async {
      await tester.pumpWidget(radio());
      expect(tester.getTopLeft(find.text('Opt 3')).dy, greaterThan(tester.getTopLeft(find.text('Opt 1')).dy));
      await tester.pumpWidget(radio(direction: Axis.horizontal));
      expect(tester.getTopLeft(find.text('Opt 3')).dy, tester.getTopLeft(find.text('Opt 1')).dy);
      expect(tester.getTopLeft(find.text('Opt 3')).dx, greaterThan(tester.getTopLeft(find.text('Opt 1')).dx));
    });
  });

  group('site-banner.spec', () {
    testWidgets('warning variant with heading and outside link; info value as a link', (tester) async {
      int status = 0, opened = 0;
      await tester.pumpWidget(
        host(
          Column(
            children: [
              SiteBanner(value: 'Test message', heading: 'We are investigating', linkText: 'Viam status', onLinkTap: () => status++),
              SiteBanner(variant: SiteBannerVariant.info, value: 'Info link', onTap: () => opened++),
            ],
          ),
        ),
      );
      expect(find.text('Test message'), findsOneWidget);
      expect(find.text('We are investigating'), findsOneWidget);
      expect(find.byIcon(PrimeIcons.alert), findsOneWidget);
      await tester.tap(find.text('Viam status'));
      await tester.tap(find.text('Info link'));
      expect((status, opened), (1, 1));
    });

    testWidgets('dismiss button only with onDismiss, and it calls back', (tester) async {
      int dismissed = 0;
      await tester.pumpWidget(host(const SiteBanner(value: 'No dismiss')));
      expect(find.byIcon(PrimeIcons.close), findsNothing);
      await tester.pumpWidget(host(SiteBanner(value: 'Dismiss', onDismiss: () => dismissed++)));
      await tester.tap(find.byIcon(PrimeIcons.close));
      expect(dismissed, 1);
    });

    testWidgets('announcement: badge, styled segments, several links, and dismiss', (tester) async {
      final log = <String>[];
      Widget banner({String? badge}) => host(
        SiteBanner(
          variant: SiteBannerVariant.announcement,
          badge: badge,
          segments: [
            const SiteBannerSegment('Strong', style: SiteBannerSegmentStyle.strong),
            const SiteBannerSegment('Subtle', style: SiteBannerSegmentStyle.subtle),
            SiteBannerSegment('Link one', onTap: () => log.add('one')),
            SiteBannerSegment('Link two', onTap: () => log.add('two')),
          ],
          onDismiss: () => log.add('dismiss'),
        ),
      );
      await tester.pumpWidget(banner(badge: 'New'));
      expect(find.text('NEW'), findsOneWidget);
      await tester.tap(find.text('Link one'));
      await tester.tap(find.text('Link two'));
      await tester.tap(find.byIcon(PrimeIcons.close));
      expect(log, ['one', 'two', 'dismiss']);
      await tester.pumpWidget(banner());
      expect(find.text('NEW'), findsNothing);
    });
  });

  group('switch.spec', () {
    testWidgets('switches on and off when clicked; not when disabled', (tester) async {
      bool value = false;
      Widget app({bool disabled = false}) => host(
        StatefulBuilder(
          builder: (context, setState) => Switch(value: value, disabled: disabled, onChanged: (next) => setState(() => value = next)),
        ),
      );
      await tester.pumpWidget(app());
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(value, isFalse);
      await tester.pumpWidget(app(disabled: true));
      await tester.tap(find.byType(Switch));
      expect(value, isFalse);
    });

    testWidgets('renders an annotated switch, with a custom annotation', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: [
              Switch(value: true, annotated: true, onChanged: (_) {}),
              Switch(value: false, annotated: true, onChanged: (_) {}),
              Switch(value: true, annotated: true, onText: 'Enabled', onChanged: (_) {}),
            ],
          ),
        ),
      );
      expect(find.text('On'), findsOneWidget);
      expect(find.text('Off'), findsOneWidget);
      expect(find.text('Enabled'), findsOneWidget);
    });
  });

  group('tab.spec / tabs-bar.spec', () {
    testWidgets('renders tabs as children and handles clicks', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        PrimeApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: TabBar(
                items: const [Text('The first tab'), Text('The second tab'), Text('The third tab')],
                selectedIndex: selected,
                onDestinationSelected: (index) => setState(() => selected = index),
              ),
            ),
          ),
        ),
      );
      expect(find.text('The first tab'), findsOneWidget);
      await tester.tap(find.text('The third tab'));
      await tester.pumpAndSettle();
      expect(selected, 2);
    });
  });

  group('toggle-button.spec', () {
    Widget toggle(Set<String> selected, ValueChanged<Set<String>> onChanged, {bool disabled = false}) => host(
      SegmentedButton<String>(
        segments: const {'1': Text('Opt 1'), '2': Text('Opt 2'), '3': Text('Opt 3')},
        selected: selected,
        disabled: disabled,
        onSelectionChanged: onChanged,
      ),
    );

    testWidgets('renders options; allows input when enabled; prevents it when disabled', (tester) async {
      Set<String> selected = {'1'};
      await tester.pumpWidget(toggle(selected, (next) => selected = next));
      for (final label in ['Opt 1', 'Opt 2', 'Opt 3']) {
        expect(find.text(label), findsOneWidget);
      }
      await tester.tap(find.text('Opt 3'));
      expect(selected, {'3'});
      await tester.pumpWidget(toggle(selected, (next) => selected = next, disabled: true));
      await tester.tap(find.text('Opt 1'));
      expect(selected, {'3'});
    });
  });

  group('vector-input.spec', () {
    testWidgets('renders labels and three inputs with their initial values', (tester) async {
      await tester.pumpWidget(host(const VectorInput(values: {'x': 1, 'y': 2, 'z': 3})));
      for (final label in ['x', 'y', 'z']) {
        expect(find.text(label), findsOneWidget);
      }
      expect([for (final field in tester.widgetList<EditableText>(find.byType(EditableText))) field.controller.text], ['1', '2', '3']);
    });

    testWidgets('updates on input; emits input while the slider moves and change when it is released', (tester) async {
      final inputs = <Map<String, num>>[], changes = <Map<String, num>>[];
      Map<String, num> values = {'x': 0, 'y': 0, 'z': 0};
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => VectorInput(
              values: values,
              onChanged: (next) {
                inputs.add(next);
                setState(() => values = next);
              },
              onChangeEnd: changes.add,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText).at(1), '5');
      await tester.pump();
      expect(values['y'], 5);
      inputs.clear();
      final handle = tester.getTopLeft(find.byType(SliderInput).first) + const Offset(7, 20);
      await tester.dragFrom(handle, const Offset(60, 0));
      await tester.pump();
      expect(inputs, isNotEmpty);
      expect(values['x'], greaterThan(0));
      expect(changes.last['x'], values['x']);
    });

    testWidgets('makes its inputs readonly', (tester) async {
      await tester.pumpWidget(host(const VectorInput(values: {'x': 1, 'y': 2, 'z': 3}, readOnly: true)));
      expect(tester.widgetList<EditableText>(find.byType(EditableText)).every((field) => field.readOnly), isTrue);
    });
  });

  group('badge.spec', () {
    testWidgets('renders its text and each variant in its colors', (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            children: [for (final variant in BadgeVariant.values) Badge(variant: variant, child: Text(variant.name))],
          ),
        ),
      );
      expect(textColorOf(tester, 'success'), scheme.statusSuccessDark);
      expect(textColorOf(tester, 'warning'), scheme.statusWarningDark);
      expect(textColorOf(tester, 'danger'), scheme.statusDangerDark);
      expect(textColorOf(tester, 'pending'), PrimeColors.pendingDark);
      expect(textColorOf(tester, 'inactive'), scheme.textPrimary);
    });

    testWidgets('progress badge shows a spinning loader; an icon renders when given', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              Badge(variant: BadgeVariant.progress, child: Text('Progress')),
              Badge(variant: BadgeVariant.success, icon: Icon(PrimeIcons.check), child: Text('Success + icon')),
            ],
          ),
        ),
      );
      expect(find.descendant(of: find.widgetWithText(Badge, 'Progress'), matching: find.byType(Progress)), findsOneWidget);
      expect(find.byIcon(PrimeIcons.check), findsOneWidget);
    });
  });

  group('banner.spec', () {
    testWidgets('renders title, subtitle and action; each variant has its icon', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              PrimeBanner(variant: BannerVariant.danger, title: Text('Title'), subtitle: Text('Subtitle'), action: Text('Action')),
              PrimeBanner(variant: BannerVariant.warning, title: Text('Warn')),
              PrimeBanner(variant: BannerVariant.success, title: Text('Good')),
              PrimeBanner(variant: BannerVariant.info, title: Text('Info')),
            ],
          ),
        ),
      );
      for (final text in ['Title', 'Subtitle', 'Action']) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.byIcon(PrimeIcons.alertCircle), findsOneWidget);
      expect(find.byIcon(PrimeIcons.alert), findsOneWidget);
      expect(find.byIcon(PrimeIcons.checkCircle), findsOneWidget);
      expect(find.byIcon(PrimeIcons.information), findsOneWidget);
    });

    testWidgets('a spinner replaces the icon when loading; a small banner has no icon', (tester) async {
      await tester.pumpWidget(host(const PrimeBanner(loading: true, title: Text('Loading'))));
      expect(find.byType(Progress), findsOneWidget);
      expect(find.byIcon(PrimeIcons.information), findsNothing);
      await tester.pumpWidget(host(const PrimeBanner(size: BannerSize.small, title: Text('Small'))));
      expect(find.byIcon(PrimeIcons.information), findsNothing);
    });

    testWidgets('emits close when exitable; a button toggles the details open', (tester) async {
      int closed = 0;
      await tester.pumpWidget(
        host(PrimeBanner(title: const Text('T'), onClose: () => closed++, expandableDetails: const Text('The details'))),
      );
      await tester.tap(find.byIcon(PrimeIcons.close));
      expect(closed, 1);
      expect(find.text('The details'), findsNothing);
      await tester.tap(find.text('Details'));
      await tester.pump();
      expect(find.text('The details'), findsOneWidget);
      await tester.tap(find.text('Details'));
      await tester.pump();
      expect(find.text('The details'), findsNothing);
    });
  });

  group('button.spec / icon-button.spec', () {
    testWidgets('renders its label; clickable; disabled ignores clicks; full width fills', (tester) async {
      int clicks = 0;
      await tester.pumpWidget(
        host(
          Column(
            children: [
              Button(label: const Text('Click'), onPressed: () => clicks++),
              Button(label: const Text('Disabled'), disabled: true, onPressed: () => clicks++),
              Button(label: const Text('Wide'), fullWidth: true, onPressed: () {}),
              for (final variant in ButtonVariant.values) Button(label: Text(variant.name), variant: variant, onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Click'));
      await tester.tap(find.text('Disabled'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(clicks, 1);
      expect(
        tester.getSize(find.widgetWithText(Button, 'Wide')).width,
        greaterThan(tester.getSize(find.widgetWithText(Button, 'Click')).width * 2),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('icon button: renders its icon, each variant, clickable, disabled', (tester) async {
      int clicks = 0;
      await tester.pumpWidget(
        host(
          Column(
            children: [
              IconButton(icon: const Icon(PrimeIcons.plus), label: 'Add', onPressed: () => clicks++),
              IconButton(icon: const Icon(PrimeIcons.minus), label: 'Remove', disabled: true, onPressed: () => clicks++),
              for (final variant in IconButtonVariant.values) IconButton(icon: const Icon(PrimeIcons.cog), variant: variant),
            ],
          ),
        ),
      );
      await tester.tap(find.byIcon(PrimeIcons.plus));
      await tester.tap(find.byIcon(PrimeIcons.minus));
      expect(clicks, 1);
      expect(find.byIcon(PrimeIcons.cog), findsNWidgets(IconButtonVariant.values.length));
    });
  });

  group('code-editor.spec', () {
    testWidgets('renders empty content and real content for every language', (tester) async {
      for (final language in CodeEditorLanguage.values) {
        await tester.pumpWidget(host(CodeEditor(key: ValueKey(language), value: '', language: language)));
        expect(tester.takeException(), isNull, reason: '$language empty');
        expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, '');
        await tester.pumpWidget(host(CodeEditor(key: ValueKey('${language.name}-content'), value: 'name: "x" // 1', language: language)));
        expect(tester.takeException(), isNull, reason: '$language content');
      }
    });

    testWidgets('does not fire onChange on initial mount; fires on a user edit', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(host(CodeEditor(value: '{}', language: CodeEditorLanguage.json, onChanged: changes.add)));
      await tester.pump();
      expect(changes, isEmpty);
      await tester.enterText(find.byType(EditableText), '{ }');
      expect(changes, ['{ }']);
    });

    testWidgets('a new value from outside is not reported as a user change, and reads back', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(host(CodeEditor(value: 'one', onChanged: changes.add)));
      await tester.pumpWidget(host(CodeEditor(value: 'two', onChanged: changes.add)));
      expect(changes, isEmpty);
      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 'two');
    });

    testWidgets('exposes readonly and invalid', (tester) async {
      await tester.pumpWidget(host(const CodeEditor(value: 'x', readOnly: true, invalid: true)));
      expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
      final border =
          tester.widgetList<Container>(find.descendant(of: find.byType(CodeEditor), matching: find.byType(Container))).first.decoration!
              as BoxDecoration;
      expect((border.border! as Border).top.color, scheme.statusDangerDark);
    });
  });

  group('json-fixer.spec', () {
    test('fixes trailing commas before } and ], with newlines, and nested', () {
      expect(tryFixJson('{"a": 1,}'), '{"a": 1}');
      expect(tryFixJson('[1, 2,]'), '[1, 2]');
      expect(tryFixJson('{\n  "a": 1,\n}'), '{\n  "a": 1\n}');
      expect(tryFixJson('{"a": [1, 2,], "b": {"c": 3,},}'), '{"a": [1, 2], "b": {"c": 3}}');
    });

    test('does not modify commas inside strings; handles escaped quotes', () {
      expect(tryFixJson('{"a": "hello,}"}'), '{"a": "hello,}"}');
      expect(tryFixJson(r'{"a": "say \"hi\",}",}'), r'{"a": "say \"hi\",}"}');
    });

    test('returns nothing for unfixable JSON and for missing commas', () {
      expect(tryFixJson('{"a": }'), isNull);
      expect(tryFixJson('{"a": 1 "b": 2}'), isNull);
    });

    test('fixes a realistic machine config with trailing commas', () {
      const input =
          '{\n  "components": [\n    {\n      "name": "my-motor",\n      "attributes": {\n        "pins": { "a": "13", "b": "15", },\n        "board": "my-board",\n      },\n    },\n  ],\n  "services": [],\n}';
      expect(tryFixJson(input), isNotNull);
    });

    testWidgets('the editor fixes trailing commas on blur when asked', (tester) async {
      String value = '{"a": 1}';
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                CodeEditor(
                  value: value,
                  language: CodeEditorLanguage.json,
                  fixJsonOnBlur: true,
                  onChanged: (next) => setState(() => value = next),
                ),
                const Input(placeholder: 'Other field'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText).first);
      await tester.enterText(find.byType(EditableText).first, '{"a": 1,}');
      await tester.pump();
      expect(value, '{"a": 1,}');
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(value, '{"a": 1}');
    });
  });

  group('context-menu.spec / floating-menu.spec', () {
    testWidgets('renders menu, items with variants and a separator; forwards item clicks', (tester) async {
      final clicked = <String>[];
      await tester.pumpWidget(
        host(
          ContextMenu(
            children: [
              ContextMenuItem(icon: PrimeIcons.plus, onTap: () => clicked.add('one'), child: const Text('label 1')),
              const ContextMenuSeparator(),
              ContextMenuItem(variant: ContextMenuItemVariant.danger, onTap: () => clicked.add('danger'), child: const Text('danger')),
            ],
          ),
        ),
      );
      expect(find.byType(ContextMenuSeparator), findsOneWidget);
      expect(textColorOf(tester, 'danger'), scheme.statusDangerDark);
      await tester.tap(find.text('label 1'));
      await tester.tap(find.text('danger'));
      expect(clicked, ['one', 'danger']);
    });

    testWidgets('opens and closes from the control, on Escape, on a click outside, and from an item', (tester) async {
      bool isOpen = false;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                FloatingMenu(
                  isOpen: isOpen,
                  onChange: (open) => setState(() => isOpen = open),
                  control: const Text('Open menu'),
                  items: [ContextMenuItem(onTap: () => setState(() => isOpen = false), child: const Text('Item'))],
                ),
                const SizedBox(height: 300),
                const Text('Elsewhere'),
              ],
            ),
          ),
        ),
      );
      Future<void> toggle() async {
        await tester.tap(find.text('Open menu'));
        await tester.pumpAndSettle();
      }

      await toggle();
      expect(find.text('Item'), findsOneWidget);
      await toggle();
      expect(find.text('Item'), findsNothing);

      await toggle();
      await pressEscape(tester);
      expect(find.text('Item'), findsNothing);

      await toggle();
      await tester.tap(find.text('Elsewhere'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsNothing);

      await toggle();
      await tester.tap(find.text('Item'));
      await tester.pumpAndSettle();
      expect(find.text('Item'), findsNothing);
    });
  });

  group('icon.spec', () {
    testWidgets('renders an icon at every size', (tester) async {
      await tester.pumpWidget(
        host(
          Row(
            children: [
              for (final size in [12.0, 14.0, 16.0, 18.0, 24.0, 32.0, 40.0, 48.0]) Icon(PrimeIcons.cog, size: size),
            ],
          ),
        ),
      );
      final sizes = [for (final icon in find.byIcon(PrimeIcons.cog).evaluate()) tester.getSize(find.byWidget(icon.widget)).width];
      expect(sizes, [12.0, 14.0, 16.0, 18.0, 24.0, 32.0, 40.0, 48.0]);
    });

    test('every icon has its own glyph', () {
      const icons = [
        PrimeIcons.cog,
        PrimeIcons.calendarBlank,
        PrimeIcons.checkboxBlankOutline,
        PrimeIcons.onnx,
        PrimeIcons.sparkles,
        PrimeIcons.folder,
      ];
      expect({for (final icon in icons) icon.codePoint}.length, icons.length);
      expect(icons.every((icon) => icon.fontFamily == 'PrimeIcons' && icon.fontPackage == 'prime_flutter'), isTrue);
    });
  });

  group('input.spec / text-input.spec / numeric-input.spec', () {
    testWidgets('renders; disabled; readonly; info, warn and error states', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              Input(placeholder: 'Enter your name'),
              Input(disabled: true),
              Input(readOnly: true),
              Input(state: InputState.info),
              Input(state: InputState.warn),
              Input(state: InputState.error),
            ],
          ),
        ),
      );
      expect(find.text('Enter your name'), findsOneWidget);
      final fields = tester.widgetList<EditableText>(find.byType(EditableText)).toList();
      expect(fields[1].readOnly, isTrue);
      expect(fields[2].readOnly, isTrue);
      expect(find.byIcon(PrimeIcons.information), findsOneWidget);
      expect(find.byIcon(PrimeIcons.alert), findsOneWidget);
      expect(find.byIcon(PrimeIcons.alertCircle), findsOneWidget);
    });

    testWidgets('a disabled input does not take text', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(host(Input(disabled: true, onChanged: changes.add)));
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();
      expect(tester.testTextInput.hasAnyClients, isFalse);
      expect(changes, isEmpty);
    });

    testWidgets('renders as an email input and as a password input', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              Input(keyboardType: TextInputType.emailAddress),
              Input(obscureText: true),
            ],
          ),
        ),
      );
      final fields = tester.widgetList<EditableText>(find.byType(EditableText)).toList();
      expect(fields[0].keyboardType, TextInputType.emailAddress);
      expect(fields[1].obscureText, isTrue);
    });

    testWidgets('numeric input sets its value; an integer input rejects a decimal', (tester) async {
      num? value;
      await tester.pumpWidget(host(NumericInput(type: NumericInputType.integer, value: 7, onChanged: (next) => value = next)));
      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, '7');
      await tester.enterText(find.byType(EditableText), '1.5');
      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, isNot('1.5'));
      await tester.enterText(find.byType(EditableText), '12');
      expect(value, 12);
    });
  });

  group('range-input.spec', () {
    Widget range({
      num value = 50,
      bool disabled = false,
      bool readOnly = false,
      ValueChanged<num>? onChanged,
      ValueChanged<num>? onChangeEnd,
      num step = 10,
    }) =>
        host(RangeInput(value: value, step: step, disabled: disabled, readOnly: readOnly, onChanged: onChanged, onChangeEnd: onChangeEnd));

    testWidgets('renders the number box, the slider, and the min and max', (tester) async {
      await tester.pumpWidget(range());
      expect(find.byType(EditableText), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      // The min label, alongside the number box's own "0" placeholder.
      expect(find.text('0'), findsWidgets);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('readonly and disabled inputs do not respond', (tester) async {
      final changes = <num>[];
      for (final locked in [range(readOnly: true, onChanged: changes.add), range(disabled: true, onChanged: changes.add)]) {
        await tester.pumpWidget(locked);
        await tester.drag(find.byType(Slider), const Offset(120, 0), warnIfMissed: false);
        await tester.pump();
      }
      expect(changes, isEmpty);
    });

    testWidgets('does not allow sliding below min or above max', (tester) async {
      final changes = <num>[];
      await tester.pumpWidget(range(onChanged: changes.add));
      await tester.drag(find.byType(Slider), const Offset(-2000, 0));
      await tester.drag(find.byType(Slider), const Offset(4000, 0));
      await tester.pump();
      expect(changes, isNotEmpty);
      expect(changes.every((value) => value >= 0 && value <= 100), isTrue);
    });

    testWidgets('a typed value out of range is not accepted while typing and is corrected on blur', (tester) async {
      num value = 50;
      final ends = <num>[];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                RangeInput(value: value, onChanged: (next) => setState(() => value = next), onChangeEnd: ends.add),
                const Input(placeholder: 'Other'),
              ],
            ),
          ),
        ),
      );
      final box = find.byType(EditableText).first;
      await tester.tap(box);
      await tester.enterText(box, '250');
      await tester.pump();
      // The box keeps what is being typed; the value does not leave the range.
      expect(tester.widget<EditableText>(box).controller.text, '250');
      expect(value, 50);
      await tester.tap(find.byType(EditableText).last);
      await tester.pump();
      expect(tester.widget<EditableText>(box).controller.text, '100');
      expect(value, 100);
      expect(ends.last, 100);
    });

    testWidgets('emits input and change when the number is edited', (tester) async {
      final inputs = <num>[], ends = <num>[];
      await tester.pumpWidget(range(onChanged: inputs.add, onChangeEnd: ends.add));
      await tester.enterText(find.byType(EditableText), '30');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(inputs, [30]);
      expect(ends, contains(30));
    });
  });

  group('slider-input.spec', () {
    Widget slider(List<num?> inputs, List<num?> ends, {num value = 5}) => host(
      StatefulBuilder(
        builder: (context, setState) => SliderInput(
          value: value,
          min: 0,
          max: 10,
          step: 2,
          onChanged: (next) {
            inputs.add(next);
            setState(() => value = next ?? value);
          },
          onChangeEnd: ends.add,
        ),
      ),
    );

    Future<void> scrub(WidgetTester tester, double dx) async {
      await tester.dragFrom(tester.getTopLeft(find.byType(SliderInput)) + const Offset(7, 20), Offset(dx, 0));
      await tester.pump();
    }

    testWidgets('does not slide below min or above max', (tester) async {
      final inputs = <num?>[], ends = <num?>[];
      await tester.pumpWidget(slider(inputs, ends));
      await scrub(tester, -600);
      expect(inputs.last, 0);
      await scrub(tester, 900);
      expect(inputs.last, 10);
    });

    testWidgets('slides in increments of step; emits input while moving and change on release', (tester) async {
      final inputs = <num?>[], ends = <num?>[];
      await tester.pumpWidget(slider(inputs, ends, value: 4));
      await scrub(tester, 40);
      expect(inputs, isNotEmpty);
      expect(inputs.every((value) => value! % 2 == 0), isTrue);
      expect(ends.single, inputs.last);
    });

    testWidgets('emits input and change when the number is edited', (tester) async {
      final inputs = <num?>[], ends = <num?>[];
      await tester.pumpWidget(slider(inputs, ends));
      await tester.enterText(find.byType(EditableText), '8');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(inputs, [8]);
      expect(ends, contains(8));
    });
  });

  group('label.spec', () {
    testWidgets('label above the input by default and left of it when asked', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              Label(
                label: Text('Top label'),
                child: Input(placeholder: 'top field'),
              ),
              Label(
                label: Text('Left label'),
                position: LabelPosition.left,
                child: Input(placeholder: 'left field'),
              ),
            ],
          ),
        ),
      );
      expect(tester.getBottomLeft(find.text('Top label')).dy, lessThanOrEqualTo(tester.getTopLeft(find.text('top field')).dy));
      expect(tester.getTopRight(find.text('Left label')).dx, lessThan(tester.getTopLeft(find.text('left field')).dx));
      expect(tester.getCenter(find.text('Left label')).dy, closeTo(tester.getCenter(find.text('left field')).dy, 12));
    });

    testWidgets('renders as disabled, as required, with its input and with a detail', (tester) async {
      await tester.pumpWidget(
        host(
          const Column(
            children: [
              Label(label: Text('Off'), disabled: true),
              Label(
                label: Text('Needed'),
                required: true,
                child: Input(placeholder: 'slot'),
              ),
              Label(label: Text('With'), detail: '(detail)'),
            ],
          ),
        ),
      );
      expect(textColorOf(tester, 'Off'), scheme.textPlaceholder);
      expect(find.text(' *'), findsOneWidget);
      expect(find.text('slot'), findsOneWidget);
      expect(find.text(' (detail)'), findsOneWidget);
    });
  });

  group('nav-dropdown.spec', () {
    Widget nav(List<String> visited, {String selected = '/a'}) => host(
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            NavDropdown<String>(
              options: const [
                NavOption(label: 'Alpha', value: '/a', selectedText: 'Selected alpha'),
                NavOption(label: 'Beta', value: '/b', detail: 'detail', description: 'A description'),
                NavOption(label: 'Gamma', value: '/c'),
              ],
              selected: selected,
              onSelected: (value) {
                visited.add(value);
                setState(() => selected = value);
              },
            ),
            const SizedBox(height: 300),
          ],
        ),
      ),
    );

    testWidgets('shows the selected text in the button; expands on click; shows option details', (tester) async {
      await tester.pumpWidget(nav([]));
      expect(find.text('Selected alpha'), findsOneWidget);
      expect(find.text('Gamma'), findsNothing);
      await tester.tap(find.text('Selected alpha'));
      await tester.pumpAndSettle();
      expect(find.text('Gamma'), findsOneWidget);
      expect(find.text('A description'), findsOneWidget);
      expect(find.textContaining('(detail)', findRichText: true), findsOneWidget);
    });

    testWidgets('closes on Escape and on Tab', (tester) async {
      for (final key in [LogicalKeyboardKey.escape, LogicalKeyboardKey.tab]) {
        await tester.pumpWidget(nav([]));
        await tester.tap(find.byType(NavDropdown<String>));
        await tester.pumpAndSettle();
        expect(find.text('Gamma'), findsOneWidget);
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
        expect(find.text('Gamma'), findsNothing);
      }
    });

    testWidgets('arrow keys walk the options from the current page and wrap; Enter follows one', (tester) async {
      final visited = <String>[];
      await tester.pumpWidget(nav(visited));
      await tester.tap(find.byType(NavDropdown<String>));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(visited, ['/b']);
      expect(find.text('Gamma'), findsNothing);

      // From Beta, up twice wraps past Alpha to Gamma.
      await tester.tap(find.byType(NavDropdown<String>));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(visited, ['/b', '/c']);
    });
  });

  group('notification.spec', () {
    Future<BuildContext> pump(WidgetTester tester) async {
      late BuildContext inner;
      await tester.pumpWidget(
        PrimeApp(
          home: NotificationContainer(
            child: Builder(
              builder: (context) {
                inner = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      return inner;
    }

    double barOf(WidgetTester tester, String title) => tester
        .widget<FractionallySizedBox>(
          find.descendant(
            of: find.ancestor(of: find.text(title), matching: find.byType(PrimeBanner)),
            matching: find.byType(FractionallySizedBox),
          ),
        )
        .heightFactor!;

    testWidgets('displays dismissible notifications, several at once in different styles', (tester) async {
      final context = await pump(tester);
      final notify = Notify.of(context);
      notify.info('Info title', message: 'Info message');
      notify.warn('Warn title');
      notify.danger('Danger title');
      notify.success('Success title');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      for (final title in ['Info title', 'Warn title', 'Danger title', 'Success title', 'Info message']) {
        expect(find.text(title), findsOneWidget);
      }
      await tester.tap(
        find.descendant(
          of: find.ancestor(of: find.text('Warn title'), matching: find.byType(PrimeBanner)),
          matching: find.byIcon(PrimeIcons.close),
        ),
      );
      await tester.pump();
      expect(find.text('Warn title'), findsNothing);
      expect(find.text('Info title'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
    });

    testWidgets('renders a spinner for pending notifications', (tester) async {
      final context = await pump(tester);
      final handle = Notify.of(context).pending('Working', persist: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.descendant(of: find.byType(PrimeBanner), matching: find.byType(Progress)), findsOneWidget);
      handle.dismiss();
      await tester.pump();
    });

    testWidgets('holds the bar full for persisted notifications and drains it for auto-dismissing ones', (tester) async {
      final context = await pump(tester);
      final handle = Notify.of(context).info('Stays', persist: true);
      Notify.of(context).info('Goes');
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(barOf(tester, 'Stays'), 1);
      expect(barOf(tester, 'Goes'), inInclusiveRange(0.3, 0.7));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('Goes'), findsNothing);
      expect(find.text('Stays'), findsOneWidget);
      handle.dismiss();
      await tester.pump();
    });
  });

  group('parse-relative-time.spec', () {
    test('returns the current date for "now"', () {
      final now = DateTime(2026, 5, 1, 9, 30);
      expect(parseRelativeTime('now', now: now), now);
      final live = parseRelativeTime('now')!;
      expect(DateTime.now().difference(live).inSeconds.abs(), lessThan(2));
    });
  });

  group('multiselect.spec', () {
    Widget select(
      List<String> selected,
      ValueChanged<List<String>> onChanged, {
      SelectSort sort = SelectSort.matchesFirst,
      bool showPills = true,
      bool disabled = false,
    }) => host(
      Column(
        children: [
          Multiselect(
            options: SelectOption.fromStrings(['First Option', 'Option 2', 'C.) Option']),
            selected: selected,
            sort: sort,
            showPills: showPills,
            disabled: disabled,
            clearable: true,
            heading: 'A heading',
            buttonText: 'A button',
            onChanged: onChanged,
          ),
          const SizedBox(height: 400),
          const Text('Elsewhere'),
        ],
      ),
    );

    List<String> order(WidgetTester tester) {
      final names = ['First Option', 'Option 2', 'C.) Option'].where((name) => find.text(name).evaluate().isNotEmpty).toList();
      names.sort((a, b) => tester.getTopLeft(find.text(a).last).dy.compareTo(tester.getTopLeft(find.text(b).last).dy));
      return names;
    }

    Future<void> open(WidgetTester tester, [String? query]) async {
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
      if (query != null) {
        await tester.enterText(find.byType(EditableText), query);
        await tester.pumpAndSettle();
      }
    }

    testWidgets('renders the input, the heading and the button', (tester) async {
      await tester.pumpWidget(select(const [], (_) {}));
      await open(tester);
      expect(find.text('A heading'), findsOneWidget);
      expect(find.text('A button'), findsOneWidget);
      expect(order(tester), ['First Option', 'Option 2', 'C.) Option']);
    });

    testWidgets('a match at the start sorts above a match further in', (tester) async {
      await tester.pumpWidget(select(const [], (_) {}));
      await open(tester, 'opt');
      expect(order(tester), ['Option 2', 'First Option', 'C.) Option']);
    });

    testWidgets('filters out options without a match when reducing', (tester) async {
      await tester.pumpWidget(select(const [], (_) {}, sort: SelectSort.reduce));
      await open(tester, 'c.)');
      expect(order(tester), ['C.) Option']);
    });

    testWidgets('does not filter or sort when sorting is off', (tester) async {
      await tester.pumpWidget(select(const [], (_) {}, sort: SelectSort.off));
      await open(tester, 'opt');
      expect(order(tester), ['First Option', 'Option 2', 'C.) Option']);
    });

    testWidgets('selects with a click, and with the arrow keys and Enter', (tester) async {
      List<String> selected = [];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => Multiselect(
              options: SelectOption.fromStrings(['First Option', 'Option 2', 'C.) Option']),
              selected: selected,
              onChanged: (next) => setState(() => selected = next),
            ),
          ),
        ),
      );
      await open(tester);
      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();
      expect(selected, ['Option 2']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(selected, ['Option 2', 'C.) Option']);
    });

    testWidgets('closes the menu on Escape and when focus leaves', (tester) async {
      await tester.pumpWidget(select(const [], (_) {}));
      await open(tester);
      await pressEscape(tester);
      expect(find.text('A heading'), findsNothing);
      await open(tester);
      await tester.tap(find.text('Elsewhere'));
      await tester.pumpAndSettle();
      expect(find.text('A heading'), findsNothing);
    });

    testWidgets('clears with clear all; removes one with its pill; hides pills when asked', (tester) async {
      List<String> selected = ['First Option', 'Option 2'];
      Widget app({bool showPills = true}) => host(
        StatefulBuilder(
          builder: (context, setState) => Multiselect(
            options: SelectOption.fromStrings(['First Option', 'Option 2']),
            selected: selected,
            clearable: true,
            showPills: showPills,
            onChanged: (next) => setState(() => selected = next),
          ),
        ),
      );
      await tester.pumpWidget(app());
      await tester.tap(find.descendant(of: find.widgetWithText(Pill, 'First Option'), matching: find.byIcon(PrimeIcons.close)));
      await tester.pump();
      expect(selected, ['Option 2']);
      await tester.tap(find.text('Clear all'));
      await tester.pump();
      expect(selected, isEmpty);
      selected = ['Option 2'];
      await tester.pumpWidget(app(showPills: false));
      expect(find.byType(Pill), findsNothing);
    });

    testWidgets('disabled: does not open, and its pills cannot be removed', (tester) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(select(const ['Option 2'], changes.add, disabled: true));
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('A heading'), findsNothing);
      await tester.tap(find.descendant(of: find.byType(Pill), matching: find.byIcon(PrimeIcons.close)), warnIfMissed: false);
      expect(changes, isEmpty);
    });
  });

  group('searchable-select.spec', () {
    final options = [
      const SelectOption('one', label: 'Option One', description: 'The first', icon: PrimeIcons.cog),
      const SelectOption('two', label: 'Option Two'),
      const SelectOption('three', label: 'Something Else'),
    ];

    Widget select(
      String value,
      ValueChanged<String> onChanged, {
      bool exclusive = false,
      bool disabled = false,
      bool isLoading = false,
      String prefix = '',
      List<SelectOption>? opts,
      String placeholder = 'Select an option',
    }) => host(
      Column(
        children: [
          SearchableSelect(
            options: opts ?? options,
            value: value,
            exclusive: exclusive,
            disabled: disabled,
            isLoading: isLoading,
            otherOptionPrefix: prefix,
            placeholder: placeholder,
            onChanged: onChanged,
          ),
          const SizedBox(height: 400),
          const Text('Elsewhere'),
        ],
      ),
    );

    Future<void> focus(WidgetTester tester) async {
      await tester.tap(find.byType(EditableText));
      await tester.pumpAndSettle();
    }

    Future<void> blur(WidgetTester tester) async {
      await tester.tap(find.text('Elsewhere'));
      await tester.pumpAndSettle();
    }

    String text(WidgetTester tester) => tester.widget<EditableText>(find.byType(EditableText)).controller.text;

    testWidgets('has a placeholder; expands on focus; collapses on blur', (tester) async {
      await tester.pumpWidget(select('', (_) {}));
      expect(find.text('Select an option'), findsOneWidget);
      expect(find.text('Option Two'), findsNothing);
      await focus(tester);
      expect(find.text('Option Two'), findsOneWidget);
      await blur(tester);
      expect(find.text('Option Two'), findsNothing);
    });

    testWidgets('does not expand when disabled', (tester) async {
      await tester.pumpWidget(select('', (_) {}, disabled: true));
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Option Two'), findsNothing);
    });

    testWidgets('shows a loading indicator in place of the options', (tester) async {
      await tester.pumpWidget(select('', (_) {}, isLoading: true));
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.pump();
      expect(find.byType(Progress), findsOneWidget);
      expect(find.text('Option Two'), findsNothing);
    });

    testWidgets('has options with labels, descriptions and icons', (tester) async {
      await tester.pumpWidget(select('', (_) {}));
      await focus(tester);
      expect(find.text('Option One'), findsOneWidget);
      expect(find.text('The first'), findsOneWidget);
      expect(find.byIcon(PrimeIcons.cog), findsOneWidget);
    });

    testWidgets('selects a clicked option, shows its label, and does not report again on blur', (tester) async {
      final changes = <String>[];
      String value = '';
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                SearchableSelect(
                  options: options,
                  value: value,
                  onChanged: (next) {
                    changes.add(next);
                    setState(() => value = next);
                  },
                ),
                const SizedBox(height: 400),
                const Text('Elsewhere'),
              ],
            ),
          ),
        ),
      );
      await focus(tester);
      await tester.tap(find.text('Option Two'));
      await tester.pumpAndSettle();
      expect(changes, ['two']);
      expect(text(tester), 'Option Two');
      await focus(tester);
      await blur(tester);
      expect(changes, ['two']);
    });

    testWidgets('renders the initial value, and its label once options arrive', (tester) async {
      await tester.pumpWidget(select('two', (_) {}, opts: const []));
      expect(text(tester), 'two');
      await tester.pumpWidget(select('one', (_) {}));
      expect(text(tester), 'Option One');
    });

    testWidgets('updates the rendered options when the options change', (tester) async {
      await tester.pumpWidget(select('', (_) {}));
      await focus(tester);
      expect(find.text('Something Else'), findsOneWidget);
      await tester.pumpWidget(select('', (_) {}, opts: const [SelectOption('new', label: 'Brand New')]));
      await tester.pumpAndSettle();
      expect(find.text('Brand New'), findsOneWidget);
      expect(find.text('Something Else'), findsNothing);
    });

    testWidgets('typing an exact option and pressing Enter selects it; blur does the same', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(select('', changes.add));
      await focus(tester);
      await tester.enterText(find.byType(EditableText), 'option two');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(changes, ['two']);

      changes.clear();
      await tester.pumpWidget(select('', changes.add));
      await focus(tester);
      await tester.enterText(find.byType(EditableText), 'Something Else');
      await blur(tester);
      expect(changes, ['three']);
    });

    testWidgets('Escape keeps the last selected value, exclusive or not', (tester) async {
      for (final exclusive in [false, true]) {
        final changes = <String>[];
        await tester.pumpWidget(select('two', changes.add, exclusive: exclusive));
        await focus(tester);
        await tester.enterText(find.byType(EditableText), 'something el');
        await tester.pumpAndSettle();
        await pressEscape(tester);
        expect(changes, isEmpty, reason: 'exclusive: $exclusive');
        expect(text(tester), 'Option Two');
        expect(find.text('Something Else'), findsNothing);
      }
    });

    testWidgets('non-exclusive accepts arbitrary text, offered with a prefix; exclusive does not', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(select('', changes.add, prefix: 'Use'));
      await focus(tester);
      await tester.enterText(find.byType(EditableText), 'custom thing');
      await tester.pumpAndSettle();
      expect(find.text('Use custom thing'), findsOneWidget);
      await tester.tap(find.text('Use custom thing'));
      await tester.pumpAndSettle();
      expect(changes, ['custom thing']);

      changes.clear();
      await tester.pumpWidget(select('two', changes.add, exclusive: true));
      await focus(tester);
      await tester.enterText(find.byType(EditableText), 'custom thing');
      await tester.pumpAndSettle();
      expect(find.textContaining('custom thing', skipOffstage: true), findsOneWidget);
      await blur(tester);
      expect(changes, isEmpty);
      expect(text(tester), 'Option Two');
    });

    testWidgets('clearing a non-exclusive field reports an empty value', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(select('two', changes.add));
      await focus(tester);
      await tester.enterText(find.byType(EditableText), '');
      await blur(tester);
      expect(changes, ['']);
    });

    testWidgets('arrow keys move through the list and wrap; Enter picks the highlighted option', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(select('', changes.add));
      await focus(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changes, ['three']);
    });
  });

  group('search.spec', () {
    testWidgets('matches special characters at the start and in the middle of an option', (tester) async {
      Future<List<String>> search(String query) async {
        await tester.pumpWidget(
          host(
            SearchableSelect(
              key: ValueKey(query),
              options: SelectOption.fromStrings(['C.) Option', 'Plain', 'Has (parens) inside']),
              sort: SelectSort.reduce,
            ),
          ),
        );
        await tester.tap(find.byType(EditableText));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText), query);
        await tester.pumpAndSettle();
        return [
          for (final name in ['C.) Option', 'Plain', 'Has (parens) inside'])
            if (find.text(name).evaluate().isNotEmpty) name,
        ];
      }

      expect(await search('c.)'), ['C.) Option']);
      expect(await search('(parens)'), ['Has (parens) inside']);
      expect(await search('[zzz'), isEmpty);
    });
  });

  group('select.spec', () {
    testWidgets('renders; selects an option and emits the change; not when disabled', (tester) async {
      final changes = <String?>[];
      String? value;
      Widget app({bool disabled = false}) => host(
        StatefulBuilder(
          builder: (context, setState) => Dropdown<String>(
            value: value,
            placeholder: 'Select one',
            items: const ['First', 'Second'],
            disabled: disabled,
            onChanged: (next) {
              changes.add(next);
              setState(() => value = next);
            },
          ),
        ),
      );
      await tester.pumpWidget(app());
      expect(find.text('Select one'), findsOneWidget);
      await tester.tap(find.text('Select one'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(changes, ['Second']);
      expect(find.text('Second'), findsOneWidget);

      await tester.pumpWidget(app(disabled: true));
      await tester.tap(find.text('Second'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('First'), findsNothing);
      expect(changes, ['Second']);
    });

    testWidgets('renders in the warn and error states', (tester) async {
      Color borderOf(String text) {
        final container = tester.widget<Container>(find.ancestor(of: find.text(text), matching: find.byType(Container)).first);
        return ((container.decoration! as BoxDecoration).border! as Border).top.color;
      }

      await tester.pumpWidget(
        host(
          const Column(
            children: [
              Dropdown<String>(items: ['a'], placeholder: 'Warn state', state: InputState.warn),
              Dropdown<String>(items: ['a'], placeholder: 'Error state', state: InputState.error),
              Dropdown<String>(items: ['a'], placeholder: 'Plain'),
            ],
          ),
        ),
      );
      expect(borderOf('Warn state'), scheme.statusWarningDark);
      expect(borderOf('Error state'), scheme.statusDangerDark);
      expect(borderOf('Plain'), scheme.borderSubtle);
    });
  });

  group('table.spec / table-row.spec', () {
    testWidgets('renders table data and each row variant in its colors', (tester) async {
      await tester.pumpWidget(
        host(
          const PrimeTable(
            header: [Text('Name'), Text('State')],
            rows: [
              PrimeTableRow(cells: [Text('plain'), Text('a')]),
              PrimeTableRow(cells: [Text('good'), Text('b')], variant: TableRowVariant.success),
              PrimeTableRow(cells: [Text('off'), Text('c')], variant: TableRowVariant.disabled),
              PrimeTableRow(cells: [Text('bad'), Text('d')], variant: TableRowVariant.error),
            ],
          ),
        ),
      );
      expect(textColorOf(tester, 'plain'), scheme.textPrimary);
      expect(textColorOf(tester, 'good'), scheme.statusSuccessDark);
      expect(textColorOf(tester, 'off'), scheme.textPlaceholder);
      expect(textColorOf(tester, 'bad'), scheme.statusDangerDark);
    });

    testWidgets('fixed columns share the width; auto columns size to content; widths can be set per column', (tester) async {
      Widget table(TableVariant variant, [Map<int, TableColumnWidth>? widths]) => host(
        PrimeTable(
          variant: variant,
          columnWidths: widths,
          rows: const [
            PrimeTableRow(cells: [Text('a'), Text('a much longer cell')]),
          ],
        ),
      );
      double left(String text) => tester.getTopLeft(find.text(text)).dx;

      await tester.pumpWidget(table(TableVariant.fixed));
      final fixedSecond = left('a much longer cell');
      expect(fixedSecond, greaterThan(300));
      // Auto sizes columns from their content, so the short first column gets less than half.
      await tester.pumpWidget(table(TableVariant.auto));
      expect(left('a much longer cell'), lessThan(fixedSecond - 50));
      await tester.pumpWidget(table(TableVariant.fixed, const {0: FixedColumnWidth(120)}));
      expect(left('a much longer cell'), closeTo(left('a') + 120, 1));
    });
  });

  group('takeover.spec and its parts', () {
    Widget app(List<String> log) => PrimeApp(
      home: Builder(
        builder: (context) => Button(
          label: const Text('Open'),
          onPressed: () async {
            await Takeover.show<void>(
              context: context,
              builder: (context) => const Takeover(
                header: TakeoverHeader(
                  children: [
                    Expanded(child: TakeoverTitle(child: Text('Setup Wizard'))),
                    TakeoverClose(),
                  ],
                ),
                child: Text('Children content'),
              ),
            );
            log.add('closed');
          },
        ),
      ),
    );

    testWidgets('nothing renders while closed; title, close button and children render when open', (tester) async {
      await tester.pumpWidget(app([]));
      expect(find.text('Setup Wizard'), findsNothing);
      expect(find.byType(TakeoverClose), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Setup Wizard'), findsOneWidget);
      expect(find.byType(TakeoverClose), findsOneWidget);
      expect(find.text('Children content'), findsOneWidget);
    });

    testWidgets('closes from the close button and on Escape, reporting the close', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(app(log));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TakeoverClose));
      await tester.pumpAndSettle();
      expect(find.text('Setup Wizard'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await pressEscape(tester);
      expect(find.text('Setup Wizard'), findsNothing);
      expect(log, ['closed', 'closed']);
    });
  });

  group('toast.spec', () {
    testWidgets('displays a dismissible toast, with an action button when given', (tester) async {
      int dismissed = 0, undone = 0;
      await tester.pumpWidget(
        host(
          Column(
            children: [
              Toast(message: 'Test Message', variant: ToastVariant.success, onClose: () => dismissed++),
              Toast(
                message: 'With action',
                action: GestureDetector(onTap: () => undone++, child: const Text('Undo')),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Test Message'), findsOneWidget);
      await tester.tap(find.byIcon(PrimeIcons.close).first);
      await tester.tap(find.text('Undo'));
      expect((dismissed, undone), (1, 1));
    });
  });

  group('tooltip.spec', () {
    Widget tip({TooltipVisibility? visibility, Duration delay = Duration.zero}) => host(
      Column(
        children: [
          const SizedBox(height: 120),
          Tooltip(message: 'This is the tooltip text!', visibility: visibility, hoverDelay: delay, child: const Text('Target')),
        ],
      ),
    );

    Future<TestGesture> hover(WidgetTester tester) async {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Target')));
      await tester.pump();
      return mouse;
    }

    testWidgets('renders the target without the tooltip', (tester) async {
      await tester.pumpWidget(tip());
      await tester.pump();
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('This is the tooltip text!'), findsNothing);
    });

    testWidgets('always renders when visible; never when invisible, even on hover', (tester) async {
      await tester.pumpWidget(tip(visibility: TooltipVisibility.visible));
      await tester.pump();
      expect(find.text('This is the tooltip text!'), findsOneWidget);
      await tester.pumpWidget(tip(visibility: TooltipVisibility.invisible));
      final mouse = await hover(tester);
      await tester.pump();
      expect(find.text('This is the tooltip text!'), findsNothing);
      await mouse.removePointer();
    });

    testWidgets('shows on mouse enter and hides on mouse exit', (tester) async {
      await tester.pumpWidget(tip());
      await tester.pump();
      final mouse = await hover(tester);
      await tester.pump();
      expect(find.text('This is the tooltip text!'), findsOneWidget);
      await mouse.moveTo(const Offset(700, 500));
      await tester.pump();
      await tester.pump();
      expect(find.text('This is the tooltip text!'), findsNothing);
      await mouse.removePointer();
    });

    testWidgets('shows on mouse enter only after its delay', (tester) async {
      await tester.pumpWidget(tip(delay: const Duration(milliseconds: 500)));
      await tester.pump();
      final mouse = await hover(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('This is the tooltip text!'), findsNothing);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.text('This is the tooltip text!'), findsOneWidget);
      await mouse.removePointer();
    });

    testWidgets('shows on keyboard focus and hides on blur', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        host(
          Column(
            children: [
              const SizedBox(height: 120),
              Tooltip(
                message: 'Focus tip',
                child: Focus(focusNode: node, child: const Text('Focusable')),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      node.requestFocus();
      await tester.pump();
      await tester.pump();
      expect(find.text('Focus tip'), findsOneWidget);
      node.unfocus();
      await tester.pump();
      await tester.pump();
      expect(find.text('Focus tip'), findsNothing);
    });
  });

  test('debug platform override is not left set', () {
    expect(debugDefaultTargetPlatformOverride, isNull);
  });
}
