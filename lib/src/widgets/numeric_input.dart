import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'input.dart';
import 'label.dart';
import 'slider.dart';
import 'tooltip.dart';

/// Whether a numeric input accepts decimals or whole numbers only.
enum NumericInputType { number, integer }

String _formatNumber(num? value) {
  if (value == null) return '';
  if (value is int || value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

int _decimalsOf(num step) {
  final text = step.toString();
  final dot = text.indexOf('.');
  if (dot < 0 || text.endsWith('.0')) return 0;
  return text.length - dot - 1;
}

/// A text field for numbers.
///
/// ```dart
/// NumericInput(
///   type: NumericInputType.integer,
///   value: count,
///   onChanged: (value) => setState(() => count = value?.toInt()),
/// )
/// ```
class NumericInput extends StatefulWidget {
  /// The current value, or null when empty.
  final num? value;

  /// Called on every edit that parses to a number, or with null when cleared.
  final ValueChanged<num?>? onChanged;

  /// Called when the user submits or leaves the field.
  final ValueChanged<num?>? onChangeEnd;

  final NumericInputType type;

  /// Lower bound, applied when the edit is committed.
  final num? min;

  /// Upper bound, applied when the edit is committed.
  final num? max;

  final String placeholder;
  final bool disabled;
  final bool readOnly;
  final InputState state;
  final FocusNode? focusNode;
  final Widget? leading;
  final Widget? trailing;

  /// A compact 28px-tall variant for tool panels.
  final bool dense;

  const NumericInput({
    super.key,
    this.value,
    this.onChanged,
    this.onChangeEnd,
    this.type = NumericInputType.number,
    this.min,
    this.max,
    this.placeholder = '0',
    this.disabled = false,
    this.readOnly = false,
    this.state = InputState.none,
    this.focusNode,
    this.leading,
    this.trailing,
    this.dense = false,
  });

  @override
  State<NumericInput> createState() => _NumericInputState();
}

class _NumericInputState extends State<NumericInput> {
  late final TextEditingController _controller = TextEditingController(text: _formatNumber(widget.value));
  FocusNode? _ownFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(NumericInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_handleFocusChange);
      _focusNode.addListener(_handleFocusChange);
    }
    // Leave the text alone while it still parses to the incoming value, so
    // typing "1." or "-0" is not rewritten under the user.
    if (_parse(_controller.text) != widget.value) {
      final text = _formatNumber(widget.value);
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _ownFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
  }

  num? _parse(String text) {
    if (text.isEmpty) return null;
    return widget.type == NumericInputType.integer ? int.tryParse(text) : num.tryParse(text);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _handleChanged(String text) {
    final parsed = _parse(text);
    if (text.isEmpty || parsed != null) widget.onChanged?.call(parsed);
  }

  void _commit() {
    num? value = _parse(_controller.text);
    if (value != null) {
      if (widget.min != null && value < widget.min!) value = widget.min!;
      if (widget.max != null && value > widget.max!) value = widget.max!;
    }
    final text = _formatNumber(value);
    if (text != _controller.text) {
      _controller.text = text;
      widget.onChanged?.call(value);
    }
    widget.onChangeEnd?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final isInteger = widget.type == NumericInputType.integer;
    return Input(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: widget.placeholder,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      state: widget.state,
      leading: widget.leading,
      trailing: widget.trailing,
      dense: widget.dense,
      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: !isInteger),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(isInteger ? r'^-?\d*' : r'^-?\d*\.?\d*'))],
      onChanged: _handleChanged,
      onSubmitted: _commit,
    );
  }
}

/// A [NumericInput] with a drag handle on its leading edge: drag left or
/// right to scrub the value by [step].
///
/// ```dart
/// SliderInput(value: speed, min: 0, max: 1, step: 0.1, onChanged: setSpeed)
/// ```
class SliderInput extends StatefulWidget {
  final num? value;

  /// Called while typing and while dragging.
  final ValueChanged<num?>? onChanged;

  /// Called when an edit is committed or the drag is released.
  final ValueChanged<num?>? onChangeEnd;

  final NumericInputType type;

  /// The amount each 10 logical pixels of drag adds or subtracts.
  final num step;

  final num? min;
  final num? max;
  final String placeholder;
  final bool disabled;
  final bool readOnly;
  final InputState state;

  const SliderInput({
    super.key,
    this.value,
    this.onChanged,
    this.onChangeEnd,
    this.type = NumericInputType.number,
    this.step = 1,
    this.min,
    this.max,
    this.placeholder = '0',
    this.disabled = false,
    this.readOnly = false,
    this.state = InputState.none,
  });

  @override
  State<SliderInput> createState() => _SliderInputState();
}

class _SliderInputState extends State<SliderInput> {
  bool _dragging = false;
  bool _hovered = false;
  double _dragDistance = 0;
  num _startValue = 0;
  num? _dragValue;

  bool get _locked => widget.disabled || widget.readOnly;

  void _handleDragStart(DragStartDetails details) {
    _startValue = widget.value ?? 0;
    _dragDistance = 0;
    _dragValue = _startValue;
    setState(() => _dragging = true);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.delta.dx;
    final isInteger = widget.type == NumericInputType.integer;
    num next = _startValue + (_dragDistance / 10).round() * widget.step;
    next = isInteger ? next.round() : double.parse(next.toStringAsFixed(_decimalsOf(widget.step).clamp(0, 10)));
    if (widget.min != null && next < widget.min!) next = widget.min!;
    if (widget.max != null && next > widget.max!) next = widget.max!;
    if (next != _dragValue) {
      setState(() => _dragValue = next);
      widget.onChanged?.call(next);
    }
  }

