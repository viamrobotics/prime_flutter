import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'floating.dart';
import 'icon_button.dart';
import 'input.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';

/// What kind of time a [RelativeTimeValue] holds.
enum RelativeTimeType { relative, absolute, undefined }

/// The value reported by [RelativeTimePicker].
class RelativeTimeValue {
  final RelativeTimeType type;

  /// The text as entered: `now-15m` or `MM/DD/YYYY HH:mm:ss`. Null when cleared.
  final String? value;

  /// The resolved instant, in local time. Null when cleared.
  final DateTime? date;

  const RelativeTimeValue.relative(String this.value, DateTime this.date) : type = RelativeTimeType.relative;
  const RelativeTimeValue.absolute(String this.value, DateTime this.date) : type = RelativeTimeType.absolute;
  const RelativeTimeValue.undefined() : type = RelativeTimeType.undefined, value = null, date = null;
}

final RegExp _relativePattern = RegExp(
  r'^now(?:-(\d+)(seconds?|sec|s|minutes?|min|m|hours?|hr|h|days?|d|weeks?|wk|w|months?|mon|years?|yrs|yr|y))?$',
  caseSensitive: false,
);

/// Parses `now` or `now-<n><unit>` (e.g. `now-15m`, `now-2 days` is not valid,
/// `now-2days` is) into an instant relative to [now], which defaults to the
/// current time. Returns null when [input] is not a relative time.
///
/// Units: s/sec/second(s), m/min/minute(s), h/hr/hour(s), d/day(s),
/// w/wk/week(s), mon/month(s), y/yr/yrs/year(s).
DateTime? parseRelativeTime(String input, {DateTime? now}) {
  final match = _relativePattern.firstMatch(input.trim().toLowerCase());
  if (match == null) return null;

  final current = now ?? DateTime.now();
  final amountText = match.group(1);
  final unit = match.group(2);
  if (amountText == null || unit == null) return current;
  final amount = int.tryParse(amountText);
  if (amount == null) return null;

  if (unit.startsWith('s')) return current.subtract(Duration(seconds: amount));
  if (unit.startsWith('mon')) return _withMonth(current, current.year, current.month - amount);
  if (unit.startsWith('m')) return current.subtract(Duration(minutes: amount));
  if (unit.startsWith('h')) return current.subtract(Duration(hours: amount));
  if (unit.startsWith('d')) return current.subtract(Duration(days: amount));
  if (unit.startsWith('w')) return current.subtract(Duration(days: 7 * amount));
  return _withMonth(current, current.year - amount, current.month);
}

/// Moves [from] to another month, pinning the day to that month's length.
DateTime _withMonth(DateTime from, int year, int month) {
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = from.day > lastDay ? lastDay : from.day;
  final build = from.isUtc ? DateTime.utc : DateTime.new;
  return build(year, month, day, from.hour, from.minute, from.second, from.millisecond, from.microsecond);
}

String _two(int value) => value.toString().padLeft(2, '0');

/// Formats [date] as `MM/DD/YYYY HH:mm:ss`, the absolute format
/// [RelativeTimePicker] reads and writes.
String formatDateValueString(DateTime date) {
  return '${_two(date.month)}/${_two(date.day)}/${date.year} ${_two(date.hour)}:${_two(date.minute)}:${_two(date.second)}';
}

/// Parses `MM/DD/YYYY HH:mm:ss` into a local [DateTime], or null when the
/// text is not in that format.
DateTime? parseDateValueString(String value) {
  final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4}) (\d{1,2}):(\d{1,2}):(\d{1,2})$').firstMatch(value.trim());
  if (match == null) return null;
  final parts = [for (int i = 1; i <= 6; i++) int.parse(match.group(i)!)];
  final (month, day, year, hour, minute, second) = (parts[0], parts[1], parts[2], parts[3], parts[4], parts[5]);
  if (month < 1 || month > 12 || day < 1 || day > DateTime(year, month + 1, 0).day) return null;
  if (hour > 23 || minute > 59 || second > 59) return null;
  return DateTime(year, month, day, hour, minute, second);
}

