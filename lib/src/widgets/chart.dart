import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_colors.dart';
import '../theme/prime_theme.dart';
import 'internal/chart_math.dart';
import 'progress.dart';

/// Formats a time for a [Chart] tick label, tooltip or table cell.
typedef ChartTimeFormat = String Function(DateTime value);

/// Formats a value for a [Chart] tick label, tooltip or table cell.
typedef ChartValueFormat = String Function(double value);

/// One point of a [ChartSeries]: a time and a value.
class ChartPoint {
  /// When the value was read.
  final DateTime x;

  /// The value. A `null` is a gap: the line breaks there and never joins
  /// across it.
  final double? y;

  const ChartPoint(this.x, this.y);

  /// A point whose time is given in milliseconds since the Unix epoch.
  ChartPoint.millis(num milliseconds, this.y) : x = DateTime.fromMillisecondsSinceEpoch(milliseconds.floor());
}

/// One line of a [Chart].
class ChartSeries {
  /// Labels the series in the legend, the tooltip and the table.
  final String name;

  /// The points to draw, in time order.
  final List<ChartPoint> points;

  /// Shown after the name in the legend, as `cell-01 (°)`, and after the
  /// value in the tooltip.
  final String? unit;

  /// The line's color. Without it the series takes the next of the seven
  /// chart colors by its position in [Chart.series], wrapping after seven.
  final Color? color;

  /// Shows a loading mark beside the series in the legend.
  final bool loading;

  /// Whether the series starts hidden. The legend toggles it, and a hidden
  /// series keeps its color and its position.
  final bool hidden;

  const ChartSeries({required this.name, required this.points, this.unit, this.color, this.loading = false, this.hidden = false});
}

// A series as the parts read it: the arithmetic's view plus its color.
class _Series {
  final ChartSeries source;
  final ChartSeriesData data;
  final Color color;

  const _Series(this.source, this.data, this.color);
}

class _ChartData {
  final String semanticLabel;
  final List<_Series> series;
  final List<ChartSeriesData> data;
  final XWindow window;
  final double? yMin;
  final double? yMax;
  final bool loading;
  final bool isEmpty;
  final Widget? empty;
  final ChartTimeFormat? xFormat;
  final ChartValueFormat? yFormat;
  final void Function(int index) toggle;

  const _ChartData({
    required this.semanticLabel,
    required this.series,
    required this.data,
    required this.window,
    required this.yMin,
    required this.yMax,
    required this.loading,
    required this.isEmpty,
    required this.empty,
    required this.xFormat,
    required this.yFormat,
    required this.toggle,
  });

  List<_Series> get visible => series.where((entry) => !entry.data.hidden).toList();
}

class _ChartScope extends InheritedWidget {
  final _ChartData data;

  const _ChartScope({required this.data, required super.child});

  static _ChartData of(BuildContext context, String part) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ChartScope>();
    assert(scope != null, '$part must be placed inside a Chart.');
    return scope!.data;
  }

  // The data is rebuilt with the chart, so every rebuild is a change.
  @override
  bool updateShouldNotify(_ChartScope oldWidget) => true;
}

/// A time-series line chart.
///
/// Give it the series and it draws the plot. To add a legend or a table, or
/// to size the plot, pass a [child] that arranges [ChartPlot], [ChartLegend]
/// and [ChartTable] however the screen needs.
///
/// ```dart
/// Chart(
///   semanticLabel: 'Cell temperature',
///   series: [
///     ChartSeries(name: 'cell-01', unit: '°C', points: readings),
///   ],
///   child: const Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     children: [
///       ChartLegend(),
///       SizedBox(height: 256, child: ChartPlot()),
///     ],
///   ),
/// )
/// ```
///
/// One y axis serves every series. Series with different units share it, and
/// the axis shows no unit of its own. When the series share a unit, add it in
/// [yFormat].
class Chart extends StatefulWidget {
  /// Names the chart for screen readers.
  final String semanticLabel;

  /// The lines to draw.
  final List<ChartSeries> series;

  /// The left end of the time axis. Left out, it comes from the data.
  final DateTime? xMin;

  /// The right end of the time axis. Left out, it comes from the data.
  final DateTime? xMax;

  /// The bottom of the value axis. Left out, it comes from the data, rounded
  /// out to the next tick.
  final double? yMin;

