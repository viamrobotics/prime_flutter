// The arithmetic behind [Chart]: tick generation, domains, point search and
// key steps, the table rows and the summary text. Nothing here touches a
// widget, so it is tested directly.
//
// The linear and time ticks follow d3-array and d3-scale, which the web
// library's chart is built on, so both charts put ticks in the same places.
import 'dart:math' as math;

// --- Series as the arithmetic reads it ---

/// One series, with each point's x already placed on the time scale as epoch
/// milliseconds.
class ChartSeriesData {
  final String name;
  final String? unit;
  final bool hidden;
  final List<double> xs;
  final List<double?> ys;

  const ChartSeriesData({required this.name, this.unit, this.hidden = false, required this.xs, required this.ys});

  int get length => xs.length;

  /// Whether the point at [index] can be drawn: it has a finite x and y.
  bool isPlaced(int index) {
    final y = ys[index];
    return y != null && y.isFinite && xs[index].isFinite;
  }

  /// The series as the legend names it, `cell-01 (°)`.
  String get label => unit == null || unit!.isEmpty ? name : '$name ($unit)';
}

/// The drawn x domain, in either order. Point search and key steps treat a
/// point outside it like a gap.
typedef XWindow = (double, double);

bool isInsideWindow(double x, XWindow window) {
  final (start, end) = window;
  return x >= math.min(start, end) && x <= math.max(start, end);
}

// --- Linear ticks (d3-array) ---

final double _e10 = math.sqrt(50);
final double _e5 = math.sqrt(10);
final double _e2 = math.sqrt(2);

// JavaScript's Math.round, which rounds a half up. Dart rounds it away from zero.
double _round(double value) => (value + 0.5).floorToDouble();

(double, double, double) _tickSpec(double start, double stop, double count) {
  final step = (stop - start) / math.max(0, count);
  final power = (math.log(step) / math.ln10).floor();
  final error = step / math.pow(10, power);
  final factor = error >= _e10
      ? 10
      : error >= _e5
      ? 5
      : error >= _e2
      ? 2
      : 1;
  double i1, i2, inc;
  if (power < 0) {
    inc = math.pow(10, -power) / factor;
    i1 = _round(start * inc);
    i2 = _round(stop * inc);
    if (i1 / inc < start) i1 += 1;
    if (i2 / inc > stop) i2 -= 1;
    inc = -inc;
  } else {
    inc = (math.pow(10, power) * factor).toDouble();
    i1 = _round(start / inc);
    i2 = _round(stop / inc);
    if (i1 * inc < start) i1 += 1;
    if (i2 * inc > stop) i2 -= 1;
  }
  if (i2 < i1 && 0.5 <= count && count < 2) return _tickSpec(start, stop, count * 2);
  return (i1, i2, inc);
}

bool _canTick(double start, double stop, num count) => start.isFinite && stop.isFinite && count > 0 && start != stop;

/// About [count] round values between [start] and [stop], both included when
/// they are round themselves.
List<double> linearTicks(double start, double stop, int count) {
  if (!start.isFinite || !stop.isFinite || count <= 0) return const [];
  if (start == stop) return [start];
  final reverse = stop < start;
  final (i1, i2, inc) = reverse ? _tickSpec(stop, start, count.toDouble()) : _tickSpec(start, stop, count.toDouble());
  if (!(i2 >= i1)) return const [];
  final n = (i2 - i1 + 1).toInt();
  final ticks = List<double>.generate(n, (i) => inc < 0 ? (i1 + i) / -inc : (i1 + i) * inc);
  return reverse ? ticks.reversed.toList() : ticks;
}

/// The distance between two ticks of [linearTicks].
double tickStep(double start, double stop, int count) {
  if (!_canTick(start, stop, count)) return 0;
  final reverse = stop < start;
  final inc = reverse ? _tickSpec(stop, start, count.toDouble()).$3 : _tickSpec(start, stop, count.toDouble()).$3;
  return (reverse ? -1 : 1) * (inc < 0 ? 1 / -inc : inc);
}

/// Rounds a domain out to the ticks [linearTicks] would draw for [count].
(double, double) niceLinear(double start, double stop, int count) {
  if (!_canTick(start, stop, count) || stop < start) return (start, stop);
  double? previous;
  for (var i = 0; i < 10; i++) {
    final step = _tickSpec(start, stop, count.toDouble()).$3;
    if (step == previous) break;
    if (step > 0) {
      start = (start / step).floorToDouble() * step;
      stop = (stop / step).ceilToDouble() * step;
    } else if (step < 0) {
      start = (start * step).ceilToDouble() / step;
      stop = (stop * step).floorToDouble() / step;
    } else {
      break;
    }
    previous = step;
  }
  return (start, stop);
}

