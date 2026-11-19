import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

Widget host(Widget child) {
  return PrimeApp(
    home: PrimeScaffold(
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

void main() {
  testWidgets('display components render', (tester) async {
    await tester.pumpWidget(
      host(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            for (final variant in BannerVariant.values)
              PrimeBanner(
                variant: variant,
                title: Text('Title $variant'),
                subtitle: const Text('Subtitle'),
                action: const Text('Action'),
                expandableDetails: const Text('Details body'),
                onClose: () {},
              ),
            const PrimeBanner(size: BannerSize.small, loading: true, title: Text('Small')),
            const SiteBanner(value: 'Investigating', heading: 'Heading', linkText: 'Status'),
            SiteBanner(variant: SiteBannerVariant.info, value: 'Info', onDismiss: () {}),
            SiteBanner(
              variant: SiteBannerVariant.announcement,
              badge: 'New',
              segments: [const SiteBannerSegment('Hello', style: SiteBannerSegmentStyle.strong), SiteBannerSegment('link', onTap: () {})],
              onDismiss: () {},
            ),
            const Breadcrumbs(crumbs: ['Dessert', 'Cookie']),
            NavigationBreadcrumb(
              children: [
                NavigationBreadcrumbLink(onTap: () {}, child: const Text('Fleet')),
                const NavigationBreadcrumbSeparator(),
                const NavigationBreadcrumbEllipsis(),
                const NavigationBreadcrumbSeparator(),
                const NavigationBreadcrumbPage(child: Text('arm-1')),
              ],
            ),
            for (final variant in IconButtonVariant.values) IconButton(icon: const Icon(PrimeIcons.plus), label: 'Add $variant', variant: variant),
            const IconButton(icon: Icon(PrimeIcons.plus), disabled: true, size: IconButtonSize.large),
            const IconButton(icon: Icon(PrimeIcons.plus), loading: true),
            const InlineCode('viam-server'),
            const CodeSnippet(code: '{ "a": 1 }', caption: Text('Caption')),
            const CodeSnippet(code: 'wrapped', wrapLines: true, showCopyButton: false),
            const KbdGroup(children: [Kbd(child: Text('S')), Kbd(variant: KbdVariant.dark, child: Text('K'))]),
            const Label(label: Text('Name'), required: true, detail: '(optional)', child: Input()),
            const Label(label: Text('Left'), position: LabelPosition.left, child: Input()),
            for (final variant in PillVariant.values) Pill(value: 'Pill $variant', variant: variant, icon: PrimeIcons.tagOutline, iconTooltip: 'Tag'),
            const Pill(value: 'Readonly', readOnly: true),
            for (final variant in StatusPillVariant.values) StatusPill(label: 'live', variant: variant, tooltip: 'Tip'),
            const StatusPill(label: 'loading', variant: StatusPillVariant.inactive, loading: true),
            const Tooltip(message: 'Always', visibility: TooltipVisibility.visible, child: Text('Target')),
            PrimeTable(
              header: const [Text('Name'), Text('Status')],
              rows: [
                for (final variant in TableRowVariant.values) PrimeTableRow(cells: [Text('row $variant'), const Text('ok')], variant: variant),
              ],
            ),
            const PrimeTable(variant: TableVariant.auto, rows: [PrimeTableRow(cells: [Text('a'), Text('b')])]),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Always'), findsOneWidget);

    await tester.tap(find.text('Details').first);
    await tester.pump();
    expect(find.text('Details body'), findsOneWidget);
  });

  testWidgets('PrimeBanner outlined appearance shows a chip, content, and a working close button', (tester) async {
    int closed = 0;
    await tester.pumpWidget(
      host(
        Column(
          spacing: 8,
          children: [
            for (final variant in BannerVariant.values)
              PrimeBanner(
                appearance: BannerAppearance.outlined,
                variant: variant,
                title: Text('Title ${variant.name}'),
                subtitle: const Text('Description'),
                onClose: () => closed++,
              ),
            const PrimeBanner(appearance: BannerAppearance.outlined, subtitle: Text('Compact one-liner')),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Title warning'), findsOneWidget);
    expect(find.text('Compact one-liner'), findsOneWidget);
    // The pending variant wears a spinner in its chip.
    expect(find.byType(Progress), findsOneWidget);
    await tester.tap(find.byIcon(PrimeIcons.close).first);
    expect(closed, 1);
  });

  testWidgets('Badge variants, Progress dots, highlighted CodeSnippet, and JSON5 editor render', (tester) async {
    await tester.pumpWidget(
      host(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            for (final variant in BadgeVariant.values) Badge(variant: variant, child: Text(variant.name.toUpperCase())),
            const Progress(variant: ProgressVariant.dots),
            const CodeSnippet(code: '{ "speed": 5, "on": true }', language: CodeEditorLanguage.json),
            const CodeEditor(value: "{\n  // comments are fine\n  name: 'arm',\n  limit: 0xff,\n}", language: CodeEditorLanguage.json5),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    // The progress badge wears a spinner; the dots style is a single braille glyph.
    expect(find.descendant(of: find.widgetWithText(Badge, 'PROGRESS'), matching: find.byType(Progress)), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is Text && (widget.data?.length == 1) && widget.data!.codeUnitAt(0) >= 0x2800 && widget.data!.codeUnitAt(0) <= 0x28FF), findsOneWidget);

    // The snippet colors its tokens: the number and the boolean differ from plain text.
    final theme = PrimeThemeData.light();
    final spans = highlightCode('{ "speed": 5, "on": true }', CodeEditorLanguage.json, theme);
    final colors = {for (final span in spans) span.text!.trim(): span.style?.color};
    expect(colors['5'], isNotNull);
    expect(colors['true'], isNotNull);
    expect(colors['5'], isNot(colors['true']));
    // JSON5: a comment and a bare key are both recognized.
    final json5 = highlightCode("// note\nname: 'arm'", CodeEditorLanguage.json5, theme);
    expect(json5.firstWhere((span) => span.text == '// note').style?.color, isNotNull);
    expect(json5.firstWhere((span) => span.text == 'name').style?.color, isNotNull);
    expect(highlightCode('name: 1', CodeEditorLanguage.json, theme).any((span) => span.text == 'name' && span.style?.color != null), isFalse);
  });

  testWidgets('Multiselect shows a heading and a call-to-action in its menu', (tester) async {
    int added = 0;
    await tester.pumpWidget(
      host(
        Multiselect(
          options: SelectOption.fromStrings(['Arm', 'Base']),
          heading: 'Components',
          buttonText: 'Add new',
          buttonIcon: PrimeIcons.plus,
          onButtonPressed: () => added++,
        ),
      ),
    );
    expect(find.text('Components'), findsNothing);
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    expect(find.text('Components'), findsOneWidget);
    expect(find.text('Arm'), findsOneWidget);
    await tester.tap(find.text('Add new'));
    expect(added, 1);
  });

  testWidgets('Expandable toggles', (tester) async {
    await tester.pumpWidget(
      host(Expandable(triggerBuilder: (context, isOpen) => Text(isOpen ? 'Hide' : 'Show'), content: const Text('Body'))),
    );
    expect(find.text('Show'), findsOneWidget);
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('Hide'), findsOneWidget);
  });

  testWidgets('FloatingMenu opens, selects, and closes on outside tap', (tester) async {
    bool isOpen = false;
    int renamed = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              FloatingMenu(
                isOpen: isOpen,
                onChange: (open) => setState(() => isOpen = open),
                control: const Text('Menu'),
                items: [
                  ContextMenuItem(icon: PrimeIcons.pencilOutline, onTap: () => renamed++, child: const Text('Rename')),
                  const ContextMenuSeparator(),
                  const ContextMenuItem(variant: ContextMenuItemVariant.danger, child: Text('Delete')),
                ],
              ),
              const SizedBox(height: 300),
              const Text('Elsewhere'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Rename'), findsNothing);
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsOneWidget);
    await tester.tap(find.text('Rename'));
    expect(renamed, 1);
    await tester.tap(find.text('Elsewhere'));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsNothing);
  });

  testWidgets('Radio reports selection and respects disabled', (tester) async {
    String? selected = 'a';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Radio<String>(
            legend: const Text('Legend'),
            required: true,
            options: const [
              RadioOption(label: 'A', value: 'a', content: Text('A content'), errorMessage: 'Bad'),
              RadioOption(label: 'B', value: 'b', description: 'Desc'),
              RadioOption(label: 'C', value: 'c', disabled: true),
            ],
            selected: selected,
            onChanged: (value) => setState(() => selected = value),
          ),
        ),
      ),
    );
    expect(find.text('A content'), findsOneWidget);
    await tester.tap(find.text('C'));
    expect(selected, 'a');
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(selected, 'b');
    expect(find.text('A content'), findsNothing);
  });

  testWidgets('NumericInput parses, filters, and clamps on commit', (tester) async {
    num? value;
    num? committed;
    await tester.pumpWidget(
      host(NumericInput(type: NumericInputType.integer, max: 10, onChanged: (next) => value = next, onChangeEnd: (next) => committed = next)),
    );
    await tester.enterText(find.byType(EditableText), '42');
    expect(value, 42);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(committed, 10);
    expect(find.text('10'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '1.5x');
    expect(find.text('1.5x'), findsNothing);
  });

  testWidgets('RangeInput, SliderInput and VectorInput render and scrub', (tester) async {
    num slider = 5;
    Map<String, num> vector = {'x': 1, 'y': 2, 'z': 3};
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            spacing: 12,
            children: [
              RangeInput(value: 20, suffix: '%', onChanged: (_) {}),
              const RangeInput(value: 0.5, max: 1, step: 0.01, disabled: true),
              SliderInput(key: const ValueKey('slider'), value: slider, min: 0, max: 8, onChanged: (next) => setState(() => slider = next ?? 0)),
              VectorInput(values: vector, onChanged: (next) => setState(() => vector = next)),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('100%'), findsOneWidget);

    final handle = tester.getTopLeft(find.byKey(const ValueKey('slider'))) + const Offset(7, 20);
    await tester.dragFrom(handle, const Offset(100, 0));
    await tester.pump();
    expect(slider, 8);
  });

  testWidgets('NavDropdown selects an option', (tester) async {
    String? selected = '/a';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => NavDropdown<String>(
            options: const [
              NavOption(label: 'Overview', value: '/a', detail: 'x'),
              NavOption(label: 'Logs', value: '/b', description: 'Live'),
            ],
            selected: selected,
            onSelected: (value) => setState(() => selected = value),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(NavDropdown<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Logs'));
    await tester.pumpAndSettle();
    expect(selected, '/b');
    expect(find.text('Live'), findsNothing);
  });

  testWidgets('SearchableSelect filters, selects, and enforces exclusive', (tester) async {
    String value = '';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              SearchableSelect(
                options: SelectOption.fromStrings(['Arm', 'Base', 'Camera']),
                value: value,
                exclusive: true,
                sort: SelectSort.reduce,
                onChanged: (next) => setState(() => value = next),
              ),
              const SizedBox(height: 400),
              const Text('Elsewhere'),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    expect(find.text('Base'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'ca');
    await tester.pumpAndSettle();
    expect(find.text('Base'), findsNothing);
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(value, 'Camera');

    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'nope');
    await tester.pumpAndSettle();
    expect(find.text('No matching results'), findsOneWidget);
    await tester.tap(find.text('Elsewhere'));
    await tester.pumpAndSettle();
    expect(value, 'Camera');
  });

  testWidgets('Multiselect toggles values and removes via pill', (tester) async {
    List<String> selected = ['Arm'];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Multiselect(
            options: SelectOption.fromStrings(['Arm', 'Base']),
            selected: selected,
            clearable: true,
            onChanged: (next) => setState(() => selected = next),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(EditableText));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Base'));
    await tester.pumpAndSettle();
    expect(selected, ['Arm', 'Base']);
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
  });

  testWidgets('Combobox filters, selects by value, declines, and deselects', (tester) async {
    int? region = 1;
    final queries = <String>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Combobox<int>(
                items: const [
                  ComboboxItem(value: 1, label: 'US East'),
                  ComboboxItem(value: 2, label: 'US West'),
                  ComboboxItem(value: 3, label: 'EU Central'),
                ],
                value: region,
                allowDeselect: true,
                emptyText: 'No matching region',
                onQueryChanged: queries.add,
                // EU Central is declined.
                onChanged: (next) => setState(() => region = next == 3 ? region : next),
              ),
              const SizedBox(height: 400),
              const Text('Elsewhere'),
            ],
          ),
        ),
      ),
    );
    final field = find.byType(EditableText);
    String text() => tester.widget<EditableText>(field).controller.text;
    expect(text(), 'US East');

    await tester.tap(field);
    await tester.pumpAndSettle();
    expect(find.text('US West'), findsOneWidget);
    await tester.enterText(field, 'west');
    await tester.pumpAndSettle();
    expect(queries.last, 'west');
    expect(find.text('EU Central'), findsNothing);
    await tester.tap(find.text('US West'));
    await tester.pumpAndSettle();
    expect(region, 2);
    expect(text(), 'US West');
    expect(queries.last, '');

    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No matching region'), findsOneWidget);
    await tester.tap(find.text('Elsewhere'));
    await tester.pumpAndSettle();
    expect(region, 2);
    expect(text(), 'US West');

    // A declined choice leaves the field showing the value it still has.
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.text('EU Central'));
    await tester.pumpAndSettle();
    expect(region, 2);
    expect(text(), 'US West');

    // Picking the selected option again clears it.
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.text('US West').last);
    await tester.pumpAndSettle();
    expect(region, isNull);
    expect(text(), '');
  });

  testWidgets('DateRangePicker picks start then end, swaps a backwards pick, and parses typing', (tester) async {
    DateRange? value = DateRange(start: DateTime(2026, 3, 10), end: DateTime(2026, 3, 12));
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => DateRangePicker(value: value, max: DateTime(2026, 3, 28), onChanged: (next) => setState(() => value = next)),
        ),
      ),
    );
    final field = find.byType(EditableText);
    String text() => tester.widget<EditableText>(field).controller.text;
    expect(text(), '03/10/2026 – 03/12/2026');

    // After a finished range, the first pick starts a new one and the calendar stays open.
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    expect(value, DateRange(start: DateTime(2026, 3, 20)));
    expect(value!.isComplete, isFalse);
    expect(find.text('March 2026'), findsOneWidget);

    // Picking an earlier day as the end swaps the two.
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(value, DateRange(start: DateTime(2026, 3, 15), end: DateTime(2026, 3, 20)));
    expect(find.text('March 2026'), findsNothing);
    expect(text(), '03/15/2026 – 03/20/2026');

    // Days past max cannot be picked.
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30'));
    await tester.pumpAndSettle();
    expect(value!.start, DateTime(2026, 3, 15));
    // The calendar is still open; its trigger closes it.
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsNothing);

    await tester.enterText(field, '03/05/2026 - 03/02/2026');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(value, DateRange(start: DateTime(2026, 3, 2), end: DateTime(2026, 3, 5)));

    await tester.enterText(field, 'nonsense');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(value!.start, DateTime(2026, 3, 2));
    expect(find.byIcon(PrimeIcons.alertCircle), findsOneWidget);

    await tester.enterText(field, '');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(value, isNull);
  });

  testWidgets('DateTimeInput edits a time, a date, or both, and rejects bad times', (tester) async {
    DateTime? time = DateTime(2026, 3, 10, 9, 30);
    DateTime? moment = DateTime(2026, 3, 10, 9, 30);
    DateTime? day;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            spacing: 12,
            children: [
              DateTimeInput(key: const ValueKey('time'), type: DateTimeInputType.time, value: time, onChanged: (next) => setState(() => time = next)),
              DateTimeInput(key: const ValueKey('both'), value: moment, onChanged: (next) => setState(() => moment = next)),
              DateTimeInput(key: const ValueKey('date'), type: DateTimeInputType.date, value: day, onChanged: (next) => setState(() => day = next)),
            ],
          ),
        ),
      ),
    );
    Finder field(String key, [int index = 0]) => find.descendant(of: find.byKey(ValueKey(key)), matching: find.byType(EditableText)).at(index);
    String text(String key, [int index = 0]) => tester.widget<EditableText>(field(key, index)).controller.text;
    Future<void> type(Finder target, String value) async {
      await tester.enterText(target, value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    }

    // Time only: shows HH:mm, keeps the day, pads a short hour.
    expect(text('time'), '09:30');
    await type(field('time'), '7:05');
    expect(time, DateTime(2026, 3, 10, 7, 5));
    expect(text('time'), '07:05');

    // A time that does not exist is refused and flagged.
    await type(field('time'), '25:00');
    expect(time, DateTime(2026, 3, 10, 7, 5));
    expect(find.descendant(of: find.byKey(const ValueKey('time')), matching: find.byIcon(PrimeIcons.alertCircle)), findsOneWidget);
    await type(field('time'), '');
    expect(time, isNull);

    // Date and time: each part edits its half and leaves the other alone.
    expect(text('both', 0), '03/10/2026');
    expect(text('both', 1), '09:30');
    await type(field('both', 1), '14:45');
    expect(moment, DateTime(2026, 3, 10, 14, 45));
    await type(field('both', 0), '03/12/2026');
    expect(moment, DateTime(2026, 3, 12, 14, 45));
    // Clearing the time keeps the day, at midnight.
    await type(field('both', 1), '');
    expect(moment, DateTime(2026, 3, 12));

    // Date only: typed, and picked from the calendar.
    await type(field('date'), '04/02/2026');
    expect(day, DateTime(2026, 4, 2));
    await tester.tap(find.descendant(of: find.byKey(const ValueKey('date')), matching: find.byType(IconButton)));
    await tester.pumpAndSettle();
    expect(find.text('April 2026'), findsOneWidget);
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    expect(day, DateTime(2026, 4, 20));
    await type(field('date'), '');
    expect(day, isNull);
  });

  testWidgets('DateTimeInput does not respond when disabled or readonly', (tester) async {
    final changes = <DateTime?>[];
    await tester.pumpWidget(
      host(
        Column(
          children: [
            DateTimeInput(value: DateTime(2026, 3, 10, 9, 30), disabled: true, onChanged: changes.add),
            DateTimeInput(type: DateTimeInputType.time, value: DateTime(2026, 3, 10, 9, 30), readOnly: true, onChanged: changes.add),
          ],
        ),
      ),
    );
    expect(tester.widgetList<EditableText>(find.byType(EditableText)).every((field) => field.readOnly), isTrue);
    await tester.tap(find.byType(IconButton), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsNothing);
    expect(changes, isEmpty);
  });

  testWidgets('NotificationContainer shows, auto-dismisses, and persists', (tester) async {
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
    int dismissed = 0;
    Notify.of(inner).success('Saved', message: 'All good', onDismiss: () => dismissed++);
    final pending = Notify.of(inner).pending('Uploading', persist: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Uploading'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text('Saved'), findsNothing);
    expect(dismissed, 1);
    expect(find.text('Uploading'), findsOneWidget);

    pending.dismiss();
    await tester.pump();
    expect(find.text('Uploading'), findsNothing);
  });

  testWidgets('Takeover shows and closes', (tester) async {
    await tester.pumpWidget(
      PrimeApp(
        home: Builder(
          builder: (context) => Button(
            label: const Text('Open'),
            onPressed: () => Takeover.show<void>(
              context: context,
              builder: (context) => const Takeover(
                header: TakeoverHeader(
                  children: [
                    Expanded(child: TakeoverTitle(child: Text('Wizard'))),
                    TakeoverClose(),
                  ],
                ),
                child: Center(child: Text('Content')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Wizard'), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('Wizard'), findsNothing);
  });

  group('relative time', () {
    final now = DateTime(2026, 3, 31, 12);

    test('parseRelativeTime', () {
      expect(parseRelativeTime('now', now: now), now);
      expect(parseRelativeTime('now-15m', now: now), DateTime(2026, 3, 31, 11, 45));
      expect(parseRelativeTime('NOW-2hours', now: now), DateTime(2026, 3, 31, 10));
      expect(parseRelativeTime('now-1w', now: now), DateTime(2026, 3, 24, 12));
      expect(parseRelativeTime('now-1mon', now: now), DateTime(2026, 2, 28, 12));
      expect(parseRelativeTime('now-1y', now: now), DateTime(2025, 3, 31, 12));
      expect(parseRelativeTime('yesterday', now: now), isNull);
      expect(parseRelativeTime('now-5', now: now), isNull);
    });

    test('date value strings round-trip', () {
      final date = DateTime(2026, 1, 5, 3, 4, 5);
      expect(formatDateValueString(date), '01/05/2026 03:04:05');
      expect(parseDateValueString('01/05/2026 03:04:05'), date);
      expect(parseDateValueString('13/05/2026 03:04:05'), isNull);
      expect(parseDateValueString('02/30/2026 03:04:05'), isNull);
      expect(parseDateValueString('nope'), isNull);
    });

    testWidgets('RelativeTimePicker commits text and picks days', (tester) async {
      final changes = <RelativeTimeValue>[];
      int applied = 0;
      String? value;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => RelativeTimePicker(
              value: value,
              onApply: () => applied++,
              onChanged: (next) {
                changes.add(next);
                setState(() => value = next.value);
              },
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'now-15m');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(changes.last.type, RelativeTimeType.relative);
      expect(applied, 1);

      await tester.enterText(find.byType(EditableText), 'garbage');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('Invalid date format.'), findsOneWidget);
      expect(changes.length, 1);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      expect(changes.last.type, RelativeTimeType.absolute);
      expect(changes.last.date!.day, 15);
      expect(find.text('Invalid date format.'), findsNothing);
    });
  });

  group('TreeView', () {
    final nodes = [
      (id: 'rover', name: 'Rover', children: [(id: 'rover/cam', name: 'Camera', children: null), (id: 'rover/base', name: 'Base', children: null)]),
      (id: 'drone', name: 'Drone', children: null),
    ];

    Widget tree({required ValueChanged<Set<String>> onSelected, TreeBranchClick branchClick = TreeBranchClick.toggle}) {
      return host(
        TreeView<dynamic>(
          nodes: nodes,
          nodeToValue: (node) => node.id as String,
          nodeToString: (node) => node.name as String,
          nodeToChildren: (node) => (node.children as List?)?.cast<dynamic>(),
          branchClick: branchClick,
          onSelectedChanged: onSelected,
        ),
      );
    }

    testWidgets('expands on tap and selects leaves', (tester) async {
      Set<String> selected = {};
      await tester.pumpWidget(tree(onSelected: (next) => selected = next));
      expect(find.text('Camera'), findsNothing);
      await tester.tap(find.text('Rover'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsOneWidget);
      expect(selected, isEmpty);
      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();
      expect(selected, {'rover/cam'});
    });

    testWidgets('keyboard navigation', (tester) async {
      Set<String> selected = {};
      await tester.pumpWidget(tree(onSelected: (next) => selected = next, branchClick: TreeBranchClick.select));
      await tester.tap(find.text('Rover'));
      await tester.pumpAndSettle();
      expect(selected, {'rover'});
      expect(find.text('Camera'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(selected, {'rover/base'});
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(selected, {'drone'});
    });
  });

  group('panes', () {
    const a = PaneNode<String>(id: 'a', data: 'A');
    const b = PaneNode<String>(id: 'b', data: 'B');
    const c = PaneNode<String>(id: 'c', data: 'C');
    const LayoutNode<String> root = SplitNode<String>(
      id: 'root',
      direction: SplitDirection.row,
      ratio: 0.5,
      first: a,
      second: SplitNode<String>(id: 'inner', direction: SplitDirection.column, first: b, second: c),
    );

    List<String> ids(LayoutNode<String>? node) => [for (final pane in listPanes(node)) pane.id];

    test('tree operations', () {
      expect(ids(root), ['a', 'b', 'c']);
      expect((setSplitRatio(root, 'inner', 0.3) as SplitNode<String>).second, isA<SplitNode<String>>().having((s) => s.ratio, 'ratio', 0.3));
      expect(identical(setSplitRatio(root, 'missing', 0.3), root), isTrue);

      final removed = removePane(root, 'b') as SplitNode<String>;
      expect(removed.second, same(c));
      expect(removePane(a, 'a'), isNull);

      expect(ids(swapPanes(root, 'a', 'c')), ['c', 'b', 'a']);
      expect((findLayoutNode(updatePaneData(root, 'b', 'B2'), 'b') as PaneNode<String>).data, 'B2');

      final moved = movePane(root, 'a', 'c', SplitDirection.row, SplitKey.first, 'new') as SplitNode<String>;
      expect(moved.id, 'inner');
      expect(ids(moved), ['b', 'a', 'c']);
      expect(moved.second.id, 'new');

      final stacked = stackPanes(root, 'b', 'a', 'stack');
      final stack = findLayoutNode(stacked, 'stack') as StackNode<String>;
      expect([for (final pane in stack.panes) pane.id], ['b', 'a']);
      expect(stack.activeId, 'a');
      expect((findLayoutNode(selectPane(stacked, 'b'), 'stack') as StackNode<String>).activeId, 'b');
      expect([for (final pane in (findLayoutNode(reorderPane(stacked, 'a', 0), 'stack') as StackNode<String>).panes) pane.id], ['a', 'b']);
      // Removing one of two stacked panes dissolves the stack.
      expect(findLayoutNode(removePane(stacked, 'a'), 'stack'), isNull);
      expect(ids(removePane(stacked, 'a')), ['b', 'c']);

      const d = PaneNode<String>(id: 'd', data: 'D');
      expect(ids(addPaneToUpperRight(root, d, 'split-d')), ['a', 'b', 'd', 'c']);
      expect(addPaneToUpperRight<String>(null, d, 'split-d'), same(d));
    });

    testWidgets('Panes renders, resizes, and switches tabs', (tester) async {
      LayoutNode<String>? layout = stackPanes(root, 'c', 'b', 'stack');
      await tester.pumpWidget(
        PrimeApp(
          home: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 800,
              height: 600,
              child: Panes<String>(
                layout: layout,
                onLayoutChanged: (next) => setState(() => layout = next),
                paneLabel: (pane) => 'Tab ${pane.data}',
                paneBuilder: (context, pane, state) => Center(child: Text('Pane ${pane.data}')),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Pane A'), findsOneWidget);
      expect(find.text('Pane B'), findsOneWidget);
      expect(find.text('Pane C'), findsNothing);

      await tester.tap(find.text('Tab C'));
      await tester.pumpAndSettle();
      expect(find.text('Pane C'), findsOneWidget);

      await tester.dragFrom(const Offset(400, 300), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect((layout as SplitNode<String>).ratio, closeTo(0.25, 0.03));
    });
  });

  testWidgets('Panes rearranges by dragging: edge splits, center swaps, tabs stack and unstack', (tester) async {
    LayoutNode<String>? layout = const SplitNode<String>(
      id: 'root',
      direction: SplitDirection.row,
      first: PaneNode(id: 'a', data: 'A'),
      second: SplitNode<String>(id: 'inner', direction: SplitDirection.column, first: PaneNode(id: 'b', data: 'B'), second: PaneNode(id: 'c', data: 'C')),
    );
    await tester.pumpWidget(
      PrimeApp(
        home: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 800,
            height: 600,
            child: Panes<String>(
              layout: layout,
              onLayoutChanged: (next) => setState(() => layout = next),
              paneLabel: (pane) => 'Tab ${pane.data}',
              paneBuilder: (context, pane, state) => Column(
                children: [
                  PaneDragTrigger(child: SizedBox(height: 30, child: Text('Grip ${pane.data}'))),
                  Expanded(child: Text('Body ${pane.data}')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    List<String> ids() => [for (final pane in listPanes(layout)) pane.id];

    Future<void> dragTo(Finder from, Offset to) async {
      final gesture = await tester.startGesture(tester.getCenter(from));
      await gesture.moveBy(const Offset(0, 30));
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
    }

    // A (left half) onto the middle of C (bottom right): swap.
    await dragTo(find.text('Grip A'), const Offset(600, 450));
    expect(ids(), ['c', 'b', 'a']);

    // C (now left) onto the right edge of B (top right): new row split beside B.
    await dragTo(find.text('Grip C'), const Offset(790, 150));
    expect(ids(), ['b', 'c', 'a']);
    final root = layout as SplitNode<String>;
    expect(root.id, 'inner');
    expect((root.first as SplitNode<String>).direction, SplitDirection.row);

    // Dropping outside every pane changes nothing.
    final before = layout;
    await dragTo(find.text('Grip A'), const Offset(2000, 2000));
    expect(identical(layout, before), isTrue);

    // Stack from code, then drag a tab out onto the left edge of the other pane.
    layout = stackPanes(layout, 'b', 'c', 'stack');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      PrimeApp(
        home: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 800,
            height: 600,
            child: Panes<String>(
              layout: layout,
              centerDrop: PaneCenterDrop.stack,
              onLayoutChanged: (next) => setState(() => layout = next),
              paneLabel: (pane) => 'Tab ${pane.data}',
              paneBuilder: (context, pane, state) => Column(
                children: [
                  PaneDragTrigger(child: SizedBox(height: 30, child: Text('Grip ${pane.data}'))),
                  Expanded(child: Text('Body ${pane.data}')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Tab B'), findsOneWidget);
    // A fills the bottom half; its left edge is at x = 0.
    await dragTo(find.text('Tab B'), const Offset(10, 450));
    expect(findLayoutNode(layout, 'stack'), isNull);
    expect(ids(), ['c', 'b', 'a']);

    // With centerDrop: stack, the middle of a plain pane creates a stack.
    await dragTo(find.text('Grip C'), tester.getCenter(find.text('Body A')));
    final stacks = [for (final id in ['a', 'c']) findLayoutNode(layout, id)];
    expect(stacks.every((node) => node != null), isTrue);
    expect(find.text('Tab A'), findsOneWidget);
    expect(find.text('Tab C'), findsOneWidget);
  });

  test('moveStack and swapSlots move whole slots', () {
    const LayoutNode<String> root = SplitNode<String>(
      id: 'root',
      direction: SplitDirection.row,
      first: PaneNode(id: 'a', data: 'A'),
      second: SplitNode<String>(
        id: 'inner',
        direction: SplitDirection.column,
        first: StackNode<String>(id: 'stack', activeId: 'c', panes: [PaneNode(id: 'b', data: 'B'), PaneNode(id: 'c', data: 'C')]),
        second: PaneNode(id: 'd', data: 'D'),
      ),
    );
    List<String> ids(LayoutNode<String>? node) => [for (final pane in listPanes(node)) pane.id];

    final moved = moveStack(root, 'stack', 'a', SplitDirection.column, SplitKey.second, 'new') as SplitNode<String>;
    expect(ids(moved), ['a', 'b', 'c', 'd']);
    final split = moved.first as SplitNode<String>;
    expect(split.id, 'new');
    expect(split.direction, SplitDirection.column);
    expect(split.second, isA<StackNode<String>>().having((stack) => stack.activeId, 'activeId', 'c'));
    // A stack cannot move next to one of its own panes.
    expect(identical(moveStack(root, 'stack', 'b', SplitDirection.row, SplitKey.first, 'new'), root), isTrue);

    // Slots swap whole: naming a stacked pane swaps its stack.
    final swapped = swapSlots(root, 'a', 'b') as SplitNode<String>;
    expect(swapped.first, isA<StackNode<String>>());
    expect(ids(swapped), ['b', 'c', 'a', 'd']);
    expect(identical(swapSlots(root, 'b', 'c'), root), isTrue);
  });

  group('keybindings', () {
    test('format per platform', () {
      const save = Keybinding(id: 'save', description: 'Save', key: 's', mod: true, shift: true);
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(keybindingParts(save), ['⌘', '⇧', 'S']);
      expect(formatKeybinding(save), '⌘⇧S');
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(formatKeybinding(save), 'Ctrl+Shift+S');
      expect(formatKey('arrowup'), '↑');
      expect(formatKey('escape'), 'Esc');
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Hotkey runs while mounted, honors when, lists itself, and leaves typing alone', (tester) async {
      int saves = 0, adds = 0;
      bool enabled = true, showAdd = true;
      late StateSetter rebuild;
      late BuildContext inner;
      await tester.pumpWidget(
        host(
          Keybindings(
            child: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                Widget body = Builder(
                  builder: (context) {
                    inner = context;
                    return const Input(placeholder: 'Type here');
                  },
                );
                if (showAdd) {
                  body = Hotkey(binding: const Keybinding(id: 'add', description: 'Add one', key: 'k'), onInvoke: () => adds++, child: body);
                }
                return Hotkey(
                  binding: const Keybinding(id: 'save', description: 'Save', group: 'File', key: 's', mod: true),
                  onInvoke: () => saves++,
                  when: () => enabled,
                  child: body,
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect([for (final binding in Keybindings.of(inner).bindings) binding.id], ['save', 'add']);

      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      expect(adds, 1);
      // Mod is Control off Apple platforms, which is what the test host reports.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(saves, 1);
      // Plain S is a different shortcut, and so is Shift+K.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect((saves, adds), (1, 1));

      // `when` is read at press time.
      enabled = false;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      expect(saves, 1);

      // An unmodified key typed into a field belongs to the field.
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      expect(adds, 1);

      // Unmounting the Hotkey removes its shortcut.
      rebuild(() => showAdd = false);
      await tester.pump();
      await tester.pump();
      expect([for (final binding in Keybindings.of(inner).bindings) binding.id], ['save']);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  });

  group('floating panes', () {
    const LayoutNode<String> root = SplitNode<String>(
      id: 'root',
      direction: SplitDirection.row,
      first: PaneNode(id: 'a', data: 'A'),
      second: StackNode<String>(id: 'stack', activeId: 'b', panes: [PaneNode(id: 'b', data: 'B'), PaneNode(id: 'c', data: 'C')]),
    );
    const rect = FloatRect(x: 40, y: 40, width: 240, height: 160);

    test('float tree operations', () {
      final floated = floatPane(root, 'a', rect, 'win-a', 'float') as FloatNode<String>;
      expect(floated.base, isA<StackNode<String>>());
      expect(floated.floats.single.content.id, 'a');
      expect(floatEntryOf(floated, 'a'), 'win-a');
      expect(floatEntryOf(floated, 'b'), isNull);
      expect([for (final pane in listPanes(floated)) pane.id], ['b', 'c', 'a']);

      // A second window joins the same float node; a stack floats whole.
      final two = floatStack(floated, 'stack', rect.copyWith(x: 300), 'win-stack', 'unused') as FloatNode<String>;
      expect(two.id, 'float');
      expect(two.base, isNull);
      expect([for (final entry in two.floats) entry.id], ['win-a', 'win-stack']);

      expect((raiseFloat(two, 'win-a') as FloatNode<String>).floats.last.id, 'win-a');
      expect(identical(raiseFloat(two, 'win-stack'), two), isTrue);
      final moved = setFloatRect(two, 'win-a', rect.copyWith(x: 99)) as FloatNode<String>;
      expect(moved.floats.first.rect.x, 99);
      expect(identical(setFloatRect(two, 'win-a', rect), two), isTrue);

      // Closing the last window gives the base back; removing a floated pane closes its window.
      expect(removeFloat(floated, 'win-a'), same(floated.base));
      expect(removePane(floated, 'a'), same(floated.base));
      expect(removeFloat(two, 'win-a'), isA<FloatNode<String>>().having((node) => node.floats.length, 'floats', 1));

      // Docking: move the floated pane back beside a base pane.
      final docked = movePane(floated, 'a', 'b', SplitDirection.row, SplitKey.first, 'split');
      expect(docked, isA<SplitNode<String>>());
      expect(floatEntryOf(docked, 'a'), isNull);

      // A host other than the root wraps just that node.
      final hosted = floatPane(root, 'a', rect, 'win-a', 'float', 'stack');
      expect(hosted, isA<FloatNode<String>>().having((node) => node.base?.id, 'base', 'stack'));
    });

    testWidgets('windows render, raise, move, resize, and close', (tester) async {
      LayoutNode<String>? layout = floatPane(floatPane(root, 'a', rect, 'win-a', 'float'), 'c', rect.copyWith(x: 400), 'win-c', 'float');
      final states = <String, PaneState>{};
      await tester.pumpWidget(
        PrimeApp(
          home: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 800,
              height: 600,
              child: Panes<String>(
                layout: layout,
                onLayoutChanged: (next) => setState(() => layout = next),
                paneLabel: (pane) => 'Tab ${pane.data}',
                paneBuilder: (context, pane, state) {
                  states[pane.id] = state;
                  return Center(child: Text('Body ${pane.data}'));
                },
              ),
            ),
          ),
        ),
      );
      FloatNode<String> node() => layout as FloatNode<String>;
      expect(find.text('Body A'), findsOneWidget);
      expect(find.text('Body B'), findsOneWidget);
      expect(states['a']!.isFloating, isTrue);
      expect(states['a']!.floatEntryId, 'win-a');
      expect(states['b']!.isFloating, isFalse);
      expect(tester.getTopLeft(find.text('Tab A')).dx, greaterThan(40));

      // Pressing the lower window raises it; dragging its title bar moves it.
      expect(node().floats.last.id, 'win-c');
      await tester.drag(find.text('Tab A'), const Offset(30, 50));
      await tester.pumpAndSettle();
      expect(node().floats.last.id, 'win-a');
      expect(node().floats.last.rect.x, closeTo(70, 25));
      expect(node().floats.last.rect.y, closeTo(90, 25));

      final before = node().floats.last.rect;
      await tester.drag(find.bySemanticsLabel('Resize Tab A'), const Offset(60, 40));
      await tester.pumpAndSettle();
      expect(node().floats.last.rect.width, greaterThan(before.width + 20));
      expect(node().floats.last.rect.height, greaterThan(before.height + 10));

      await tester.tap(find.bySemanticsLabel('Close Tab A'));
      await tester.pumpAndSettle();
      expect(find.text('Body A'), findsNothing);
      expect(node().floats.single.id, 'win-c');
    });
  });

  testWidgets('a floating window is kept inside its box on a small screen', (tester) async {
    final layout = floatPane(
      const SplitNode<String>(id: 'root', direction: SplitDirection.row, first: PaneNode(id: 'a', data: 'A'), second: PaneNode(id: 'b', data: 'B')),
      'a',
      const FloatRect(x: 300, y: 500, width: 360, height: 240),
      'win',
      'float',
    );
    await tester.pumpWidget(
      PrimeApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            height: 400,
            child: Panes<String>(layout: layout, onLayoutChanged: (_) {}, paneLabel: (pane) => 'Tab ${pane.data}', paneBuilder: (context, pane, state) => Text('Body ${pane.data}')),
          ),
        ),
      ),
    );
    await tester.pump();
    final window = tester.getRect(find.ancestor(of: find.text('Tab A'), matching: find.byType(Positioned)).first);
    expect(window.left, greaterThanOrEqualTo(0));
    expect(window.right, lessThanOrEqualTo(320));
    expect(window.bottom, lessThanOrEqualTo(400));
    expect(tester.getCenter(find.bySemanticsLabel('Close Tab A')).dx, lessThan(320));
  });

  testWidgets('Panes floatBuilder supplies custom window chrome', (tester) async {
    LayoutNode<String>? layout = floatPane(
      const SplitNode<String>(id: 'root', direction: SplitDirection.row, first: PaneNode(id: 'a', data: 'A'), second: PaneNode(id: 'b', data: 'B')),
      'a',
      const FloatRect(x: 40, y: 40, width: 240, height: 160),
      'win',
      'float',
    );
    await tester.pumpWidget(
      PrimeApp(
        home: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 800,
            height: 600,
            child: Panes<String>(
              layout: layout,
              onLayoutChanged: (next) => setState(() => layout = next),
              paneBuilder: (context, pane, state) => Text('Body ${pane.data}'),
              floatBuilder: (context, entry, controls, content) => Column(
                children: [
                  controls.dragHandle(child: Text('Grab ${entry.id}')),
                  GestureDetector(onTap: controls.close, child: const Text('Shut')),
                  Expanded(child: content),
                  controls.resizeHandle(child: const Text('Size')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp('^Close')), findsNothing);
    await tester.drag(find.text('Grab win'), const Offset(50, 60));
    await tester.pumpAndSettle();
    final moved = (layout as FloatNode<String>).floats.single.rect;
    expect(moved.x, closeTo(90, 25));
    await tester.drag(find.text('Size'), const Offset(60, 60));
    await tester.pumpAndSettle();
    expect((layout as FloatNode<String>).floats.single.rect.width, greaterThan(moved.width + 20));
    await tester.tap(find.text('Shut'));
    await tester.pumpAndSettle();
    expect(layout, isA<PaneNode<String>>());
  });

  testWidgets('AGGridTable takes column defs and row data, reads map fields, variants and getters', (tester) async {
    final clicked = <Object?>[];
    await tester.pumpWidget(
      host(
        AGGridTable<Map<String, Object?>>(
          height: 300,
          onRowClicked: (row) => clicked.add(row['name']),
          columnDefs: [
            const ColDef(field: 'name', headerName: 'Name', flex: 2),
            const ColDef(field: 'parts'),
            ColDef(headerName: 'Double', valueGetter: (row) => (row['parts'] as int) * 2),
            ColDef(headerName: 'Go', sortable: false, cellRenderer: (context, row) => Text('open ${row['name']}')),
          ],
          rowData: const [
            {'name': 'rover', 'parts': 3},
            {'name': 'arm', 'parts': 12, 'variant': 'error'},
            {'name': 'drone', 'parts': 1},
          ],
        ),
      ),
    );
    expect(find.text('parts'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('open drone'), findsOneWidget);
    final errorStyle = tester.widget<DefaultTextStyle>(find.ancestor(of: find.text('arm'), matching: find.byType(DefaultTextStyle)).first);
    expect(errorStyle.style.color, PrimeColors.dangerDark);

    await tester.tap(find.text('Double'));
    await tester.pump();
    expect(tester.getTopLeft(find.text('drone')).dy, lessThan(tester.getTopLeft(find.text('rover')).dy));
    await tester.tap(find.text('rover'));
    expect(clicked, ['rover']);
  });

  testWidgets('Panes move mode places a pane from the keyboard and by tap', (tester) async {
    LayoutNode<String>? layout = const SplitNode<String>(
      id: 'root',
      direction: SplitDirection.row,
      first: PaneNode(id: 'a', data: 'A'),
      second: SplitNode<String>(id: 'inner', direction: SplitDirection.column, first: PaneNode(id: 'b', data: 'B'), second: PaneNode(id: 'c', data: 'C')),
    );
    final moving = <String, bool>{};
    await tester.pumpWidget(
      PrimeApp(
        home: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 800,
            height: 600,
            child: Panes<String>(
              layout: layout,
              onLayoutChanged: (next) => setState(() => layout = next),
              paneLabel: (pane) => 'pane ${pane.data}',
              idGenerator: (kind) => 'new-$kind',
              paneBuilder: (context, pane, state) {
                moving[pane.id] = state.isMoving;
                return Column(
                  children: [
                    PaneMoveTrigger(label: 'Move ${pane.data}', child: Text('Move ${pane.data}')),
                    Expanded(child: Text('Body ${pane.data}')),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    List<String> ids() => [for (final pane in listPanes(layout)) pane.id];

    await tester.tap(find.text('Move A'));
    await tester.pump();
    expect(moving['a'], isTrue);
    expect(find.textContaining('Enter to place pane A'), findsOneWidget);

    // Escape cancels and changes nothing.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(moving['a'], isFalse);
    expect(ids(), ['a', 'b', 'c']);

    // Walk to the far right edge of B and place: A lands in a new row split right of B.
    await tester.tap(find.text('Move A'));
    await tester.pump();
    for (int i = 0; i < 4 && find.textContaining('Right of pane B').evaluate().isEmpty; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
    }
    expect(find.textContaining('Right of pane B'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.textContaining('Below pane B'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.textContaining('Above pane C'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    for (int i = 0; i < 12 && find.textContaining('Right of pane B').evaluate().isEmpty; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(ids(), ['b', 'a', 'c']);
    expect(findLayoutNode(layout, 'new-split'), isA<SplitNode<String>>().having((split) => split.direction, 'direction', SplitDirection.row));
    expect(moving.values.any((value) => value), isFalse);

    // Tap placement: move C, then tap the middle of B to swap them.
    await tester.tap(find.text('Move C'));
    await tester.pump();
    await tester.tap(find.text('Body B'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(ids(), ['c', 'a', 'b']);
  });

  group('CodeEditor', () {
    testWidgets('edits and reports changes', (tester) async {
      String value = '{ "speed": 5 }';
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => CodeEditor(
              value: value,
              language: CodeEditorLanguage.json,
              semanticLabel: 'Config',
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), '{\n  "speed": 6\n}');
      await tester.pump();
      expect(value, '{\n  "speed": 6\n}');
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders every language, wrapped, in a bounded box', (tester) async {
      for (final language in CodeEditorLanguage.values) {
        await tester.pumpWidget(
          PrimeApp(
            home: SizedBox(
              height: 200,
              child: CodeEditor(
                value: '// c\n# c\n-- c\nfunc Main(x int) { return "s" + \'c\' + `t` + 1.5 + true + nil }\n/* open',
                language: language,
                wrapLines: language.index.isEven,
                readOnly: true,
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$language');
      }
    });

    testWidgets('folds from the gutter and keyboard, keeps the document whole, and unfolds', (tester) async {
      const source = '{\n  "a": {\n    "b": 1,\n    "c": 2\n  },\n  "d": [\n    1\n  ]\n}';
      String value = source;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => CodeEditor(value: value, language: CodeEditorLanguage.json, onChanged: (next) => setState(() => value = next)),
          ),
        ),
      );
      String view() => tester.widget<EditableText>(find.byType(EditableText)).controller.text;
      expect(find.text('9'), findsOneWidget);
      expect(find.bySemanticsLabel('Fold line 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Fold line 3'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Fold line 2'));
      await tester.pump();
      expect(view().split('\n').length, 6);
      expect(value, source);
      // Line numbers skip the folded lines.
      expect(find.text('3'), findsNothing);
      expect(find.text('6'), findsOneWidget);
      expect(find.byIcon(PrimeIcons.dotsHorizontal), findsOneWidget);

      // Typing elsewhere reports the whole document, folded region included.
      await tester.enterText(find.byType(EditableText), '${view()}\n');
      await tester.pump();
      expect(value, '$source\n');

      // Fold the outer object too, then unfold everything by tapping the chips.
      await tester.tap(find.bySemanticsLabel('Fold line 1'));
      await tester.pump();
      expect(view().split('\n').length, 2);
      expect(value, '$source\n');
      await tester.tap(find.byIcon(PrimeIcons.dotsHorizontal));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Unfold line 2'));
      await tester.pump();
      expect(view(), '$source\n');
      expect(find.byIcon(PrimeIcons.dotsHorizontal), findsNothing);

      // Keyboard: put the cursor on line 6 and fold, then unfold.
      await tester.tap(find.byType(EditableText));
      tester.widget<EditableText>(find.byType(EditableText)).controller.selection = TextSelection.collapsed(offset: source.indexOf('"d"'));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft);
      await tester.pump();
      expect(view().contains('1\n  ]'), isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.bracketRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(view(), '$source\n');

      // Deleting a chip deletes the code it stood for.
      await tester.tap(find.bySemanticsLabel('Fold line 6'));
      await tester.pump();
      final folded = view();
      final chip = folded.runes.firstWhere((rune) => rune >= 0xE000 && rune <= 0xF8FF);
      await tester.enterText(find.byType(EditableText), folded.replaceAll(String.fromCharCode(chip), ''));
      await tester.pump();
      expect(value, '{\n  "a": {\n    "b": 1,\n    "c": 2\n  },\n  "d": []\n}\n');
    });

    testWidgets('python blocks fold by indentation', (tester) async {
      const source = 'def a():\n    x = 1\n\n    return x\n\ndef b():\n    pass';
      await tester.pumpWidget(host(const CodeEditor(value: source, language: CodeEditorLanguage.python)));
      await tester.tap(find.bySemanticsLabel('Fold line 1'));
      await tester.pump();
      final view = tester.widget<EditableText>(find.byType(EditableText)).controller.text;
      expect(view.split('\n').length, 4);
      expect(view.endsWith('\ndef b():\n    pass'), isTrue);
    });

    testWidgets('search finds, steps, replaces, and closes', (tester) async {
      String value = 'speed one\nSPEED two\nslow\nspeed three';
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => CodeEditor(value: value, onChanged: (next) => setState(() => value = next)),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(find.text('Find'), findsOneWidget);

      final fields = find.byType(EditableText);
      await tester.enterText(fields.at(0), 'speed');
      await tester.pump();
      expect(find.text('1 of 3'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Next match'));
      await tester.pump();
      expect(find.text('2 of 3'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Previous match'));
      await tester.tap(find.bySemanticsLabel('Previous match'));
      await tester.pump();
      expect(find.text('3 of 3'), findsOneWidget);

      await tester.enterText(fields.at(1), 'rate');
      await tester.tap(find.bySemanticsLabel('Replace match'));
      await tester.pump();
      expect(value, 'speed one\nSPEED two\nslow\nrate three');
      expect(find.text('1 of 2'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Replace all matches'));
      await tester.pump();
      expect(value, 'rate one\nrate two\nslow\nrate three');
      expect(find.text('No results'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Close search'));
      await tester.pump();
      expect(find.text('Find'), findsNothing);
    });

    testWidgets('read-only search has no replace row, and searchable: false disables the shortcut', (tester) async {
      for (final searchable in [true, false]) {
        await tester.pumpWidget(host(CodeEditor(key: ValueKey(searchable), value: 'abc', readOnly: true, searchable: searchable)));
        await tester.tap(find.byType(EditableText));
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pump();
        expect(find.text('Find'), searchable ? findsOneWidget : findsNothing);
        expect(find.bySemanticsLabel('Replace match'), findsNothing);
      }
    });

    testWidgets('diff view is editable: edits report the document and re-lay the diff', (tester) async {
      const original = 'one\ntwo\nthree\nfour';
      for (final diff in CodeEditorDiff.values) {
        String value = 'one\nTWO\nthree';
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, setState) =>
                  CodeEditor(key: ValueKey(diff), value: value, original: original, diff: diff, onChanged: (next) => setState(() => value = next)),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$diff');
        final field = find.byType(EditableText);
        String view() => tester.widget<EditableText>(field).controller.text;
        bool isChunk(int unit) => unit >= 0xF000 && unit <= 0xF8FF;
        int chunks() => view().codeUnits.where(isChunk).length;

        // "two" was replaced and "four" deleted: two deleted runs stand in the text, and neither is part of the document.
        expect(chunks(), 2);
        expect(view().split('\n').length, 5);
        expect(find.text('+'), findsOneWidget);
        if (diff == CodeEditorDiff.unified) {
          expect(find.textContaining('two', findRichText: true), findsWidgets);
          expect(find.text('-'), findsNWidgets(2));
        }

        // Restore line two by editing: its deleted run goes away and the document is reported clean.
        await tester.enterText(field, view().replaceFirst('TWO', 'two'));
        await tester.pump();
        expect(value, 'one\ntwo\nthree');
        expect(chunks(), 1);
        expect(find.text('+'), findsNothing);

        // Delete a line: a new deleted run appears for it.
        await tester.enterText(field, view().replaceFirst('one\n', ''));
        await tester.pump();
        expect(value, 'two\nthree');
        expect(chunks(), 2);

        // Typing the original back leaves no diff at all.
        await tester.enterText(field, original);
        await tester.pump();
        expect(value, original);
        expect(chunks(), 0);
        expect(view(), original);

        // A new value from outside is laid out as a diff again.
        value = 'zero\n$original';
        await tester.pumpWidget(
          host(CodeEditor(key: ValueKey(diff), value: value, original: original, diff: diff, onChanged: (_) {})),
        );
        expect(view(), value);
        expect(find.text('+'), findsOneWidget);
      }
    });

    testWidgets('collapsed diff stays editable and keeps its folds while typing', (tester) async {
      final original = [for (int i = 1; i <= 30; i++) 'line $i'].join('\n');
      String value = original.replaceFirst('line 15', 'line fifteen');
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) =>
                CodeEditor(value: value, original: original, collapseUnchanged: true, onChanged: (next) => setState(() => value = next)),
          ),
        ),
      );
      final field = find.byType(EditableText);
      String view() => tester.widget<EditableText>(field).controller.text;
      int folds() => view().codeUnits.where((unit) => unit >= 0xE000 && unit < 0xF000).length;

      // Two long unchanged runs are folded, with three lines of context kept around the change.
      expect(folds(), 2);
      expect(view().contains('line 5'), isFalse);
      expect(view().contains('line 12\nline 13\nline 14'), isTrue);
      expect(find.byIcon(PrimeIcons.dotsHorizontal), findsNWidgets(2));

      // Editing a visible line reports the whole document and leaves both runs folded.
      await tester.enterText(field, view().replaceFirst('line 13', 'line thirteen'));
      await tester.pump();
      expect(value, original.replaceFirst('line 15', 'line fifteen').replaceFirst('line 13', 'line thirteen'));
      expect(folds(), 2);
      expect(view().contains('line 5'), isFalse);

      // A fold opens on tap and stays open through later edits.
      await tester.tap(find.byIcon(PrimeIcons.dotsHorizontal).first);
      await tester.pump();
      expect(folds(), 1);
      expect(view().contains('line 5'), isTrue);
      await tester.enterText(field, view().replaceFirst('line 5\n', 'line five\n'));
      await tester.pump();
      expect(value.contains('line five'), isTrue);
      expect(value.split('\n').length, 30);
      expect(folds(), 1);
    });

    testWidgets('search opens only the folds that hold a match', (tester) async {
      const source = '{\n  "a": {\n    "needle": 1\n  },\n  "b": {\n    "hay": 2\n  }\n}';
      await tester.pumpWidget(host(const CodeEditor(value: source, language: CodeEditorLanguage.json)));
      String view() => tester.widgetList<EditableText>(find.byType(EditableText)).last.controller.text;
      await tester.tap(find.bySemanticsLabel('Fold line 5'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Fold line 2'));
      await tester.pump();
      expect(view().contains('needle'), isFalse);
      expect(view().contains('hay'), isFalse);

      await tester.tap(find.byType(EditableText));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      // Opening search unfolds nothing.
      expect(view().contains('needle'), isFalse);

      await tester.enterText(find.byType(EditableText).first, 'needle');
      await tester.pump();
      expect(find.text('1 of 1'), findsOneWidget);
      expect(view().contains('needle'), isTrue);
      expect(view().contains('hay'), isFalse);
    });

    testWidgets('diff views mark changed lines and collapse unchanged runs', (tester) async {
      final original = [for (int i = 1; i <= 30; i++) 'line $i'].join('\n');
      final value = original.replaceFirst('line 15', 'line fifteen');
      for (final diff in CodeEditorDiff.values) {
        await tester.pumpWidget(host(CodeEditor(key: ValueKey(diff), value: value, original: original, diff: diff, collapseUnchanged: true)));
        expect(tester.takeException(), isNull, reason: '$diff');
        expect(find.text('+'), findsOneWidget);
        expect(find.text('-'), findsOneWidget);
        expect(find.text('12 unchanged lines'), findsWidgets);
        expect(find.text('11 unchanged lines'), findsWidgets);
        expect(find.textContaining('line fifteen', findRichText: true), findsWidgets);
        await tester.tap(find.text('11 unchanged lines').first);
        await tester.pump();
        expect(find.textContaining('line 5', findRichText: true), findsWidgets);
      }
    });
  });

  testWidgets('Field shares state with Label, Hint, Input, Checkbox and Textarea', (tester) async {
    bool checked = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Field(
                required: true,
                state: InputState.error,
                child: Column(
                  children: [
                    const Label(label: Text('Email')),
                    const Input(),
                    const Hint(child: Text('Enter a valid address.')),
                    const Textarea(placeholder: 'Notes'),
                    Checkbox(checked: checked, onChanged: (next) => setState(() => checked = next), label: const Text('Accept')),
                  ],
                ),
              ),
              const Field(disabled: true, child: Checkbox(checked: true, label: Text('Locked'))),
              Checkbox(checked: false, indeterminate: true, onChanged: (_) {}),
              for (final state in StatusDotState.values) StatusDot(state: state, label: state.name),
              const StatusDot(label: 'none', variant: StatusDotVariant.hollow),
              const StatusDot(label: 'busy', working: true, state: StatusDotState.info),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(' *'), findsOneWidget);
    expect(find.byIcon(PrimeIcons.alertCircle), findsNWidgets(2));
    final hint = tester.widget<DefaultTextStyle>(find.ancestor(of: find.text('Enter a valid address.'), matching: find.byType(DefaultTextStyle)).first);
    expect(hint.style.color, PrimeColors.dangerDark);

    await tester.tap(find.text('Accept'));
    await tester.pump();
    expect(checked, isTrue);
    expect(find.byIcon(PrimeIcons.checkboxMarked), findsNWidgets(2));
    await tester.tap(find.text('Locked'));
    await tester.pump();
    expect(find.byIcon(PrimeIcons.checkboxBlankOutline), findsNothing);
  });

  testWidgets('Menu runs items, toggles checks, picks radios, opens submenus, and closes', (tester) async {
    final log = <String>[];
    bool hidden = false;
    String size = 'small';
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              Menu(
                trigger: const Text('Open menu'),
                items: [
                  MenuItem(icon: PrimeIcons.pencilOutline, shortcut: 'R', onTap: () => log.add('rename'), child: const Text('Rename')),
                  MenuItem(disabled: true, onTap: () => log.add('nope'), child: const Text('Disabled')),
                  MenuCheckboxItem(checked: hidden, onChanged: (next) => setState(() => hidden = next), child: const Text('Show hidden')),
                  const MenuSeparator(),
                  MenuRadioGroup<String>(
                    value: size,
                    onChanged: (next) => setState(() => size = next),
                    heading: const Text('Size'),
                    children: const [
                      MenuRadioItem(value: 'small', child: Text('Small')),
                      MenuRadioItem(value: 'large', child: Text('Large')),
                    ],
                  ),
                  MenuSub(
                    items: [MenuItem(variant: MenuItemVariant.danger, onTap: () => log.add('nested'), child: const Text('Nested'))],
                    child: const Text('More'),
                  ),
                ],
              ),
              const SizedBox(height: 500),
              const Text('Elsewhere'),
            ],
          ),
        ),
      ),
    );

    Future<void> open() async {
      await tester.tap(find.text('Open menu'));
      await tester.pumpAndSettle();
    }

    await open();
    await tester.tap(find.text('Disabled'));
    await tester.pumpAndSettle();
    expect(log, isEmpty);
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    expect(log, ['rename']);
    expect(find.text('Rename'), findsNothing);

    await open();
    await tester.tap(find.text('Show hidden'));
    await tester.pumpAndSettle();
    expect(hidden, isTrue);

    await open();
    await tester.tap(find.text('Large'));
    await tester.pumpAndSettle();
    expect(size, 'large');

    await open();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nested'));
    await tester.pumpAndSettle();
    expect(log, ['rename', 'nested']);
    expect(find.text('More'), findsNothing);

    await open();
    await tester.tap(find.text('Elsewhere'));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsNothing);
  });

  testWidgets('Menubar switches menus and ContextMenuRegion opens on long press', (tester) async {
    int copied = 0;
    await tester.pumpWidget(
      host(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Menubar(
              menus: [
                MenubarMenu(label: const Text('File'), items: [MenuItem(onTap: () {}, child: const Text('Open'))]),
                MenubarMenu(label: const Text('Edit'), items: [MenuItem(onTap: () {}, child: const Text('Undo'))]),
              ],
            ),
            const SizedBox(height: 200),
            ContextMenuRegion(
              items: [MenuItem(onTap: () => copied++, child: const Text('Copy'))],
              child: const SizedBox(width: 200, height: 80, child: Text('Target')),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsNothing);

    await tester.longPress(find.text('Target'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy'));
    await tester.pumpAndSettle();
    expect(copied, 1);
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('Popover and Collapsible open and close', (tester) async {
    await tester.pumpWidget(
      host(
        Column(
          children: [
            Popover(
              trigger: const Text('Filters'),
              contentBuilder: (context, close) => GestureDetector(onTap: close, child: const Text('Done')),
            ),
            const SizedBox(height: 200),
            const Collapsible(title: Text('Advanced'), child: Text('More settings')),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNothing);

    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.text('More settings')).height, greaterThan(0));
  });

  testWidgets('DatePicker parses typed dates, rejects unavailable ones, and picks from the calendar', (tester) async {
    DateTime? value = DateTime(2026, 3, 10);
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => DatePicker(value: value, max: DateTime(2026, 3, 20), onChanged: (next) => setState(() => value = next)),
        ),
      ),
    );
    expect(find.text('03/10/2026'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '03/12/2026');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(value, DateTime(2026, 3, 12));

    await tester.enterText(find.byType(EditableText), '03/25/2026');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(value, DateTime(2026, 3, 12));
    expect(find.byIcon(PrimeIcons.alertCircle), findsOneWidget);

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);
    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 3, 12));
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 3, 15));
    expect(find.text('March 2026'), findsNothing);
  });

  testWidgets('tool panel controls render, scrub, and edit', (tester) async {
    num? speed = 5;
    PointValue position = const PointValue(x: 1, y: 2, z: 3);
    num opacity = 0.5;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Panel(
            title: 'Camera',
            children: [
              NumberField(label: 'Speed', min: 0, max: 10, value: speed, onChanged: (next) => setState(() => speed = next)),
              PointField(label: 'Position', value: position, onChanged: (next) => setState(() => position = next)),
              Folder(
                title: 'Lighting',
                children: [
                  SliderField(label: 'Opacity', min: 0, max: 1, step: 0.01, value: opacity, onChanged: (next) => setState(() => opacity = next)),
                  const ControlRow(label: 'Mode', child: Text('Orbit')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);

    await tester.drag(find.text('Speed'), const Offset(3, 0));
    await tester.pump();
    expect(speed, greaterThan(5));
    await tester.drag(find.text('Speed'), const Offset(300, 0));
    await tester.pump();
    expect(speed, 10);

    await tester.enterText(find.byWidgetPredicate((widget) => widget is EditableText && widget.controller.text == '2'), '7');
    await tester.pump();
    expect(position, const PointValue(x: 1, y: 7, z: 3));

    await tester.tap(find.text('Lighting'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.ancestor(of: find.text('Orbit'), matching: find.byType(SizeTransition)).first).height, 0);
  });

  testWidgets('tool panel controls take hints, suffixes, states, per-axis options, and a text field', (tester) async {
    String name = '';
    PointValue pose = const PointValue(x: 1, y: 2, z: 30);
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Panel(
            title: 'Motion',
            children: [
              PanelTextField(label: 'Name', labelWidth: 72, hint: 'The motion service to use', placeholder: 'builtin', onChanged: (next) => setState(() => name = next)),
              const NumberField(label: 'Power', labelWidth: 72, hint: 'Fraction of full power', suffix: '%', state: InputState.error, value: 50),
              const SliderField(label: 'Speed', hint: 'Metres per second', suffix: 'm/s', min: 0, max: 2, step: 0.1, value: 1),
              PointField(
                label: 'Pose',
                hint: 'Position and heading',
                suffix: 'mm',
                value: pose,
                axes: const {'z': PointAxisOptions(suffix: 'deg', max: 45, state: InputState.warn)},
                details: const Text('Heading is near its limit.'),
                onChanged: (next) => setState(() => pose = next),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('m/s'), findsOneWidget);
    expect(find.text('mm'), findsNWidgets(2));
    expect(find.text('deg'), findsOneWidget);
    expect(find.text('Heading is near its limit.'), findsOneWidget);
    expect(find.byIcon(PrimeIcons.informationOutline), findsNWidgets(4));

    await tester.enterText(find.byType(EditableText).first, 'planner');
    expect(name, 'planner');

    // The z axis has its own max: scrubbing its label stops at 45, not beyond.
    await tester.drag(find.text('Z'), const Offset(300, 0));
    await tester.pump();
    expect(pose.z, 45);

    // A long press on the info icon shows the hint.
    await tester.longPress(find.byIcon(PrimeIcons.informationOutline).first);
    await tester.pump();
    expect(find.text('The motion service to use'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Modal shows actions and closes', (tester) async {
    await tester.pumpWidget(
      PrimeApp(
        home: Builder(
          builder: (context) => Button(
            label: const Text('Open'),
            onPressed: () => Modal.show<void>(
              context: context,
              title: const Text('Print?'),
              message: const Text('Writes to the console.'),
              actionsBuilder: (context) => [Button(label: const Text('Cancel'), onPressed: () => Navigator.of(context).pop())],
            ),
          ),
        ),
      ),
    );
    for (final dismiss in [find.text('Cancel'), find.byIcon(PrimeIcons.close)]) {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Print?'), findsOneWidget);
      await tester.tap(dismiss);
      await tester.pumpAndSettle();
      expect(find.text('Print?'), findsNothing);
    }
  });

  testWidgets('DataGrid sorts, cycles direction, reports taps, and shows the empty state', (tester) async {
    final rows = [(name: 'rover', parts: 3), (name: 'arm', parts: 12), (name: 'drone', parts: 1)];
    final tapped = <String>[];
    final sorts = <DataGridSort?>[];
    Widget grid(List<({String name, int parts})> data) => host(
      DataGrid<({String name, int parts})>(
        key: ValueKey(data.length),
        height: 300,
        rows: data,
        onRowTap: (row) => tapped.add(row.name),
        onSortChanged: sorts.add,
        rowVariant: (row) => row.parts > 10 ? TableRowVariant.error : TableRowVariant.none,
        columns: [
          DataGridColumn(id: 'name', header: const Text('Name'), value: (row) => row.name, flex: 2),
          DataGridColumn(id: 'parts', header: const Text('Parts'), value: (row) => row.parts, alignment: Alignment.centerRight),
          DataGridColumn(id: 'action', header: const Text('Action'), sortable: false, width: 80, cellBuilder: (context, row) => const Text('Go')),
        ],
      ),
    );

    List<String> order() {
      final names = ['rover', 'arm', 'drone'];
      names.sort((a, b) => tester.getTopLeft(find.text(a)).dy.compareTo(tester.getTopLeft(find.text(b)).dy));
      return names;
    }

    await tester.pumpWidget(grid(rows));
    expect(order(), ['rover', 'arm', 'drone']);
    await tester.tap(find.text('Parts'));
    await tester.pump();
    expect(order(), ['drone', 'rover', 'arm']);
    await tester.tap(find.text('Parts'));
    await tester.pump();
    expect(order(), ['arm', 'rover', 'drone']);
    await tester.tap(find.text('Parts'));
    await tester.pump();
    expect(order(), ['rover', 'arm', 'drone']);
    expect(sorts.map((sort) => sort?.ascending).toList(), [true, false, null]);
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(order(), ['arm', 'drone', 'rover']);
    await tester.tap(find.text('Action'));
    await tester.pump();
    expect(order(), ['arm', 'drone', 'rover']);

    await tester.tap(find.text('drone'));
    expect(tapped, ['drone']);

    await tester.pumpWidget(grid(const []));
    expect(find.text('No rows to show'), findsOneWidget);
  });
}