  /// The top of the value axis. Left out, it comes from the data, rounded out
  /// to the next tick.
  final double? yMax;

  /// Lays an overlay on the plot and keeps the last lines drawn underneath.
  /// Loading wins over the empty state.
  final bool loading;

  /// Shown in place of the plot when no series has a point. Defaults to the
  /// text "No data".
  final Widget? empty;

  /// Formats the time axis's tick labels, and the tooltip's and table's times
  /// unless they are given their own.
  final ChartTimeFormat? xFormat;

  /// Formats the value axis's tick labels, and the tooltip's and table's
  /// values unless they are given their own.
  final ChartValueFormat? yFormat;

  /// Called when the legend shows or hides a series.
  final void Function(ChartSeries series, bool hidden)? onSeriesHiddenChanged;

  /// The chart's layout: a [ChartPlot], with a [ChartLegend] or [ChartTable]
  /// around it. Defaults to a [ChartPlot] alone.
  final Widget child;

  const Chart({
    super.key,
    required this.semanticLabel,
    required this.series,
    this.xMin,
    this.xMax,
    this.yMin,
    this.yMax,
    this.loading = false,
    this.empty,
    this.xFormat,
    this.yFormat,
    this.onSeriesHiddenChanged,
    this.child = const ChartPlot(),
  });

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  // What the legend has toggled, by series name. A series not in here follows
  // its own `hidden`.
  final Map<String, bool> _hidden = {};

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A parent that changes a series' `hidden` takes the series back.
    final before = {for (final entry in oldWidget.series) entry.name: entry.hidden};
    final names = <String>{};
    for (final entry in widget.series) {
      names.add(entry.name);
      if (before[entry.name] != null && before[entry.name] != entry.hidden) _hidden.remove(entry.name);
    }
    _hidden.removeWhere((name, _) => !names.contains(name));
  }

  void _toggle(int index) {
    final source = widget.series[index];
    final next = !(_hidden[source.name] ?? source.hidden);
    setState(() => _hidden[source.name] = next);
    widget.onSeriesHiddenChanged?.call(source, next);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = PrimeTheme.of(context).brightness == Brightness.dark;
    final palette = isDark ? PrimeColors.chartSeriesDark : PrimeColors.chartSeries;

    final series = <_Series>[];
    for (var i = 0; i < widget.series.length; i++) {
      final source = widget.series[i];
      final data = ChartSeriesData(
        name: source.name,
        unit: source.unit,
        hidden: _hidden[source.name] ?? source.hidden,
        xs: [for (final point in source.points) point.x.millisecondsSinceEpoch.toDouble()],
        ys: [for (final point in source.points) point.y],
      );
      series.add(_Series(source, data, source.color ?? palette[i % palette.length]));
    }
    final data = [for (final entry in series) entry.data];
    final xMin = widget.xMin?.millisecondsSinceEpoch.toDouble();
    final xMax = widget.xMax?.millisecondsSinceEpoch.toDouble();
    final window = xDomain(domainSeries(data), min: xMin, max: xMax);

    final summary = summarizeChart(
      series: data,
      window: window,
      xMin: xMin,
      xMax: xMax,
      yMin: widget.yMin,
      yMax: widget.yMax,
      formatTime: widget.xFormat ?? defaultTimeFormat,
      formatValue: widget.yFormat ?? defaultValueFormat,
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      value: summary,
      child: _ChartScope(
        data: _ChartData(
          semanticLabel: widget.semanticLabel,
          series: series,
          data: data,
          window: window,
          yMin: widget.yMin,
          yMax: widget.yMax,
          loading: widget.loading,
          isEmpty: !hasData(data),
          empty: widget.empty,
          xFormat: widget.xFormat,
          yFormat: widget.yFormat,
          toggle: _toggle,
        ),
        child: widget.child,
      ),
    );
  }
}

// --- Plot ---

const double _tickSize = 6;
const double _tickLabelSpace = 4;
const double _yLabelGap = _tickSize + _tickLabelSpace;
const double _dotRadius = 3;
const double _pointGap = 12;
const double _defaultPlotHeight = 256;