int _exponent(double value) => int.parse(value.abs().toStringAsExponential().split('e')[1]);

/// How many decimals the ticks of [linearTicks] need.
int tickDecimals(double start, double stop, int count) {
  final step = tickStep(start, stop, count).abs();
  if (step == 0 || !step.isFinite) return 0;
  return math.max(0, -_exponent(step));
}

String _group(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// [value] with exactly [decimals] decimals and grouped thousands, `12,345.60`.
/// Tick labels pass the true minus sign, `−`, as [minus].
String formatFixed(double value, int decimals, {String minus = '-'}) {
  if (!value.isFinite) return value.toString();
  var text = value.abs().toStringAsFixed(decimals);
  final isZero = double.parse(text) == 0;
  final dot = text.indexOf('.');
  text = dot < 0 ? _group(text) : '${_group(text.substring(0, dot))}${text.substring(dot)}';
  return value < 0 && !isZero ? '$minus$text' : text;
}

/// The value format used when none is given: grouped thousands and at most
/// three decimals, `1,234.5`.
String defaultValueFormat(double value) {
  if (!value.isFinite) return value.toString();
  var text = formatFixed(value, 3);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    if (text.endsWith('.')) text = text.substring(0, text.length - 1);
  }
  return text;
}

// --- Time ticks (d3-time, d3-scale) ---

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _two(int value) => value.toString().padLeft(2, '0');
int _hour12(DateTime value) => value.hour % 12 == 0 ? 12 : value.hour % 12;
String _period(DateTime value) => value.hour < 12 ? 'AM' : 'PM';
String _shortMonth(DateTime value) => _monthNames[value.month - 1].substring(0, 3);

/// The time format used when none is given, a full date and time with
/// seconds: `Nov 19, 2026, 6:03:21 PM`.
String defaultTimeFormat(DateTime value) {
  final local = value.toLocal();
  return '${_shortMonth(local)} ${local.day}, ${local.year}, ${_hour12(local)}:${_two(local.minute)}:${_two(local.second)} ${_period(local)}';
}

enum _Unit { second, minute, hour, day, week, month, year }

const double _secondMs = 1000;
const double _minuteMs = 60 * _secondMs;
const double _hourMs = 60 * _minuteMs;
const double _dayMs = 24 * _hourMs;
const double _weekMs = 7 * _dayMs;
const double _monthMs = 30 * _dayMs;
const double _yearMs = 365 * _dayMs;

const List<(_Unit, int, double)> _tickIntervals = [
  (_Unit.second, 1, _secondMs),
  (_Unit.second, 5, 5 * _secondMs),
  (_Unit.second, 15, 15 * _secondMs),
  (_Unit.second, 30, 30 * _secondMs),
  (_Unit.minute, 1, _minuteMs),
  (_Unit.minute, 5, 5 * _minuteMs),
  (_Unit.minute, 15, 15 * _minuteMs),
  (_Unit.minute, 30, 30 * _minuteMs),
  (_Unit.hour, 1, _hourMs),
  (_Unit.hour, 3, 3 * _hourMs),
  (_Unit.hour, 6, 6 * _hourMs),
  (_Unit.hour, 12, 12 * _hourMs),
  (_Unit.day, 1, _dayMs),
  (_Unit.day, 2, 2 * _dayMs),
  (_Unit.week, 1, _weekMs),
  (_Unit.month, 1, _monthMs),
  (_Unit.month, 3, 3 * _monthMs),
  (_Unit.year, 1, _yearMs),
];

DateTime _fromMs(double ms) => DateTime.fromMillisecondsSinceEpoch(ms.floor());

DateTime _floor(_Unit unit, DateTime t) {
  switch (unit) {
    case _Unit.second:
      return t.subtract(Duration(milliseconds: t.millisecond, microseconds: t.microsecond));
    case _Unit.minute:
      return t.subtract(Duration(seconds: t.second, milliseconds: t.millisecond, microseconds: t.microsecond));
    case _Unit.hour:
      return t.subtract(Duration(minutes: t.minute, seconds: t.second, milliseconds: t.millisecond, microseconds: t.microsecond));
    case _Unit.day:
      return DateTime(t.year, t.month, t.day);
    case _Unit.week:
      return DateTime(t.year, t.month, t.day - t.weekday % 7);
    case _Unit.month:
      return DateTime(t.year, t.month);
    case _Unit.year:
      return DateTime(t.year);
  }
}

