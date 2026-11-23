// Tests for Chart, ChartPlot, ChartLegend and ChartTable, and for the
// arithmetic behind them. The tick cases were checked against d3-scale 4,
// which the web library's chart uses, so both charts tick alike. Times are
// built in local time so the cases hold in any time zone.
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';
import 'package:prime_flutter/src/widgets/internal/chart_math.dart';

double ms(DateTime value) => value.millisecondsSinceEpoch.toDouble();

final DateTime start = DateTime(2026, 11, 19, 18);

List<ChartPoint> readings(List<double?> values, {DateTime? from, Duration every = const Duration(minutes: 1)}) => [
  for (var i = 0; i < values.length; i++) ChartPoint((from ?? start).add(every * i), values[i]),
];

ChartSeriesData data(String name, List<double?> values, {bool hidden = false, String? unit}) => ChartSeriesData(
  name: name,
  unit: unit,
  hidden: hidden,
  xs: [for (var i = 0; i < values.length; i++) ms(start.add(Duration(minutes: i)))],
  ys: values,
);

Widget host(Widget child) => PrimeApp(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

Finder get tooltip => find.byKey(const ValueKey('chart-tooltip'));

void main() {
  group('linear ticks', () {
    test('picks round values inside the range', () {
      expect(linearTicks(0, 1, 5), [0, 0.2, 0.4, 0.6, 0.8, 1]);
      expect(linearTicks(0.13, 9.7, 5), [2, 4, 6, 8]);
      expect(linearTicks(-3.2, 47.9, 6), [0, 10, 20, 30, 40]);
      expect(linearTicks(1200, 15800, 4), [5000, 10000, 15000]);
    });

    test('handles a single value, a reversed range and no count', () {
      expect(linearTicks(3, 3, 5), [3]);
      expect(linearTicks(10, 0, 5), [10, 8, 6, 4, 2, 0]);
      expect(linearTicks(0, 10, 0), isEmpty);
      expect(linearTicks(0, double.infinity, 5), isEmpty);
    });

    test('nice rounds a domain out to the ticks', () {
      expect(niceLinear(0.13, 9.7, 5), (0.0, 10.0));
      expect(niceLinear(-3.2, 47.9, 6), (-10.0, 50.0));
      expect(niceLinear(1200, 15800, 4), (0.0, 20000.0));
      expect(niceLinear(20, 21, 2), (20.0, 21.0));
    });

    test('labels carry the decimals the step needs and group thousands', () {
      String label(double value, double lo, double hi, int count) => formatFixed(value, tickDecimals(lo, hi, count), minus: '−');
      expect(label(0.2, 0, 1, 5), '0.2');
      expect(label(1, 0, 1, 5), '1.0');
      expect(label(15000, 0, 20000, 4), '15,000');
      expect(label(-10, -10, 50, 6), '−10');
      expect(label(0.0015, 0.001, 0.0045, 5), '0.0015');
    });
  });

  group('time ticks', () {
    test('seconds', () {
      final ticks = timeTicks(ms(start), ms(start.add(const Duration(seconds: 40))), 6);
      expect(ticks, [for (var s = 0; s <= 40; s += 5) start.add(Duration(seconds: s))]);
      expect(ticks.map(timeTickLabel).toList(), ['06 PM', ':05', ':10', ':15', ':20', ':25', ':30', ':35', ':40']);
    });

    test('minutes and hours', () {
      final hour = timeTicks(ms(start), ms(start.add(const Duration(hours: 1))), 2);
      expect(hour.map(timeTickLabel).toList(), ['06 PM', '06:30', '07 PM']);

      final evening = timeTicks(ms(DateTime(2026, 11, 19, 18, 3, 21)), ms(DateTime(2026, 11, 19, 23, 47, 2)), 7);
      expect(evening, [for (var h = 19; h <= 23; h++) DateTime(2026, 11, 19, h)]);
      expect(evening.map(timeTickLabel).toList(), ['07 PM', '08 PM', '09 PM', '10 PM', '11 PM']);
    });

    test('days, months and years', () {
      final days = timeTicks(ms(DateTime(2026, 11, 19)), ms(DateTime(2026, 11, 21, 12)), 6);
      expect(days.map(timeTickLabel).toList(), ['Thu 19', '12 PM', 'Fri 20', '12 PM', 'Sat 21', '12 PM']);

      final months = timeTicks(ms(DateTime(2026, 1, 15)), ms(DateTime(2026, 12, 20)), 6);
      expect(months, [DateTime(2026, 4), DateTime(2026, 7), DateTime(2026, 10)]);
      expect(months.map(timeTickLabel).toList(), ['April', 'July', 'October']);

      final years = timeTicks(ms(DateTime(2015, 3)), ms(DateTime(2026, 12, 20)), 5);
      expect(years.map(timeTickLabel).toList(), ['2016', '2018', '2020', '2022', '2024', '2026']);
    });

    test('a week start reads as a date and other days as a weekday', () {
      expect(timeTickLabel(DateTime(2026, 11, 15)), 'Nov 15');
      expect(timeTickLabel(DateTime(2026, 11, 17)), 'Tue 17');
      expect(timeTickLabel(DateTime(2026, 11)), 'November');
    });

    test('milliseconds', () {
      final ticks = timeTicks(ms(start), ms(start) + 400, 4);
      expect(ticks.map(timeTickLabel).toList(), ['06 PM', '.100', '.200', '.300', '.400']);
    });
  });

  group('formats', () {
    test('the default value format groups thousands and trims decimals', () {
      expect(defaultValueFormat(1234.5), '1,234.5');
      expect(defaultValueFormat(12), '12');
      expect(defaultValueFormat(0.12345), '0.123');
      expect(defaultValueFormat(-1500000), '-1,500,000');
    });

    test('the default time format is a full date and time with seconds', () {
      expect(defaultTimeFormat(DateTime(2026, 11, 19, 18, 3, 21)), 'Nov 19, 2026, 6:03:21 PM');
      expect(defaultTimeFormat(DateTime(2026, 1, 2, 0, 5, 9)), 'Jan 2, 2026, 12:05:09 AM');
    });
  });

  group('domains', () {
    test('the x domain comes from the data unless a bound is given', () {
      final series = [
        data('a', [1, 2, 3]),
      ];
      expect(xDomain(series), (ms(start), ms(start.add(const Duration(minutes: 2)))));
      expect(xDomain(series, min: 5), (5.0, ms(start.add(const Duration(minutes: 2)))));
    });

    test('a single point is widened so it stays inside the plot', () {
      final (lo, hi) = xDomain([
        data('a', [7]),
      ]);
      expect(hi - lo, 2);
      expect(
        yDomain([
          data('a', [7]),
        ], tickCount: 5),
        (6.0, 8.0),
      );
    });

    test('the y domain is rounded out to a tick, and a given bound is used exactly', () {
      final series = [
        data('a', [0.13, 9.7]),
      ];
      expect(yDomain(series, tickCount: 5), (0.0, 10.0));
      expect(yDomain(series, min: 0.5, tickCount: 5), (0.5, 10.0));
      expect(yDomain(series, max: 9.9, tickCount: 5), (0.0, 9.9));
    });

    test('an empty chart falls back to a fixed domain', () {
      expect(xDomain(const []), (0.0, 1.0));
      expect(yDomain(const [], tickCount: 5), (0.0, 1.0));
    });

    test('hidden series are left out, unless every series is hidden', () {
      final shown = data('a', [1, 2]);
      final hidden = data('b', [100, 200], hidden: true);
      expect(domainSeries([shown, hidden]), [shown]);
      expect(domainSeries([hidden]), [hidden]);
    });

    test('gaps and non-finite values do not count as data', () {
      expect(
        hasData([
          data('a', [null, double.nan]),
        ]),
        isFalse,
      );
      expect(
        hasData([
          data('a', [null, 1]),
        ]),
        isTrue,
      );
    });
  });

  group('navigation', () {
    final a = data('a', [1, 2, null, 4, 5]);
    final b = data('b', [9, null, 7, 6, 5]);
    final hidden = data('c', [0, 0, 0, 0, 0], hidden: true);
    final series = [a, hidden, b];
    final window = xDomain(series);

    test('first point skips hidden series and gaps', () {
      expect(firstPoint(series, window), (series: 0, index: 0));
      expect(
        firstPoint([
          hidden,
          data('d', [null, 3]),
        ], window),
        (series: 1, index: 1),
      );
      expect(firstPoint([hidden], window), isNull);
    });

    test('left and right step over gaps and stop at the ends', () {
      ActivePoint at = (series: 0, index: 1);
      at = stepPoint(series, at, ChartNavigationKey.right, window);
      expect(at.index, 3);
      at = stepPoint(series, at, ChartNavigationKey.left, window);
      expect(at.index, 1);
      expect(stepPoint(series, (series: 0, index: 0), ChartNavigationKey.left, window).index, 0);
      expect(stepPoint(series, (series: 0, index: 4), ChartNavigationKey.right, window).index, 4);
    });

    test('home, end and paging', () {
      expect(stepPoint(series, (series: 0, index: 3), ChartNavigationKey.home, window).index, 0);
      expect(stepPoint(series, (series: 0, index: 0), ChartNavigationKey.end, window).index, 4);

      final long = [data('long', List<double?>.generate(40, (i) => i.toDouble()))];
      final longWindow = xDomain(long);
      expect(stepPoint(long, (series: 0, index: 10), ChartNavigationKey.pageDown, longWindow).index, 14);
      expect(stepPoint(long, (series: 0, index: 10), ChartNavigationKey.pageUp, longWindow).index, 6);
      // A short series still moves by one.
      expect(stepPoint(series, (series: 0, index: 0), ChartNavigationKey.pageDown, window).index, 1);
    });

    test('up and down move to the next visible series at the nearest time', () {
      expect(stepPoint(series, (series: 0, index: 3), ChartNavigationKey.down, window), (series: 2, index: 3));
      // b has a gap at index 1, so the nearest drawable point is taken.
      expect(stepPoint(series, (series: 0, index: 1), ChartNavigationKey.down, window).series, 2);
      expect(stepPoint(series, (series: 2, index: 0), ChartNavigationKey.up, window), (series: 0, index: 0));
      expect(stepPoint(series, (series: 0, index: 0), ChartNavigationKey.up, window), (series: 0, index: 0));
    });

    test('points outside the x window are skipped', () {
      final narrow = (a.xs[1], a.xs[3]);
      expect(firstPoint(series, narrow), (series: 0, index: 1));
      expect(stepPoint(series, (series: 0, index: 3), ChartNavigationKey.right, narrow).index, 3);
      expect(isAvailable(series, (series: 0, index: 4), narrow), isFalse);
      // A point exactly on a bound is inside.
      expect(isAvailable(series, (series: 0, index: 3), narrow), isTrue);
    });

    test('the pointer picks the nearest point of a visible series', () {
      double x(double value) => (value - window.$1) / (window.$2 - window.$1) * 400;
      double y(double value) => 100 - value * 10;
      final near = nearestPoint(series, x(a.xs[3]) + 3, y(4) + 2, xToPixel: x, yToPixel: y, window: window);
      expect(near, (series: 0, index: 3));
      final other = nearestPoint(series, x(b.xs[0]), y(9), xToPixel: x, yToPixel: y, window: window);
      expect(other, (series: 2, index: 0));
      expect(nearestPoint([hidden], 10, 10, xToPixel: x, yToPixel: y, window: window), isNull);
    });
  });

  group('table rows', () {
    test('merge the series on time and leave a gap empty', () {
      final rows = mergeSeriesRows(
        [
          data('a', [1, null, 3]),
          data('b', [9, 8, null]),
        ],
        (ms(start), ms(start.add(const Duration(minutes: 2)))),
      );
      expect(rows.map((row) => row.values).toList(), [
        [1.0, 9.0],
        [null, 8.0],
        [3.0, null],
      ]);
    });

    test('leave out rows outside the x window', () {
      final rows = mergeSeriesRows(
        [
          data('a', [1, 2, 3]),
        ],
        (ms(start.add(const Duration(minutes: 1))), ms(start.add(const Duration(minutes: 2)))),
      );
      expect(rows.length, 2);
    });
  });

  group('summary', () {
    String summarize(List<ChartSeriesData> series) => summarizeChart(
      series: series,
      window: xDomain(domainSeries(series)),
      formatTime: (value) => '${value.hour}:${value.minute.toString().padLeft(2, '0')}',
      formatValue: defaultValueFormat,
    );

    test('names the series, the time range and the value range', () {
      expect(
        summarize([
          data('cell-01', [12.5, 30], unit: '°'),
          data('cell-02', [5, 8]),
        ]),
        'Series: cell-01 (°), cell-02. Time: 18:00 to 18:01. Values: 5 to 30.',
      );
    });

    test('says when there is no data or every series is hidden', () {
      expect(summarize(const []), 'No data.');
      expect(
        summarize([
          data('a', [1], hidden: true),
        ]),
        'Every series is hidden.',
      );
    });
  });

  group('edge overhang', () {
    test('reserves half of each edge label that reaches past the drawing', () {
      final overhang = edgeOverhang(
        containerWidth: 400,
        left: 0,
        right: 0,
        firstFraction: 0,
        firstWidth: 40,
        lastFraction: 1,
        lastWidth: 60,
      );
      expect(overhang.left, 20);
      expect(overhang.right, 30);
    });

    test('reserves nothing when the other parts already leave room', () {
      final overhang = edgeOverhang(
        containerWidth: 400,
        left: 50,
        right: 0,
        firstFraction: 0,
        firstWidth: 40,
        lastFraction: 0.5,
        lastWidth: 60,
      );
      expect(overhang.left, 0);
      expect(overhang.right, 0);
    });
  });

  group('Chart', () {
    final series = [
      ChartSeries(name: 'cell-01', unit: '°C', points: readings([20, 22, 21, null, 25])),
      ChartSeries(name: 'cell-02', points: readings([10, 12, 14, 13, 11])),
    ];

    Widget chart({
      List<ChartSeries>? of,
      bool loading = false,
      Widget? empty,
      void Function(ChartSeries, bool)? onHidden,
      bool table = false,
      ChartValueFormat? yFormat,
    }) => host(
      Chart(
        semanticLabel: 'Cell temperature',
        series: of ?? series,
        loading: loading,
        empty: empty,
        yFormat: yFormat,
        onSeriesHiddenChanged: onHidden,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ChartLegend(),
            const SizedBox(width: 480, height: 256, child: ChartPlot()),
            if (table) const ChartTable(),
          ],
        ),
      ),
    );

    testWidgets('draws a plot on its own with no child given', (tester) async {
      await tester.pumpWidget(host(Chart(semanticLabel: 'Temperature', series: series)));
      expect(find.byType(ChartPlot), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('takes 256 of height when the layout gives no limit', (tester) async {
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            child: Chart(semanticLabel: 'Temperature', series: series),
          ),
        ),
      );
      expect(tester.getSize(find.byType(ChartPlot)).height, 256);
    });

    testWidgets('the legend names each series with its unit', (tester) async {
      await tester.pumpWidget(chart());
      expect(find.text('cell-01 (°C)'), findsOneWidget);
      expect(find.text('cell-02'), findsOneWidget);
    });

    testWidgets('tapping a legend item hides the series and reports it', (tester) async {
      final changes = <(String, bool)>[];
      await tester.pumpWidget(chart(onHidden: (series, hidden) => changes.add((series.name, hidden))));

      await tester.tap(find.text('cell-02'));
      await tester.pump();
      expect(changes, [('cell-02', true)]);
      expect(tester.widget<Text>(find.text('cell-02')).style!.decoration, TextDecoration.lineThrough);

      await tester.tap(find.text('cell-02'));
      await tester.pump();
      expect(changes.last, ('cell-02', false));
      expect(tester.widget<Text>(find.text('cell-02')).style!.decoration, TextDecoration.none);
    });

    testWidgets('space toggles a focused legend item', (tester) async {
      final changes = <bool>[];
      await tester.pumpWidget(chart(onHidden: (_, hidden) => changes.add(hidden)));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(changes, [true]);
    });

    testWidgets('a series that starts hidden is struck through, and the parent can take it back', (tester) async {
      List<ChartSeries> withHidden(bool hidden) => [
        ChartSeries(name: 'a', points: readings([1, 2]), hidden: hidden),
      ];
      await tester.pumpWidget(chart(of: withHidden(true)));
      expect(tester.widget<Text>(find.text('a')).style!.decoration, TextDecoration.lineThrough);

      await tester.tap(find.text('a'));
      await tester.pump();
      expect(tester.widget<Text>(find.text('a')).style!.decoration, TextDecoration.none);

      await tester.pumpWidget(chart(of: withHidden(false)));
      await tester.pumpWidget(chart(of: withHidden(true)));
      expect(tester.widget<Text>(find.text('a')).style!.decoration, TextDecoration.lineThrough);
    });

    testWidgets('a loading series shows a loading mark in the legend', (tester) async {
      await tester.pumpWidget(
        chart(
          of: [
            ChartSeries(name: 'a', points: readings([1, 2]), loading: true),
          ],
        ),
      );
      expect(find.byType(Progress), findsOneWidget);
    });

    testWidgets('shows "No data" when no series has a point', (tester) async {
      await tester.pumpWidget(chart(of: const []));
      expect(find.text('No data'), findsOneWidget);

      await tester.pumpWidget(
        chart(
          of: [
            ChartSeries(name: 'a', points: readings([null, null])),
          ],
        ),
      );
      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('shows a custom empty state', (tester) async {
      await tester.pumpWidget(chart(of: const [], empty: const Text('Nothing recorded yet')));
      expect(find.text('Nothing recorded yet'), findsOneWidget);
      expect(find.text('No data'), findsNothing);
    });

    testWidgets('a chart whose series are all hidden is not empty', (tester) async {
      await tester.pumpWidget(
        chart(
          of: [
            ChartSeries(name: 'a', points: readings([1, 2]), hidden: true),
          ],
        ),
      );
      expect(find.text('No data'), findsNothing);
    });

    testWidgets('loading lays an overlay on the plot and wins over the empty state', (tester) async {
      await tester.pumpWidget(chart(loading: true));
      expect(find.byKey(const ValueKey('chart-loading')), findsOneWidget);

      await tester.pumpWidget(chart(of: const [], loading: true));
      expect(find.byKey(const ValueKey('chart-loading')), findsOneWidget);
      expect(find.text('No data'), findsNothing);
    });

    testWidgets('hovering shows the nearest point with its time, value and unit', (tester) async {
      await tester.pumpWidget(chart());
      expect(tooltip, findsNothing);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      // Near the top right, where cell-01 ends at 25.
      await mouse.moveTo(tester.getTopRight(find.byType(ChartPlot)) + const Offset(-4, 12));
      await tester.pump();

      expect(tooltip, findsOneWidget);
      expect(find.descendant(of: tooltip, matching: find.text('cell-01')), findsOneWidget);
      expect(find.descendant(of: tooltip, matching: find.text('25 °C')), findsOneWidget);
      expect(find.descendant(of: tooltip, matching: find.text('Nov 19, 2026, 6:04:00 PM')), findsOneWidget);

      await mouse.moveTo(const Offset(2, 2));
      await tester.pump();
      expect(tooltip, findsNothing);
    });

    testWidgets('the tooltip stays inside the plot', (tester) async {
      await tester.pumpWidget(chart());
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      final plot = tester.getRect(find.byType(ChartPlot));
      for (final at in [plot.topRight + const Offset(-4, 12), plot.bottomLeft + const Offset(60, -40)]) {
        await mouse.moveTo(at);
        await tester.pump();
        final box = tester.getRect(tooltip);
        expect(plot.contains(box.topLeft) && plot.contains(box.bottomRight - const Offset(0.01, 0.01)), isTrue);
      }
    });

    testWidgets('touching the plot shows the tooltip until a tap elsewhere', (tester) async {
      await tester.pumpWidget(chart());
      await tester.tapAt(tester.getCenter(find.byType(ChartPlot)));
      await tester.pump();
      expect(tooltip, findsOneWidget);

      await tester.tapAt(const Offset(4, 4));
      await tester.pump();
      expect(tooltip, findsNothing);
    });

    testWidgets('the keyboard moves between points and series, and Escape hides the tooltip', (tester) async {
      await tester.pumpWidget(chart());
      // Two legend items come first, then the plot.
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(find.descendant(of: tooltip, matching: find.text('20 °C')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.descendant(of: tooltip, matching: find.text('22 °C')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(find.descendant(of: tooltip, matching: find.text('25 °C')), findsOneWidget);

      // Left from the last point skips the gap.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(find.descendant(of: tooltip, matching: find.text('21 °C')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(find.descendant(of: tooltip, matching: find.text('cell-02')), findsOneWidget);
      expect(find.descendant(of: tooltip, matching: find.text('14')), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(tooltip, findsNothing);
    });

    testWidgets('hiding the active series drops the tooltip', (tester) async {
      await tester.pumpWidget(chart());
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(tooltip, findsOneWidget);
      await tester.tap(find.text('cell-01 (°C)'));
      await tester.pump();
      expect(find.descendant(of: tooltip, matching: find.text('cell-01')), findsNothing);
    });

    testWidgets('no tooltip when it is turned off', (tester) async {
      await tester.pumpWidget(
        host(
          Chart(
            semanticLabel: 'Temperature',
            series: series,
            child: const SizedBox(width: 480, height: 256, child: ChartPlot(tooltip: false)),
          ),
        ),
      );
      await tester.tapAt(tester.getCenter(find.byType(ChartPlot)));
      await tester.pump();
      expect(tooltip, findsNothing);
    });

    testWidgets('the table lists the visible series by time', (tester) async {
      await tester.pumpWidget(chart(table: true, yFormat: (value) => '${value.toStringAsFixed(1)}!'));
      final table = find.byType(ChartTable);
      expect(find.descendant(of: table, matching: find.text('Cell temperature')), findsOneWidget);
      expect(find.descendant(of: table, matching: find.text('Time')), findsOneWidget);
      expect(find.descendant(of: table, matching: find.text('cell-01 (°C)')), findsOneWidget);
      expect(find.descendant(of: table, matching: find.text('Nov 19, 2026, 6:00:00 PM')), findsOneWidget);
      expect(find.descendant(of: table, matching: find.text('20.0!')), findsOneWidget);
      expect(tester.widget<Table>(find.descendant(of: table, matching: find.byType(Table))).children.length, 6);

      await tester.tap(find.text('cell-01 (°C)').first);
      await tester.pump();
      expect(find.descendant(of: table, matching: find.text('cell-01 (°C)')), findsNothing);
      expect(find.descendant(of: table, matching: find.text('20.0!')), findsNothing);
    });

    testWidgets('describes itself to screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(chart());
      expect(find.bySemanticsLabel('Cell temperature'), findsWidgets);
      expect(tester.getSemantics(find.byType(Chart)).value, contains('Series: cell-01 (°C), cell-02.'));
      handle.dispose();
    });

    testWidgets('draws in a tiny box and in dark mode without errors', (tester) async {
      await tester.pumpWidget(
        PrimeApp(
          theme: PrimeThemeData.dark(),
          home: Scaffold(
            body: Chart(
              semanticLabel: 'Temperature',
              series: series,
              child: const SizedBox(width: 20, height: 10, child: ChartPlot()),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    test('a point can be given in epoch milliseconds', () {
      expect(ChartPoint.millis(1795129200000, 3).x.millisecondsSinceEpoch, 1795129200000);
    });
  });
}