/// The drawing area of a [Chart]: the lines, the axes, the grid and the
/// tooltip.
///
/// The plot fills the space it is given, so size it with a [SizedBox] or an
/// [Expanded]. With no height limit it is 256 tall.
///
/// Hovering or touching the plot shows the nearest point of a visible series.
/// With keyboard focus, the left and right arrows move between points, up and
/// down move between series, Home and End go to the first and last point,
/// Page Up and Page Down move by a tenth of the series, and Escape hides the
/// tooltip.
class ChartPlot extends StatefulWidget {
  /// Draws a horizontal line at each value tick.
  final bool grid;

  /// Draws the time axis and its tick labels.
  final bool xAxis;

  /// Draws the value axis and its tick labels.
  final bool yAxis;

  /// Shows the nearest point on hover, touch and keyboard focus.
  final bool tooltip;

  /// Formats the tooltip's time. Defaults to [Chart.xFormat], then a full
  /// date and time with seconds.
  final ChartTimeFormat? tooltipXFormat;

  /// Formats the tooltip's value. Defaults to [Chart.yFormat], then grouped
  /// thousands with at most three decimals.
  final ChartValueFormat? tooltipYFormat;

  /// The least width of the value axis's label column. Charts stacked in a
  /// column line up their plots by sharing one, at least as wide as the
  /// widest label.
  final double yAxisMinWidth;

  /// The tick labels' style. Its size changes how much room the axes take.
  final TextStyle? labelStyle;

  const ChartPlot({
    super.key,
    this.grid = true,
    this.xAxis = true,
    this.yAxis = true,
    this.tooltip = true,
    this.tooltipXFormat,
    this.tooltipYFormat,
    this.yAxisMinWidth = 0,
    this.labelStyle,
  });

  @override
  State<ChartPlot> createState() => _ChartPlotState();
}

// Where everything in the plot sits for one size, in the plot's own pixels.
class _PlotLayout {
  final Size size;
  final Rect area;
  final (double, double) xDomain;
  final (double, double) yDomain;
  final List<double> yTicks;
  final List<TextPainter> yLabels;
  final List<double> xTicks;
  final List<TextPainter> xLabels;

  const _PlotLayout({
    required this.size,
    required this.area,
    required this.xDomain,
    required this.yDomain,
    required this.yTicks,
    required this.yLabels,
    required this.xTicks,
    required this.xLabels,
  });

  double x(double value) => area.left + (value - xDomain.$1) / (xDomain.$2 - xDomain.$1) * area.width;
  double y(double value) => area.bottom - (value - yDomain.$1) / (yDomain.$2 - yDomain.$1) * area.height;

  void dispose() {
    for (final painter in yLabels) {
      painter.dispose();
    }
    for (final painter in xLabels) {
      painter.dispose();
    }
  }
}