DateTime _next(_Unit unit, DateTime t) {
  switch (unit) {
    case _Unit.second:
      return t.add(const Duration(seconds: 1));
    case _Unit.minute:
      return t.add(const Duration(minutes: 1));
    case _Unit.hour:
      return t.add(const Duration(hours: 1));
    case _Unit.day:
      return DateTime(t.year, t.month, t.day + 1);
    case _Unit.week:
      return DateTime(t.year, t.month, t.day + 7);
    case _Unit.month:
      return DateTime(t.year, t.month + 1);
    case _Unit.year:
      return DateTime(t.year + 1);
  }
}

int _field(_Unit unit, DateTime t) {
  switch (unit) {
    case _Unit.second:
      return t.second;
    case _Unit.minute:
      return t.minute;
    case _Unit.hour:
      return t.hour;
    case _Unit.day:
      return t.day - 1;
    case _Unit.week:
      return 0;
    case _Unit.month:
      return t.month - 1;
    case _Unit.year:
      return t.year;
  }
}

/// About [count] round local times between [startMs] and [stopMs], in epoch
/// milliseconds.
List<DateTime> timeTicks(double startMs, double stopMs, int count) {
  if (!startMs.isFinite || !stopMs.isFinite || count <= 0) return const [];
  final reverse = stopMs < startMs;
  final lo = reverse ? stopMs : startMs;
  final hi = reverse ? startMs : stopMs;
  final target = (hi - lo) / count;

  // The first interval longer than the target.
  var i = 0;
  while (i < _tickIntervals.length && _tickIntervals[i].$3 <= target) {
    i++;
  }

  List<DateTime> ticks;
  if (i == 0) {
    // Under a second apart: plain round milliseconds.
    final step = math.max(tickStep(lo, hi, count), 1.0);
    ticks = [for (var t = (lo / step).ceilToDouble() * step; t <= hi; t += step) _fromMs(t)];
  } else if (i == _tickIntervals.length) {
    final step = math.max(1, tickStep(lo / _yearMs, hi / _yearMs, count).floor());
    final first = _fromMs(lo);
    var year = (first.year / step).floor() * step;
    ticks = [];
    for (var guard = 0; guard < 10000; guard++, year += step) {
      final tick = DateTime(year);
      final ms = tick.millisecondsSinceEpoch;
      if (ms > hi) break;
      if (ms >= lo) ticks.add(tick);
    }
  } else {
    final (unit, step, _) = target / _tickIntervals[i - 1].$3 < _tickIntervals[i].$3 / target ? _tickIntervals[i - 1] : _tickIntervals[i];
    ticks = [];
    var tick = _floor(unit, _fromMs(lo));
    for (var guard = 0; guard < 100000; guard++) {
      final ms = tick.millisecondsSinceEpoch;
      if (ms > hi) break;
      if (ms >= lo && _field(unit, tick) % step == 0) ticks.add(tick);
      tick = _next(unit, tick);
    }
  }
  return reverse ? ticks.reversed.toList() : ticks;
}

bool _isFloorOf(_Unit unit, DateTime t) => _floor(unit, t).isAtSameMomentAs(t);

/// Labels a time tick by the coarsest unit it sits on: `2026` for a year
/// start, `November` for a month start, `Nov 22` for a week start, `Sat 21`
/// for a day start, `06 PM` for an hour, `06:30` for a minute, `:15` for a
/// second and `.250` below that.
String timeTickLabel(DateTime value) {
  final t = value.toLocal();
  if (!_isFloorOf(_Unit.second, t)) return '.${t.millisecond.toString().padLeft(3, '0')}';
  if (!_isFloorOf(_Unit.minute, t)) return ':${_two(t.second)}';
  if (!_isFloorOf(_Unit.hour, t)) return '${_two(_hour12(t))}:${_two(t.minute)}';
  if (!_isFloorOf(_Unit.day, t)) return '${_two(_hour12(t))} ${_period(t)}';
  if (!_isFloorOf(_Unit.month, t)) {
    return _isFloorOf(_Unit.week, t) ? '${_shortMonth(t)} ${_two(t.day)}' : '${_dayNames[t.weekday - 1]} ${_two(t.day)}';
  }
  if (!_isFloorOf(_Unit.year, t)) return _monthNames[t.month - 1];
  return t.year.toString();
}