const List<String> _monthNames = [
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

/// A time field that accepts either a relative expression (`now-15m`) or an
/// absolute `MM/DD/YYYY HH:mm:ss` timestamp, with a calendar for picking a day.
///
/// ```dart
/// RelativeTimePicker(
///   value: start,
///   onChanged: (time) => setState(() => start = time.value),
///   onApply: runQuery,
/// )
/// ```
class RelativeTimePicker extends StatefulWidget {
  /// The current text value, relative or absolute.
  final String? value;

  /// Called when a new valid value is committed or the field is cleared.
  final ValueChanged<RelativeTimeValue> onChanged;

  /// Called after Enter commits a changed value.
  final VoidCallback? onApply;

  final bool disabled;

  /// An error to show under the field. Overrides the built-in format error.
  final String? error;

  /// Days for which this returns true cannot be picked in the calendar.
  final bool Function(DateTime day)? isDateUnavailable;

  final String placeholder;

  const RelativeTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.onApply,
    this.disabled = false,
    this.error,
    this.isDateUnavailable,
    this.placeholder = 'now-15m',
  });

  @override
  State<RelativeTimePicker> createState() => _RelativeTimePickerState();
}

class _RelativeTimePickerState extends State<RelativeTimePicker> {
  late final TextEditingController _controller = TextEditingController(text: widget.value ?? '');
  final FocusNode _focusNode = FocusNode();
  bool _calendarOpen = false;
  String? _formatError;