class _ChartPlotState extends State<ChartPlot> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'ChartPlot');
  ActivePoint? _chosen;
  bool _shown = false;
  bool _announced = false;
  _PlotLayout? _layout;

  @override
  void dispose() {
    _focusNode.dispose();
    _layout?.dispose();
    super.dispose();
  }

  void _show(ActivePoint? point, {required bool fromKeyboard}) {
    if (point == null) return;
    if (_chosen == point && _shown && _announced == fromKeyboard) return;
    setState(() {
      _chosen = point;
      _shown = true;
      _announced = fromKeyboard;
    });
  }

  void _hide() {
    if (!_shown) return;
    setState(() {
      _shown = false;
      _announced = false;
    });
  }

  static final Map<LogicalKeyboardKey, ChartNavigationKey> _keys = {
    LogicalKeyboardKey.arrowLeft: ChartNavigationKey.left,
    LogicalKeyboardKey.arrowRight: ChartNavigationKey.right,
    LogicalKeyboardKey.arrowUp: ChartNavigationKey.up,
    LogicalKeyboardKey.arrowDown: ChartNavigationKey.down,
    LogicalKeyboardKey.home: ChartNavigationKey.home,
    LogicalKeyboardKey.end: ChartNavigationKey.end,
    LogicalKeyboardKey.pageUp: ChartNavigationKey.pageUp,
    LogicalKeyboardKey.pageDown: ChartNavigationKey.pageDown,
  };

  KeyEventResult _onKey(_ChartData chart, ActivePoint? active, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (!_shown) return KeyEventResult.ignored;
      _hide();
      return KeyEventResult.handled;
    }
    final key = _keys[event.logicalKey];
    if (key == null) return KeyEventResult.ignored;
    _show(active == null ? firstPoint(chart.data, chart.window) : stepPoint(chart.data, active, key, chart.window), fromKeyboard: true);
    return KeyEventResult.handled;
  }

  void _onPointer(_ChartData chart, Offset position) {
    final layout = _layout;
    if (layout == null) return;
    _show(
      nearestPoint(chart.data, position.dx, position.dy, xToPixel: layout.x, yToPixel: layout.y, window: chart.window),
      fromKeyboard: false,
    );
  }

  TextPainter _label(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
  }

  _PlotLayout _computeLayout(_ChartData chart, Size size, TextStyle style) {
    final probe = _label('0', style);
    final lineHeight = probe.height;
    probe.dispose();

    // The y axis reserves half a label above and below, and the x axis a row
    // of labels below. Each side takes the larger of what the parts ask for.
    final halfLabel = widget.yAxis ? (lineHeight / 2).ceilToDouble() : 0.0;
    final xRow = widget.xAxis ? lineHeight.ceilToDouble() + _tickSize : 0.0;
    final top = halfLabel;
    final bottom = math.max(xRow, halfLabel);
    final height = math.max(0.0, size.height - top - bottom);

    final yCount = yTickCount(height);
    final yDom = yDomain(domainSeries(chart.data), min: chart.yMin, max: chart.yMax, tickCount: yCount);
    final yTicks = linearTicks(yDom.$1, yDom.$2, yCount);
    final decimals = tickDecimals(yDom.$1, yDom.$2, yCount);
    final yFormat = chart.yFormat ?? (double value) => formatFixed(value, decimals, minus: '−');
    final yLabels = widget.yAxis ? [for (final tick in yTicks) _label(yFormat(tick), style)] : <TextPainter>[];
    final labelWidth = yLabels.fold(widget.yAxisMinWidth, (width, painter) => math.max(width, painter.width));
    final column = widget.yAxis ? labelWidth.ceilToDouble() + _yLabelGap : 0.0;

    // The x ticks come from the domain and the room the y axis leaves, never
    // from the drawing width, which the edge labels' overhang narrows.
    final xDom = chart.window;
    final xCount = xTickCount(size.width - column);
    final xTimes = widget.xAxis || widget.grid ? timeTicks(xDom.$1, xDom.$2, xCount) : const <DateTime>[];
    final xFormat = chart.xFormat ?? timeTickLabel;
    final xTicks = [for (final tick in xTimes) tick.millisecondsSinceEpoch.toDouble()];
    final xLabels = widget.xAxis ? [for (final tick in xTimes) _label(xFormat(tick), style)] : <TextPainter>[];

    var left = column;
    var right = 0.0;
    if (xLabels.isNotEmpty) {
      double fraction(double tick) => (tick - xDom.$1) / (xDom.$2 - xDom.$1);
      final overhang = edgeOverhang(
        containerWidth: size.width,
        left: column,
        right: 0,
        firstFraction: fraction(xTicks.first),
        firstWidth: xLabels.first.width,
        lastFraction: fraction(xTicks.last),
        lastWidth: xLabels.last.width,
      );
      left = math.max(column, overhang.left);
      right = math.max(0.0, overhang.right);
    }
    final width = math.max(0.0, size.width - left - right);

    return _PlotLayout(
      size: size,
      area: Rect.fromLTWH(left, top, width, height),
      xDomain: xDom,
      yDomain: yDom,
      yTicks: yTicks,
      yLabels: yLabels,
      xTicks: xTicks,
      xLabels: xLabels,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chart = _ChartScope.of(context, 'ChartPlot');
    final theme = PrimeTheme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final labelStyle = theme.textTheme.bodySmall
        .copyWith(fontSize: 12, height: 1.33, color: isDark ? PrimeColors.chartAxisLabelDark : PrimeColors.chartAxisLabel)
        .merge(widget.labelStyle);

    final isInteractive = widget.tooltip && !chart.isEmpty && firstPoint(chart.data, chart.window) != null;
    final chosen = _chosen;
    final active = chosen != null && isAvailable(chart.data, chosen, chart.window) ? chosen : null;
    final isVisible = _shown && isInteractive && active != null;

    final formatTime = widget.tooltipXFormat ?? chart.xFormat ?? defaultTimeFormat;
    final formatValue = widget.tooltipYFormat ?? chart.yFormat ?? defaultValueFormat;

    Widget plot = LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : 400,
          constraints.hasBoundedHeight ? constraints.maxHeight : _defaultPlotHeight,
        );
        _layout?.dispose();
        final layout = _layout = _computeLayout(chart, size, labelStyle);

        _Reading? reading;
        if (isVisible) {
          final series = chart.series[active.series];
          final x = series.data.xs[active.index];
          final y = series.data.ys[active.index]!;
          final value = formatValue(y);
          reading = _Reading(
            name: series.data.name,
            color: series.color,
            position: Offset(layout.x(x), layout.y(y)),
            time: formatTime(DateTime.fromMillisecondsSinceEpoch(x.floor())),
            value: series.data.unit == null || series.data.unit!.isEmpty ? value : '$value ${series.data.unit}',
          );
        }

        return SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _PlotPainter(
                    layout: layout,
                    series: chart.isEmpty ? const [] : chart.series,
                    isEmpty: chart.isEmpty,
                    grid: widget.grid,
                    xAxis: widget.xAxis,
                    yAxis: widget.yAxis,
                    gridColor: isDark ? PrimeColors.chartGridDark : PrimeColors.chartGrid,
                    axisColor: isDark ? PrimeColors.chartAxisDark : PrimeColors.chartAxis,
                    marker: reading,
                    markerBorder: colors.surfaceBase,
                  ),
                ),
              ),
              if (reading != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: CustomSingleChildLayout(
                        delegate: _ReadoutDelegate(area: layout.area, point: reading.position),
                        child: _Readout(reading: reading),
                      ),
                    ),
                  ),
                ),
              if (chart.loading)
                Positioned.fromRect(
                  rect: layout.area,
                  child: ColoredBox(key: const ValueKey('chart-loading'), color: colors.surfaceBase.withValues(alpha: 0.6)),
                )
              else if (chart.isEmpty)
                Positioned.fromRect(
                  rect: layout.area,
                  child: Center(
                    key: const ValueKey('chart-empty'),
                    child: DefaultTextStyle(
                      style: theme.textTheme.bodySmall.copyWith(fontSize: 14, color: colors.textSecondary),
                      child: chart.empty ?? const Text('No data'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (!isInteractive) return plot;

    final showFocusRing = _focusNode.hasFocus && FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    plot = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(color: showFocusRing ? colors.inputFocus : const Color(0x00000000), width: 2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: plot,
    );

    final announcement = isVisible && _announced
        ? () {
            final series = chart.series[active.series].data;
            final value = formatValue(series.ys[active.index]!);
            final time = formatTime(DateTime.fromMillisecondsSinceEpoch(series.xs[active.index].floor()));
            return '${series.name}, $time, ${series.unit == null || series.unit!.isEmpty ? value : '$value ${series.unit}'}';
          }()
        : '';

    return Semantics(
      container: true,
      focusable: true,
      liveRegion: true,
      label: chart.semanticLabel,
      value: announcement,
      hint:
          'Left and right arrows move between points. Up and down arrows move between series. '
          'Home and End go to the first and last point. Page Up and Page Down move by a tenth of the series. '
          'Escape hides the tooltip.',
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (focused) {
          if (focused) {
            _show(active ?? firstPoint(chart.data, chart.window), fromKeyboard: true);
            setState(() {});
          } else {
            _hide();
            setState(() {});
          }
        },
        onKeyEvent: (node, event) => _onKey(chart, active, event),
        child: TapRegion(
          onTapOutside: (_) => _hide(),
          child: MouseRegion(
            onHover: (event) => _onPointer(chart, event.localPosition),
            onExit: (_) {
              if (!_focusNode.hasFocus) _hide();
            },
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) => _onPointer(chart, event.localPosition),
              onPointerMove: (event) => _onPointer(chart, event.localPosition),
              child: plot,
            ),
          ),
        ),
      ),
    );
  }
}