// --- Tick counts and the x axis's edge overhang ---

const double _xTickSpacing = 80;
const double _yTickSpacing = 40;
const int _minTickCount = 2;

int xTickCount(double width) => math.max(_minTickCount, width.isFinite ? (width / _xTickSpacing).floor() : _minTickCount);
int yTickCount(double height) => math.max(_minTickCount, height.isFinite ? (height / _yTickSpacing).floor() : _minTickCount);

// Edge labels wider than the box can only overflow, so the overhang takes at
// most this share of the room the other parts leave.
const double _maxOverhangShare = 0.5;

/// The least padding that keeps the first tick label's left edge and the last
/// label's right edge inside a box [containerWidth] wide, given the padding
/// the other parts already reserve. A fraction is the tick's place along the
/// drawing width, from 0 to 1.
({double left, double right}) edgeOverhang({
  required double containerWidth,
  required double left,
  required double right,
  required double firstFraction,
  required double firstWidth,
  required double lastFraction,
  required double lastWidth,
}) {
  const none = (left: 0.0, right: 0.0);
  final fromRight = 1 - lastFraction;
  final firstHalf = firstWidth / 2;
  final lastHalf = lastWidth / 2;
  if (![firstFraction, fromRight, firstHalf, lastHalf].every((value) => value.isFinite)) return none;

  double leftFor(double right) =>
      firstFraction < 1 ? (firstHalf - firstFraction * (containerWidth - right)) / (1 - firstFraction) : double.negativeInfinity;
  double rightFor(double left) =>
      fromRight < 1 ? (lastHalf - fromRight * (containerWidth - left)) / (1 - fromRight) : double.negativeInfinity;

  final spread = lastFraction - firstFraction;
  final bothBinding = spread > 0
      ? ((firstHalf - firstFraction * containerWidth) * (1 - fromRight) + firstFraction * (lastHalf - fromRight * containerWidth)) / spread
      : double.negativeInfinity;

  final wantLeft = [left, leftFor(right), bothBinding].reduce(math.max);
  final wantRight = math.max(right, rightFor(wantLeft));

  final extraLeft = wantLeft - left;
  final extraRight = wantRight - right;
  final room = math.max(0.0, containerWidth - left - right);
  final extra = extraLeft + extraRight;
  final scale = extra > 0 ? math.min(1.0, _maxOverhangShare * room / extra) : 0.0;
  return (left: extraLeft > 0 ? left + extraLeft * scale : 0.0, right: extraRight > 0 ? right + extraRight * scale : 0.0);
}

// --- Domains ---

const (double, double) _emptyDomain = (0, 1);

(double, double) _extent(Iterable<double> values) {
  var min = double.infinity;
  var max = double.negativeInfinity;
  for (final value in values) {
    if (!value.isFinite) continue;
    if (value < min) min = value;
    if (value > max) max = value;
  }
  return min > max ? _emptyDomain : (min, max);
}

// A single value would collapse the scale, so an end that came from the data
// is widened. A given end stays where it was given.
(double, double) _widen((double, double) domain, {bool isMinGiven = false, bool isMaxGiven = false}) {
  final (min, max) = domain;
  if (min != max) return domain;
  return (isMinGiven ? min : min - 1, isMaxGiven ? max : max + 1);
}

/// The series the axes are fitted to. Hidden series keep the axes put, so
/// with none visible every series counts.
List<ChartSeriesData> domainSeries(List<ChartSeriesData> series) {
  final visible = series.where((entry) => !entry.hidden).toList();
  return visible.isEmpty ? series : visible;
}

/// Whether any series, hidden or not, has a point to draw.
bool hasData(List<ChartSeriesData> series) {
  for (final entry in series) {
    for (var i = 0; i < entry.length; i++) {
      if (entry.isPlaced(i)) return true;
    }
  }
  return false;
}

(double, double) xDomain(List<ChartSeriesData> series, {double? min, double? max}) {
  final (dataMin, dataMax) = _extent(series.expand((entry) => entry.xs));
  return _widen((min ?? dataMin, max ?? dataMax), isMinGiven: min != null, isMaxGiven: max != null);
}