  void _handleDragEnd([DragEndDetails? details]) {
    setState(() => _dragging = false);
    widget.onChangeEnd?.call(_dragValue);
  }

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    final handleColor = _locked ? c.iconDisabled : (_hovered || _dragging ? c.textTertiary : c.iconSecondary);

    return Stack(
      children: [
        NumericInput(
          value: widget.value,
          onChanged: widget.onChanged,
          onChangeEnd: widget.onChangeEnd,
          type: widget.type,
          min: widget.min,
          max: widget.max,
          placeholder: widget.placeholder,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          state: widget.state,
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 14,
          child: ExcludeSemantics(
            child: MouseRegion(
              cursor: _locked ? SystemMouseCursors.forbidden : SystemMouseCursors.resizeLeftRight,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _locked ? null : _handleDragStart,
                onHorizontalDragUpdate: _locked ? null : _handleDragUpdate,
                onHorizontalDragEnd: _locked ? null : _handleDragEnd,
                onHorizontalDragCancel: _locked ? null : _handleDragEnd,
                child: Tooltip(
                  message: _formatNumber(_dragValue),
                  visibility: _dragging ? TooltipVisibility.visible : TooltipVisibility.invisible,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 8, 5, 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: handleColor, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A numeric field paired with a slider, for values with a known range.
///
/// ```dart
/// RangeInput(value: volume, max: 100, suffix: '%', onChanged: setVolume)
/// ```
class RangeInput extends StatelessWidget {
  final num value;
  final ValueChanged<num>? onChanged;
  final ValueChanged<num>? onChangeEnd;
  final num min;
  final num max;

  /// The amount to add or subtract when moving the slider.
  final num step;

  final bool disabled;
  final bool readOnly;

  /// Whether to draw tick marks along the track. Hidden automatically when
  /// there would be more than 20.
  final bool showPips;

  /// Rendered after the min and max labels, e.g. `%`.
  final String? suffix;

  const RangeInput({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.readOnly = false,
    this.showPips = true,
    this.suffix,
  }) : assert(min < max),
       assert(step > 0);

  num _snap(double raw) {
    final steps = ((raw - min) / step).round();
    final snapped = min + steps * step;
    final isWhole = step is int && min is int;
    final num result = isWhole ? snapped.round() : double.parse(snapped.toStringAsFixed(_decimalsOf(step).clamp(0, 10)));
    return result.clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final locked = disabled || readOnly;
    final clamped = value.clamp(min, max);
    final stepCount = ((max - min) / step).round();
    final labelStyle = theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.2, color: disabled ? c.textPlaceholder : c.textSecondary);
    final isWhole = step is int && min is int;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 88,
          child: NumericInput(
            value: clamped,
            type: isWhole ? NumericInputType.integer : NumericInputType.number,
            min: min,
            max: max,
            disabled: disabled,
            readOnly: readOnly,
            onChanged: (next) {
              if (next != null && next >= min && next <= max) onChanged?.call(next);
            },
            onChangeEnd: (next) => onChangeEnd?.call((next ?? min).clamp(min, max)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_formatNumber(min)}${suffix ?? ''}', style: labelStyle),
                    Text('${_formatNumber(max)}${suffix ?? ''}', style: labelStyle),
                  ],
                ),
              ),
              IgnorePointer(
                ignoring: locked,
                child: Opacity(
                  opacity: disabled ? 0.4 : 1,
                  child: Slider(
                    value: clamped.toDouble(),
                    min: min.toDouble(),
                    max: max.toDouble(),
                    divisions: showPips && stepCount <= 20 ? stepCount : null,
                    onChanged: (raw) {
                      final next = _snap(raw);
                      if (next != value) onChanged?.call(next);
                    },
                    onChangeEnd: (raw) => onChangeEnd?.call(_snap(raw)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A row of labelled [SliderInput]s for editing a vector such as x/y/z.
///
/// ```dart
/// VectorInput(
///   values: {'x': 0, 'y': 1.5, 'z': -2},
///   onChanged: (values) => setState(() => position = values),
/// )
/// ```
class VectorInput extends StatelessWidget {
  /// The component names, in display order.
  final List<String> labels;

  /// Current values by label. Missing labels render empty.
  final Map<String, num> values;

  /// Placeholders by label. Defaults to `0`.
  final Map<String, String> placeholders;

  /// Called with the full updated map on every edit or drag.
  final ValueChanged<Map<String, num>>? onChanged;

  /// Called with the full updated map when an edit is committed.
  final ValueChanged<Map<String, num>>? onChangeEnd;

  final NumericInputType type;
  final num step;
  final bool readOnly;
  final bool disabled;

  const VectorInput({
    super.key,
    this.labels = const ['x', 'y', 'z'],
    this.values = const {},
    this.placeholders = const {},
    this.onChanged,
    this.onChangeEnd,
    this.type = NumericInputType.number,
    this.step = 1,
    this.readOnly = false,
    this.disabled = false,
  });

  void _emit(ValueChanged<Map<String, num>>? callback, String label, num? value) {
    if (callback == null || value == null) return;
    callback({...values, label: value});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 6,
      children: [
        for (final label in labels)
          Expanded(
            child: Label(
              label: Text(label),
              disabled: disabled,
              child: SliderInput(
                value: values[label],
                type: type,
                step: step,
                readOnly: readOnly,
                disabled: disabled,
                placeholder: placeholders[label] ?? '0',
                onChanged: (value) => _emit(onChanged, label, value),
                onChangeEnd: (value) => _emit(onChangeEnd, label, value),
              ),
            ),
          ),
      ],
    );
  }
}