class _Reading {
  final String name;
  final Color color;
  final Offset position;
  final String time;
  final String value;

  const _Reading({required this.name, required this.color, required this.position, required this.time, required this.value});
}

class _PlotPainter extends CustomPainter {
  final _PlotLayout layout;
  final List<_Series> series;
  final bool isEmpty;
  final bool grid;
  final bool xAxis;
  final bool yAxis;
  final Color gridColor;
  final Color axisColor;
  final _Reading? marker;
  final Color markerBorder;

  const _PlotPainter({
    required this.layout,
    required this.series,
    required this.isEmpty,
    required this.grid,
    required this.xAxis,
    required this.yAxis,
    required this.gridColor,
    required this.axisColor,
    required this.marker,
    required this.markerBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isEmpty) return;
    final area = layout.area;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;

    if (grid) {
      for (final tick in layout.yTicks) {
        final y = layout.y(tick);
        canvas.drawLine(Offset(area.left, y), Offset(area.right, y), gridPaint);
      }
    }

    if (yAxis) {
      canvas.drawLine(area.topLeft, area.bottomLeft, axisPaint);
      for (var i = 0; i < layout.yTicks.length; i++) {
        final y = layout.y(layout.yTicks[i]);
        canvas.drawLine(Offset(area.left - _tickSize, y), Offset(area.left, y), axisPaint);
        final label = layout.yLabels[i];
        label.paint(canvas, Offset(area.left - _yLabelGap - label.width, y - label.height / 2));
      }
    }

    if (xAxis) {
      canvas.drawLine(area.bottomLeft, area.bottomRight, axisPaint);
      for (var i = 0; i < layout.xLabels.length; i++) {
        final x = layout.x(layout.xTicks[i]);
        canvas.drawLine(Offset(x, area.bottom), Offset(x, area.bottom + _tickSize), axisPaint);
        final label = layout.xLabels[i];
        label.paint(canvas, Offset(x - label.width / 2, area.bottom + _tickSize));
      }
    }

    // Lines are clipped to the plot area, so data a bound cuts off never
    // draws past the axes. The extra pixel is half the stroke, so a line
    // along an edge keeps its full width.
    canvas.save();
    canvas.clipRect(area.inflate(1));
    for (final entry in series) {
      if (entry.data.hidden) continue;
      final stroke = Paint()
        ..color = entry.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round;
      final fill = Paint()..color = entry.color;

      // Runs of consecutive drawable points. A gap ends one run and starts
      // the next, and a run of one draws as a dot so it stays visible.
      final path = Path();
      var run = <Offset>[];
      void flush() {
        if (run.length == 1) {
          canvas.drawCircle(run.first, _dotRadius, fill);
        } else if (run.length > 1) {
          path.addPolygon(run, false);
        }
        run = <Offset>[];
      }

      final data = entry.data;
      for (var i = 0; i < data.length; i++) {
        final y = data.ys[i];
        final px = layout.x(data.xs[i]);
        final py = y == null ? double.nan : layout.y(y);
        if (px.isFinite && py.isFinite) {
          run.add(Offset(px, py));
        } else {
          flush();
        }
      }
      flush();
      canvas.drawPath(path, stroke);
    }
    canvas.restore();

    final marker = this.marker;
    if (marker != null) {
      canvas.drawCircle(marker.position, 5, Paint()..color = markerBorder);
      canvas.drawCircle(marker.position, 3, Paint()..color = marker.color);
    }
  }