/// [tickCount] is the y axis's tick count, so a rounded end lands on a drawn
/// tick.
(double, double) yDomain(List<ChartSeriesData> series, {double? min, double? max, required int tickCount}) {
  Iterable<double> values() sync* {
    for (final entry in series) {
      for (var i = 0; i < entry.length; i++) {
        if (entry.isPlaced(i)) yield entry.ys[i]!;
      }
    }
  }

  final (dataMin, dataMax) = _widen(_extent(values()));
  final (niceMin, niceMax) = niceLinear(dataMin, dataMax, tickCount);
  return _widen((min ?? niceMin, max ?? niceMax), isMinGiven: min != null, isMaxGiven: max != null);
}

// --- Point search and key steps ---

/// One point of one series: the series' index in the chart and the point's
/// index in the series.
typedef ActivePoint = ({int series, int index});

enum ChartNavigationKey { left, right, up, down, home, end, pageUp, pageDown }

const int _pageFraction = 10;

bool _isDrawable(ChartSeriesData series, int index, XWindow window) {
  if (index < 0 || index >= series.length || !series.isPlaced(index)) return false;
  return isInsideWindow(series.xs[index], window);
}

List<int> _drawableIndices(ChartSeriesData series, XWindow window) => [
  for (var i = 0; i < series.length; i++)
    if (_isDrawable(series, i, window)) i,
];

bool _hasPoint(ChartSeriesData series, XWindow window) {
  if (series.hidden) return false;
  for (var i = 0; i < series.length; i++) {
    if (_isDrawable(series, i, window)) return true;
  }
  return false;
}

// Binary search for the first point at or after `target`, then a walk outward
// past gaps. `position` maps a point's index to the number compared with
// `target`, and must rise with the index.
int? _nearestIndex(ChartSeriesData series, double target, double Function(int index) position, XWindow window) {
  final placed = [
    for (var i = 0; i < series.length; i++)
      if (series.xs[i].isFinite) i,
  ];
  var low = 0;
  var high = placed.length;
  while (low < high) {
    final middle = (low + high) >> 1;
    if (position(placed[middle]) < target) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  final split = low < placed.length ? placed[low] : series.length;
  var before = split - 1;
  while (before >= 0 && !_isDrawable(series, before, window)) {
    before -= 1;
  }
  var after = split;
  while (after < series.length && !_isDrawable(series, after, window)) {
    after += 1;
  }

  int? best;
  for (final index in [before, after]) {
    if (index < 0 || index >= series.length) continue;
    if (best == null || (position(index) - target).abs() < (position(best) - target).abs()) best = index;
  }
  return best;
}

/// Whether [active] still names a drawable point of a visible series.
bool isAvailable(List<ChartSeriesData> series, ActivePoint active, XWindow window) {
  if (active.series < 0 || active.series >= series.length) return false;
  final entry = series[active.series];
  return !entry.hidden && _isDrawable(entry, active.index, window);
}

/// The first drawable point of the first visible series that has one.
ActivePoint? firstPoint(List<ChartSeriesData> series, XWindow window) {
  for (var s = 0; s < series.length; s++) {
    if (!_hasPoint(series[s], window)) continue;
    return (series: s, index: _drawableIndices(series[s], window).first);
  }
  return null;
}

/// The point nearest a pointer at ([pointerX], [pointerY]). Each visible
/// series offers its point nearest in x, and the closest of those by pixel
/// distance wins. [xToPixel] and [yToPixel] place a point in the pointer's
/// coordinates.
ActivePoint? nearestPoint(
  List<ChartSeriesData> series,
  double pointerX,
  double pointerY, {
  required double Function(double x) xToPixel,
  required double Function(double y) yToPixel,
  required XWindow window,
}) {
  if (!pointerX.isFinite || !pointerY.isFinite) return null;
  ActivePoint? best;
  var bestDistance = double.infinity;
  for (var s = 0; s < series.length; s++) {
    final entry = series[s];
    if (entry.hidden) continue;
    final index = _nearestIndex(entry, pointerX, (i) => xToPixel(entry.xs[i]), window);
    if (index == null) continue;
    final dx = xToPixel(entry.xs[index]) - pointerX;
    final dy = yToPixel(entry.ys[index] ?? double.nan) - pointerY;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance < bestDistance) {
      best = (series: s, index: index);
      bestDistance = distance;
    }
  }
  return best;
}

ActivePoint _along(List<ChartSeriesData> series, ActivePoint active, XWindow window, int Function(int position, int count) offset) {
  final drawable = _drawableIndices(series[active.series], window);
  final position = drawable.indexOf(active.index);
  if (position < 0) return active;
  final next = offset(position, drawable.length).clamp(0, drawable.length - 1);
  return (series: active.series, index: drawable[next]);
}