  /// The last text reported that the parent has not yet echoed back, so
  /// submit followed by blur does not report it twice.
  String? _pendingValue;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final date = _resolvedDate ?? DateTime.now();
    _visibleMonth = DateTime(date.year, date.month);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit(_controller.text);
    });
  }

  @override
  void didUpdateWidget(RelativeTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pendingValue = null;
    if (widget.value != oldWidget.value && (widget.value ?? '') != _controller.text) {
      _controller.text = widget.value ?? '';
      _formatError = null;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  DateTime? get _resolvedDate {
    final value = widget.value;
    if (value == null || value.isEmpty) return null;
    return parseRelativeTime(value) ?? parseDateValueString(value);
  }

  /// Returns whether a new valid value was reported.
  bool _commit(String raw) {
    final input = raw.trim();
    if (input == _pendingValue) return false;
    if (input == (widget.value ?? '')) {
      if (_formatError != null) setState(() => _formatError = null);
      return false;
    }
    if (input.isEmpty) {
      setState(() => _formatError = null);
      _pendingValue = input;
      widget.onChanged(const RelativeTimeValue.undefined());
      return false;
    }

    final relative = parseRelativeTime(input);
    if (relative != null) {
      setState(() => _formatError = null);
      _pendingValue = input;
      widget.onChanged(RelativeTimeValue.relative(input, relative));
      return true;
    }
    final absolute = parseDateValueString(input);
    if (absolute == null) {
      setState(() => _formatError = 'Invalid date format.');
      return false;
    }
    setState(() => _formatError = null);
    _pendingValue = input;
    widget.onChanged(RelativeTimeValue.absolute(input, absolute));
    return true;
  }

  void _pickDay(DateTime day) {
    // Keep the time of day from an existing absolute value.
    final current = widget.value == null ? null : parseDateValueString(widget.value!);
    final picked = DateTime(day.year, day.month, day.day, current?.hour ?? 0, current?.minute ?? 0, current?.second ?? 0);
    final text = formatDateValueString(picked);
    _controller.text = text;
    _commit(text);
    setState(() => _calendarOpen = false);
  }

  void _toggleCalendar() {
    setState(() {
      _calendarOpen = !_calendarOpen;
      if (_calendarOpen) {
        final date = _resolvedDate ?? DateTime.now();
        _visibleMonth = DateTime(date.year, date.month);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final error = widget.error ?? _formatError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Floating(
          visible: _calendarOpen && !widget.disabled,
          placement: FloatingPlacement.bottomEnd,
          onTapOutside: () => setState(() => _calendarOpen = false),
          onEscape: () => setState(() => _calendarOpen = false),
          floatingBuilder: (context) => _Calendar(
            visibleMonth: _visibleMonth,
            selected: _resolvedDate,
            isDateUnavailable: widget.isDateUnavailable,
            onMonthChanged: (month) => setState(() => _visibleMonth = month),
            onPick: _pickDay,
          ),
          child: Row(
            children: [
              Expanded(
                child: Input(
                  controller: _controller,
                  focusNode: _focusNode,
                  placeholder: widget.placeholder,
                  disabled: widget.disabled,
                  autocorrect: false,
                  state: error != null ? InputState.error : InputState.none,
                  onSubmitted: () {
                    if (_commit(_controller.text)) widget.onApply?.call();
                  },
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(PrimeIcons.calendarBlank),
                label: 'Choose date',
                variant: IconButtonVariant.secondary,
                size: IconButtonSize.large,
                disabled: widget.disabled,
                onPressed: _toggleCalendar,
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(error, style: theme.textTheme.bodySmall.copyWith(fontSize: 12, color: theme.colorScheme.statusDangerDark)),
          ),
      ],
    );
  }
}

class _Calendar extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime? selected;

  /// The far end of a range starting at [selected]; days between are shaded.
  final DateTime? rangeEnd;
  final bool Function(DateTime day)? isDateUnavailable;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onPick;

  const _Calendar({
    required this.visibleMonth,
    required this.selected,
    this.rangeEnd,
    required this.isDateUnavailable,
    required this.onMonthChanged,
    required this.onPick,
  });

  static const double _cell = 36;

  bool _sameDay(DateTime? a, DateTime b) => a != null && a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final today = DateTime.now();
    final year = visibleMonth.year;
    final month = visibleMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Weeks start on Sunday.
    final leadingBlanks = DateTime(year, month, 1).weekday % 7;
    final cellCount = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    final textStyle = theme.textTheme.bodySmall.copyWith(height: 1, color: c.textSecondary);

    Widget dayCell(int index) {
      final dayNumber = index - leadingBlanks + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) return const SizedBox(width: _cell, height: _cell);
      final day = DateTime(year, month, dayNumber);
      final unavailable = isDateUnavailable?.call(day) ?? false;
      final isSelected = _sameDay(selected, day) || _sameDay(rangeEnd, day);
      final inRange = selected != null && rangeEnd != null && day.isAfter(selected!) && day.isBefore(rangeEnd!);
      final isToday = _sameDay(today, day);

      return Pressable(
        disabled: unavailable,
        onTap: () => onPick(day),
        builder: (context, hovered, pressed) => Semantics(
          selected: isSelected,
          child: Container(
            width: _cell,
            height: _cell,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? c.surfaceHighlight : (hovered || pressed || inRange ? c.surfaceHover : null),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$dayNumber',
              style: textStyle.copyWith(
                color: unavailable ? c.textPlaceholder : (isSelected || isToday ? c.textPrimary : c.textSecondary),
                fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      decoration: BoxDecoration(
        color: c.surfaceBase,
        borderRadius: BorderRadius.circular(theme.cornerRadius),
        border: Border.all(color: c.iconDisabled),
      ),
      child: SizedBox(
        width: _cell * 7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(PrimeIcons.chevronLeft),
                  label: 'Previous',
                  showTooltip: false,
                  variant: IconButtonVariant.ghost,
                  onPressed: () => onMonthChanged(DateTime(year, month - 1)),
                ),
                Expanded(
                  child: Text(
                    '${_monthNames[month - 1]} $year',
                    textAlign: TextAlign.center,
                    style: textStyle.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                  ),
                ),
                IconButton(
                  icon: const Icon(PrimeIcons.chevronRight),
                  label: 'Next',
                  showTooltip: false,
                  variant: IconButtonVariant.ghost,
                  onPressed: () => onMonthChanged(DateTime(year, month + 1)),
                ),
              ],
            ),
            Row(
              children: [
                for (final name in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                  SizedBox(
                    width: _cell,
                    height: 28,
                    child: Center(
                      child: Text(name, style: textStyle.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
            for (int week = 0; week < cellCount ~/ 7; week++) Row(children: [for (int i = 0; i < 7; i++) dayCell(week * 7 + i)]),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) => '${_two(date.month)}/${_two(date.day)}/${date.year}';

DateTime? _parseDate(String text) {
  final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(text.trim());
  if (match == null) return null;
  final month = int.parse(match.group(1)!), day = int.parse(match.group(2)!), year = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1 || day > DateTime(year, month + 1, 0).day) return null;
  return DateTime(year, month, day);
}

/// A date field with a calendar popup. Dates are typed and shown as
/// `MM/DD/YYYY`.
///
/// ```dart
/// DatePicker(
///   value: date,
///   onChanged: (next) => setState(() => date = next),
///   max: DateTime.now(),
/// )
/// ```
class DatePicker extends StatefulWidget {
  /// The selected day, or null when empty.
  final DateTime? value;

  /// Called with the new day, or null when the field is cleared.
  final ValueChanged<DateTime?>? onChanged;

  /// The earliest and latest selectable days, inclusive.
  final DateTime? min;
  final DateTime? max;

  /// Days for which this returns true cannot be picked.
  final bool Function(DateTime day)? isDateUnavailable;

  final String placeholder;
  final bool disabled;
  final bool readOnly;
  final InputState state;

  const DatePicker({
    super.key,
    this.value,
    this.onChanged,
    this.min,
    this.max,
    this.isDateUnavailable,
    this.placeholder = 'MM/DD/YYYY',
    this.disabled = false,
    this.readOnly = false,
    this.state = InputState.none,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late final TextEditingController _controller = TextEditingController(text: widget.value == null ? '' : _formatDate(widget.value!));
  final FocusNode _focusNode = FocusNode();
  bool _open = false;
  bool _invalid = false;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final date = widget.value ?? DateTime.now();
    _visibleMonth = DateTime(date.year, date.month);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value == null ? '' : _formatDate(widget.value!);
      _invalid = false;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _unavailable(DateTime day) {
    final min = widget.min, max = widget.max;
    if (min != null && day.isBefore(DateTime(min.year, min.month, min.day))) return true;
    if (max != null && day.isAfter(DateTime(max.year, max.month, max.day))) return true;
    return widget.isDateUnavailable?.call(day) ?? false;
  }

  bool _sameDay(DateTime? a, DateTime? b) => a?.year == b?.year && a?.month == b?.month && a?.day == b?.day;

  void _commit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _invalid = false);
      if (widget.value != null) widget.onChanged?.call(null);
      return;
    }
    final parsed = _parseDate(text);
    if (parsed == null || _unavailable(parsed)) {
      setState(() => _invalid = true);
      return;
    }
    setState(() => _invalid = false);
    if (!_sameDay(parsed, widget.value)) widget.onChanged?.call(parsed);
  }

  void _pick(DateTime day) {
    _controller.text = _formatDate(day);
    setState(() {
      _open = false;
      _invalid = false;
    });
    if (!_sameDay(day, widget.value)) widget.onChanged?.call(day);
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.disabled || widget.readOnly;
    return Floating(
      visible: _open && !locked,
      placement: FloatingPlacement.bottomEnd,
      onTapOutside: () => setState(() => _open = false),
      onEscape: () => setState(() => _open = false),
      floatingBuilder: (context) => _Calendar(
        visibleMonth: _visibleMonth,
        selected: widget.value,
        isDateUnavailable: _unavailable,
        onMonthChanged: (month) => setState(() => _visibleMonth = month),
        onPick: _pick,
      ),
      child: Row(
        children: [
          Expanded(
            child: Input(
              controller: _controller,
              focusNode: _focusNode,
              placeholder: widget.placeholder,
              disabled: widget.disabled,
              readOnly: widget.readOnly,
              autocorrect: false,
              keyboardType: TextInputType.datetime,
              state: _invalid ? InputState.error : widget.state,
              onSubmitted: _commit,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(PrimeIcons.calendarBlank),
            label: 'Choose date',
            variant: IconButtonVariant.secondary,
            size: IconButtonSize.large,
            disabled: locked,
            onPressed: () => setState(() {
              _open = !_open;
              final date = widget.value ?? DateTime.now();
              _visibleMonth = DateTime(date.year, date.month);
            }),
          ),
        ],
      ),
    );
  }
}

/// A start and an end day. With one end chosen the other is null, so a
/// finished range is one with both set.
@immutable
class DateRange {
  final DateTime? start;
  final DateTime? end;

  const DateRange({this.start, this.end});

  /// Whether both ends are set.
  bool get isComplete => start != null && end != null;

  @override
  bool operator ==(Object other) => other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start, $end)';
}

/// A date range picker: one field holding a start and an end date, with a
/// range calendar that opens from its trigger.
///
/// The first pick in the calendar sets the start and the second the end;
/// picking the end before the start swaps them, so `start` is never after
/// `end`. The field also accepts typing, as `MM/DD/YYYY – MM/DD/YYYY`.
/// Granularity is the day.
///
/// ```dart
/// DateRangePicker(
///   value: period,
///   max: DateTime.now(),
///   onChanged: (next) => setState(() => period = next),
/// )
/// ```
class DateRangePicker extends StatefulWidget {
  /// The chosen range, or null until a date is chosen.
  final DateRange? value;

  /// Called with the new range, or null when the field is cleared. Leave
  /// your state as it was to decline a range.
  final ValueChanged<DateRange?>? onChanged;

  /// The earliest and latest selectable days, inclusive.
  final DateTime? min;
  final DateTime? max;

  /// Days for which this returns true cannot be picked.
  final bool Function(DateTime day)? isDateUnavailable;

  final String placeholder;
  final bool disabled;
  final bool readOnly;
  final InputState state;

  const DateRangePicker({
    super.key,
    this.value,
    this.onChanged,
    this.min,
    this.max,
    this.isDateUnavailable,
    this.placeholder = 'MM/DD/YYYY – MM/DD/YYYY',
    this.disabled = false,
    this.readOnly = false,
    this.state = InputState.none,
  });

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  late final TextEditingController _controller = TextEditingController(text: _format(widget.value));
  final FocusNode _focusNode = FocusNode();
  bool _open = false;
  bool _invalid = false;
  late DateTime _visibleMonth;

  static String _format(DateRange? range) {
    if (range?.start == null) return '';
    return '${_formatDate(range!.start!)} – ${range.end == null ? '' : _formatDate(range.end!)}'.trimRight();
  }

  @override
  void initState() {
    super.initState();
    final date = widget.value?.start ?? DateTime.now();
    _visibleMonth = DateTime(date.year, date.month);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(DateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _format(widget.value);
      _invalid = false;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _unavailable(DateTime day) {
    final min = widget.min, max = widget.max;
    if (min != null && day.isBefore(DateTime(min.year, min.month, min.day))) return true;
    if (max != null && day.isAfter(DateTime(max.year, max.month, max.day))) return true;
    return widget.isDateUnavailable?.call(day) ?? false;
  }

  void _report(DateRange? range) {
    if (range != widget.value) widget.onChanged?.call(range);
    // The parent may decline the change, in which case no rebuild arrives to restore the text.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_focusNode.hasFocus) _controller.text = _format(widget.value);
    });
  }

  void _commit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _invalid = false);
      _report(null);
      return;
    }
    final parts = text.split(RegExp(r'\s*[–—-]\s*(?=\d{1,2}/)'));
    final start = _parseDate(parts.first);
    final end = parts.length > 1 ? _parseDate(parts[1]) : null;
    final bad = start == null || _unavailable(start) || parts.length > 2 || (parts.length > 1 && (end == null || _unavailable(end)));
    if (bad) {
      setState(() => _invalid = true);
      return;
    }
    setState(() => _invalid = false);
    // Typed backwards, the two ends swap.
    _report(end != null && end.isBefore(start) ? DateRange(start: end, end: start) : DateRange(start: start, end: end));
  }

  void _pick(DateTime day) {
    final current = widget.value;
    final DateRange next;
    if (current?.start == null || current!.isComplete) {
      // A first pick, or a pick after a finished range, starts over.
      next = DateRange(start: day);
    } else {
      next = day.isBefore(current.start!) ? DateRange(start: day, end: current.start) : DateRange(start: current.start, end: day);
    }
    setState(() {
      _invalid = false;
      if (next.isComplete) _open = false;
    });
    _controller.text = _format(next);
    _report(next);
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.disabled || widget.readOnly;
    return Floating(
      visible: _open && !locked,
      placement: FloatingPlacement.bottomEnd,
      onTapOutside: () => setState(() => _open = false),
      onEscape: () => setState(() => _open = false),
      floatingBuilder: (context) => _Calendar(
        visibleMonth: _visibleMonth,
        selected: widget.value?.start,
        rangeEnd: widget.value?.end,
        isDateUnavailable: _unavailable,
        onMonthChanged: (month) => setState(() => _visibleMonth = month),
        onPick: _pick,
      ),
      child: Row(
        children: [
          Expanded(
            child: Input(
              controller: _controller,
              focusNode: _focusNode,
              placeholder: widget.placeholder,
              disabled: widget.disabled,
              readOnly: widget.readOnly,
              autocorrect: false,
              state: _invalid ? InputState.error : widget.state,
              onSubmitted: _commit,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(PrimeIcons.calendarBlank),
            label: 'Choose dates',
            variant: IconButtonVariant.secondary,
            size: IconButtonSize.large,
            disabled: locked,
            onPressed: () => setState(() {
              _open = !_open;
              final date = widget.value?.start ?? DateTime.now();
              _visibleMonth = DateTime(date.year, date.month);
            }),
          ),
        ],
      ),
    );
  }
}

/// Which part of a moment a [DateTimeInput] edits.
enum DateTimeInputType { time, date, dateTime }

/// A field for a time of day, a date, or both, matching the web inputs of
/// type `time`, `date`, and `datetime-local`.
///
/// The value is always a [DateTime]. For [DateTimeInputType.time] only its
/// hour and minute matter; for [DateTimeInputType.date] only its day.
///
/// ```dart
/// DateTimeInput(
///   type: DateTimeInputType.dateTime,
///   value: startsAt,
///   onChanged: (next) => setState(() => startsAt = next),
/// )
/// ```
class DateTimeInput extends StatefulWidget {
  final DateTimeInputType type;
  final DateTime? value;

  /// Called with the new moment, or null when the field is cleared.
  final ValueChanged<DateTime?>? onChanged;

  final bool disabled;
  final bool readOnly;
  final InputState state;

  const DateTimeInput({
    super.key,
    this.type = DateTimeInputType.dateTime,
    this.value,
    this.onChanged,
    this.disabled = false,
    this.readOnly = false,
    this.state = InputState.none,
  });

  @override
  State<DateTimeInput> createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  late final TextEditingController _time = TextEditingController(text: _formatTime(widget.value));
  final FocusNode _timeFocus = FocusNode();
  bool _invalidTime = false;

  static String _formatTime(DateTime? value) => value == null ? '' : '${_two(value.hour)}:${_two(value.minute)}';

  @override
  void initState() {
    super.initState();
    _timeFocus.addListener(() {
      if (!_timeFocus.hasFocus) _commitTime();
    });
  }

  @override
  void didUpdateWidget(DateTimeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_timeFocus.hasFocus) {
      _time.text = _formatTime(widget.value);
      _invalidTime = false;
    }
  }

  @override
  void dispose() {
    _time.dispose();
    _timeFocus.dispose();
    super.dispose();
  }

  void _commitTime() {
    final text = _time.text.trim();
    if (text.isEmpty) {
      setState(() => _invalidTime = false);
      // Clearing the time of a date-and-time keeps the day, at midnight.
      final value = widget.value;
      if (value == null) return;
      widget.onChanged?.call(widget.type == DateTimeInputType.time ? null : DateTime(value.year, value.month, value.day));
      return;
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    final hour = match == null ? null : int.parse(match.group(1)!);
    final minute = match == null ? null : int.parse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      setState(() => _invalidTime = true);
      return;
    }
    setState(() => _invalidTime = false);
    final base = widget.value ?? DateTime.now();
    final next = DateTime(base.year, base.month, base.day, hour, minute);
    _time.text = _formatTime(next);
    if (next != widget.value) widget.onChanged?.call(next);
  }

  void _setDate(DateTime? day) {
    if (day == null) {
      widget.onChanged?.call(null);
      return;
    }
    final current = widget.value;
    widget.onChanged?.call(DateTime(day.year, day.month, day.day, current?.hour ?? 0, current?.minute ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final timeField = Input(
      controller: _time,
      focusNode: _timeFocus,
      placeholder: '--:--',
      keyboardType: TextInputType.datetime,
      autocorrect: false,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      state: _invalidTime ? InputState.error : widget.state,
      trailing: _invalidTime ? null : const Icon(PrimeIcons.clockOutline),
      onSubmitted: _commitTime,
    );
    final value = widget.value;
    final dateField = DatePicker(
      value: value == null ? null : DateTime(value.year, value.month, value.day),
      onChanged: _setDate,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      state: widget.state,
    );
    switch (widget.type) {
      case DateTimeInputType.time:
        return timeField;
      case DateTimeInputType.date:
        return dateField;
      case DateTimeInputType.dateTime:
        return Row(
          children: [
            Expanded(flex: 3, child: dateField),
            const SizedBox(width: 8),
            Expanded(flex: 2, child: timeField),
          ],
        );
    }
  }
}