  @override
  bool shouldRepaint(_PlotPainter oldDelegate) => true;
}

// Places the readout right of and above the point, flipped to the other side
// where it would leave the plot area.
class _ReadoutDelegate extends SingleChildLayoutDelegate {
  final Rect area;
  final Offset point;

  const _ReadoutDelegate({required this.area, required this.point});

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final right = point.dx + _pointGap;
    final left = right + childSize.width > area.right ? point.dx - _pointGap - childSize.width : right;
    final above = point.dy - _pointGap - childSize.height;
    final top = above < area.top ? point.dy + _pointGap : above;
    return Offset(
      left.clamp(area.left, math.max(area.left, area.right - childSize.width)),
      top.clamp(area.top, math.max(area.top, area.bottom - childSize.height)),
    );
  }

  @override
  bool shouldRelayout(_ReadoutDelegate oldDelegate) => area != oldDelegate.area || point != oldDelegate.point;
}

class _Readout extends StatelessWidget {
  final _Reading reading;

  const _Readout({required this.reading});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final style = theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.33, color: theme.colorScheme.actionPrimaryFg);
    return Container(
      key: const ValueKey('chart-tooltip'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: theme.colorScheme.actionPrimaryBg, borderRadius: BorderRadius.circular(2)),
      child: DefaultTextStyle(
        style: style,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: reading.color, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 6),
                Text(reading.name),
              ],
            ),
            Text(reading.time),
            Text(reading.value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// --- Legend ---

/// The legend of a [Chart]: one toggle per series, with its color, name, unit
/// and loading mark. Tapping one, or pressing Space or Enter on it, shows or
/// hides the series.
///
/// Place it anywhere inside [Chart.child]. It adds no margin of its own.
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final chart = _ChartScope.of(context, 'ChartLegend');
    return Wrap(
      spacing: 12,
      children: [for (var i = 0; i < chart.series.length; i++) _LegendItem(series: chart.series[i], onToggle: () => chart.toggle(i))],
    );
  }
}