ActivePoint _across(List<ChartSeriesData> series, ActivePoint active, XWindow window, int direction) {
  final visible = [
    for (var s = 0; s < series.length; s++)
      if (_hasPoint(series[s], window)) s,
  ];
  final at = visible.indexOf(active.series);
  final targetAt = at + direction;
  if (at < 0 || targetAt < 0 || targetAt >= visible.length) return active;
  final target = series[visible[targetAt]];
  final x = series[active.series].xs[active.index];
  final index = _nearestIndex(target, x, (i) => target.xs[i], window);
  if (index == null) return active;
  return (series: visible[targetAt], index: index);
}

/// Moves the active point for a key. Left and right step one point, Home and
/// End go to the ends of the series, and Page Up and Page Down step a tenth
/// of the series, at least one. Up and down go to the previous or next
/// visible series, at its point nearest in time. At an end, the point stays.
ActivePoint stepPoint(List<ChartSeriesData> series, ActivePoint active, ChartNavigationKey key, XWindow window) {
  int page(int count) => math.max(1, count ~/ _pageFraction);
  switch (key) {
    case ChartNavigationKey.left:
      return _along(series, active, window, (position, _) => position - 1);
    case ChartNavigationKey.right:
      return _along(series, active, window, (position, _) => position + 1);
    case ChartNavigationKey.home:
      return _along(series, active, window, (_, _) => 0);
    case ChartNavigationKey.end:
      return _along(series, active, window, (_, count) => count - 1);
    case ChartNavigationKey.pageUp:
      return _along(series, active, window, (position, count) => position - page(count));
    case ChartNavigationKey.pageDown:
      return _along(series, active, window, (position, count) => position + page(count));
    case ChartNavigationKey.up:
      return _across(series, active, window, -1);
    case ChartNavigationKey.down:
      return _across(series, active, window, 1);
  }
}

// --- Table rows ---

typedef ChartTableRow = ({double time, List<double?> values});

/// Rows are the distinct x values inside the window, ascending, with one
/// value per series. A series' first point at an x wins, and a series with
/// no point there leaves a null.
List<ChartTableRow> mergeSeriesRows(List<ChartSeriesData> series, XWindow window) {
  final byTime = <double, List<double?>>{};
  for (var s = 0; s < series.length; s++) {
    final entry = series[s];
    for (var i = 0; i < entry.length; i++) {
      if (!entry.isPlaced(i)) continue;
      final time = entry.xs[i];
      if (!isInsideWindow(time, window)) continue;
      final values = byTime.putIfAbsent(time, () => List<double?>.filled(series.length, null));
      values[s] ??= entry.ys[i];
    }
  }
  final times = byTime.keys.toList()..sort();
  return [for (final time in times) (time: time, values: byTime[time]!)];
}

// --- Summary ---

/// Describes the chart for a screen reader: the visible series, the time
/// range and the value range.
String summarizeChart({
  required List<ChartSeriesData> series,
  required XWindow window,
  double? xMin,
  double? xMax,
  double? yMin,
  double? yMax,
  required String Function(DateTime) formatTime,
  required String Function(double) formatValue,
}) {
  if (!hasData(series)) return 'No data.';
  final visible = series.where((entry) => !entry.hidden).toList();
  if (visible.isEmpty) return 'Every series is hidden.';

  double? xFrom, xTo, yFrom, yTo;
  for (final entry in visible) {
    for (var i = 0; i < entry.length; i++) {
      if (!entry.isPlaced(i)) continue;
      final x = entry.xs[i];
      if (xFrom == null || x < xFrom) xFrom = x;
      if (xTo == null || x > xTo) xTo = x;
      if (!isInsideWindow(x, window)) continue;
      final y = entry.ys[i]!;
      if (yFrom == null || y < yFrom) yFrom = y;
      if (yTo == null || y > yTo) yTo = y;
    }
  }
  xFrom = xMin ?? xFrom;
  xTo = xMax ?? xTo;
  yFrom = yMin ?? yFrom;
  yTo = yMax ?? yTo;

  final parts = ['Series: ${visible.map((entry) => entry.label).join(', ')}.'];
  if (xFrom != null && xTo != null) parts.add('Time: ${formatTime(_fromMs(xFrom))} to ${formatTime(_fromMs(xTo))}.');
  if (yFrom != null && yTo != null) parts.add('Values: ${formatValue(yFrom)} to ${formatValue(yTo)}.');
  return parts.join(' ');
}