class _LegendItem extends StatefulWidget {
  final _Series series;
  final VoidCallback onToggle;

  const _LegendItem({required this.series, required this.onToggle});

  @override
  State<_LegendItem> createState() => _LegendItemState();
}

class _LegendItemState extends State<_LegendItem> {
  bool _focusRing = false;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final colors = theme.colorScheme;
    final series = widget.series;
    final hidden = series.data.hidden;
    final textColor = hidden ? colors.textTertiary : colors.textPrimary;

    return Semantics(
      button: true,
      toggled: !hidden,
      label: series.source.loading ? '${series.data.label}, Loading' : series.data.label,
      excludeSemantics: true,
      onTap: widget.onToggle,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) => setState(() => _focusRing = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onToggle();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggle,
          child: Container(
            constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            foregroundDecoration: BoxDecoration(
              border: Border.all(color: _focusRing ? colors.inputFocus : const Color(0x00000000), width: 2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: hidden ? null : series.color,
                    border: Border.all(color: series.color, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  series.data.label,
                  style: theme.textTheme.bodySmall.copyWith(
                    fontSize: 12,
                    height: 1.33,
                    color: textColor,
                    decoration: hidden ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: textColor,
                  ),
                ),
                if (series.source.loading) ...[const SizedBox(width: 6), Progress(size: 12, color: textColor)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Table ---

/// The visible series of a [Chart] as a table, with a Time column and one
/// column per series, labeled like the legend.
///
/// Rows merge the series on time, inside the chart's time range. A series
/// with no value at a row's time leaves an empty cell. Place it anywhere
/// inside [Chart.child]. Columns are as wide as their content, so wrap it in
/// a horizontal scroll view when there are many series.
class ChartTable extends StatelessWidget {
  /// Shown above the table. Defaults to [Chart.semanticLabel].
  final String? caption;

  const ChartTable({super.key, this.caption});

  @override
  Widget build(BuildContext context) {
    final chart = _ChartScope.of(context, 'ChartTable');
    final theme = PrimeTheme.of(context);
    final colors = theme.colorScheme;
    final visible = chart.visible;
    final rows = mergeSeriesRows([for (final entry in visible) entry.data], chart.window);
    final formatTime = chart.xFormat ?? defaultTimeFormat;
    final formatValue = chart.yFormat ?? defaultValueFormat;
    final base = theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.33, color: colors.textPrimary);

    Widget cell(String text, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(text, style: style ?? base),
    );
    final header = base.copyWith(fontWeight: FontWeight.w500);
    final divider = BoxDecoration(
      border: Border(top: BorderSide(color: colors.borderSubtle)),
    );

    return Semantics(
      container: true,
      label: caption ?? chart.semanticLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caption ?? chart.semanticLabel, style: base),
          Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                children: [
                  cell('Time', style: header),
                  for (final entry in visible) cell(entry.data.label, style: header),
                ],
              ),
              for (final row in rows)
                TableRow(
                  decoration: divider,
                  children: [
                    cell(
                      formatTime(DateTime.fromMillisecondsSinceEpoch(row.time.floor())),
                      style: base.copyWith(color: colors.textTertiary),
                    ),
                    for (final value in row.values) cell(value == null ? '' : formatValue(value)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
