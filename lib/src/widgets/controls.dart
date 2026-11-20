import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'expandable.dart';
import 'input.dart';
import 'numeric_input.dart';
import 'prime_icons.dart';
import 'slider.dart';
import 'tooltip.dart';

TextStyle _controlLabelStyle(BuildContext context, {bool disabled = false}) {
  final theme = PrimeTheme.of(context);
  return theme.textTheme.bodySmall.copyWith(
    fontSize: 12,
    height: 1.3,
    color: disabled ? theme.colorScheme.textPlaceholder : theme.colorScheme.textSecondary,
  );
}

/// The hint beside a control's label: an info icon that shows [hint] in a
/// tooltip on hover, focus, or long press.
class _ControlHint extends StatelessWidget {
  final String label;
  final String hint;
  final bool disabled;

  const _ControlHint({required this.label, required this.hint, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    final icon = SizedBox(
      width: 24,
      height: 24,
      child: Icon(PrimeIcons.informationOutline, size: 14, color: disabled ? c.iconDisabled : c.textTertiary),
    );
    return Semantics(
      label: 'About $label',
      hint: hint,
      child: disabled ? icon : Tooltip(message: hint, child: icon),
    );
  }
}

Widget _suffixText(BuildContext context, String suffix, bool disabled) {
  final theme = PrimeTheme.of(context);
  return Text(
    suffix,
    style: theme.textTheme.bodySmall.copyWith(
      fontSize: 12,
      height: 1.2,
      color: disabled ? theme.colorScheme.textPlaceholder : theme.colorScheme.textTertiary,
    ),
  );
}

/// A dense container for a tool panel's controls, with an optional title.
///
/// ```dart
/// Panel(
///   title: 'Camera',
///   children: [
///     NumberField(label: 'FOV', value: fov, onChanged: setFov),
///     Folder(title: 'Lighting', children: [SliderField(label: 'Intensity', value: intensity, onChanged: setIntensity)]),
///   ],
/// )
/// ```
class Panel extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  /// Accessible name when there is no [title].
  final String? semanticLabel;

  const Panel({super.key, this.title, required this.children, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    return Semantics(
      container: true,
      label: title ?? semanticLabel,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.surfaceOffset,
          borderRadius: BorderRadius.circular(theme.cornerRadius),
          border: Border.all(color: c.borderSubtle),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            if (title != null)
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title!,
                    style: _controlLabelStyle(context).copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                  ),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A collapsible group of controls inside a [Panel]. Open by default.
class Folder extends StatelessWidget {
  final String title;
  final List<Widget> children;

  /// Controls the open state. Null lets the folder manage it.
  final bool? open;
  final bool initiallyOpen;
  final ValueChanged<bool>? onOpenChanged;
  final bool disabled;

  const Folder({
    super.key,
    required this.title,
    required this.children,
    this.open,
    this.initiallyOpen = true,
    this.onOpenChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: disabled,
      child: Expandable(
        open: open,
        initiallyOpen: initiallyOpen,
        onOpenChanged: onOpenChanged,
        triggerBuilder: (context, isOpen) => ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 24),
          child: Row(
            children: [
              AnimatedRotation(
                turns: isOpen ? 0.25 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(PrimeIcons.chevronRight, size: 14, color: disabled ? c.iconDisabled : c.iconSecondary),
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: _controlLabelStyle(
                  context,
                  disabled: disabled,
                ).copyWith(fontWeight: FontWeight.w600, color: disabled ? null : c.textPrimary),
              ),
            ],
          ),
        ),
        content: Container(
          margin: const EdgeInsets.only(top: 4, left: 6),
          padding: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: c.borderSubtle)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 4, children: children),
        ),
      ),
    );
  }
}

/// A labelled row for any control in a [Panel], such as a dropdown or a
/// segmented button.
class ControlRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool disabled;

  /// Width reserved for the label so rows line up.
  final double labelWidth;

  const ControlRow({super.key, required this.label, required this.child, this.disabled = false, this.labelWidth = 72});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _controlLabelStyle(context, disabled: disabled),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(child: child),
      ],
    );
  }
}

/// Where a [NumberField] draws its label.
enum NumberFieldLabelPlacement { outside, inset }

/// A compact number field for tool panels. Drag its label sideways to scrub
/// the value: each pixel moves it by [step].
///
/// ```dart
/// NumberField(label: 'Speed', min: 0, max: 10, step: 0.1, value: speed, onChanged: setSpeed)
/// ```
class NumberField extends StatefulWidget {
  final num? value;
  final ValueChanged<num?>? onChanged;
  final String? label;
  final NumberFieldLabelPlacement labelPlacement;
  final num? min;
  final num? max;
  final num step;
  final bool disabled;
  final bool readOnly;

  /// Width reserved for an outside label so rows line up. Null sizes to the
  /// text.
  final double? labelWidth;

  /// Help text, shown in a tooltip from an info icon beside the label. Needs
  /// a [label].
  final String? hint;

  /// Text such as a unit, drawn at the end of the field.
  final String? suffix;

  /// Contextual state: `warn` and `error` recolor the border.
  final InputState state;

  const NumberField({
    super.key,
    this.value,
    this.onChanged,
    this.label,
    this.labelPlacement = NumberFieldLabelPlacement.outside,
    this.min,
    this.max,
    this.step = 1,
    this.disabled = false,
    this.readOnly = false,
    this.labelWidth,
    this.hint,
    this.suffix,
    this.state = InputState.none,
  });

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  double _accumulated = 0;

  bool get _locked => widget.disabled || widget.readOnly;

  int get _decimals {
    final text = widget.step.toString();
    final dot = text.indexOf('.');
    return dot < 0 || text.endsWith('.0') ? 0 : text.length - dot - 1;
  }

  void _handleScrub(DragUpdateDetails details) {
    _accumulated += details.delta.dx * widget.step;
    if (widget.min != null && _accumulated < widget.min!) _accumulated = widget.min!.toDouble();
    if (widget.max != null && _accumulated > widget.max!) _accumulated = widget.max!.toDouble();
    final steps = (_accumulated / widget.step).round();
    final num next = _decimals == 0 && widget.step is int
        ? steps * widget.step
        : double.parse((steps * widget.step).toStringAsFixed(_decimals.clamp(0, 10)));
    if (next != widget.value) widget.onChanged?.call(next);
  }

  Widget? _buildLabel(BuildContext context) {
    final label = widget.label;
    if (label == null) return null;
    return MouseRegion(
      cursor: _locked ? MouseCursor.defer : SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: _locked ? null : (_) => _accumulated = (widget.value ?? widget.min ?? 0).toDouble(),
        onHorizontalDragUpdate: _locked ? null : _handleScrub,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _controlLabelStyle(context, disabled: widget.disabled),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = _buildLabel(context);
    final inset = widget.labelPlacement == NumberFieldLabelPlacement.inset;
    final input = NumericInput(
      value: widget.value,
      onChanged: widget.onChanged,
      type: widget.step is int && (widget.min == null || widget.min is int) ? NumericInputType.integer : NumericInputType.number,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      dense: true,
      state: widget.state,
      leading: inset ? label : null,
      trailing: widget.suffix != null && widget.suffix!.isNotEmpty ? _suffixText(context, widget.suffix!, widget.disabled) : null,
    );
    final hint = widget.label != null && widget.hint != null
        ? _ControlHint(label: widget.label!, hint: widget.hint!, disabled: widget.disabled)
        : null;
    if (label == null) return input;
    if (inset) {
      // An inset label sits inside the field, so its hint goes after the field.
      return hint == null
          ? input
          : Row(
              children: [
                Expanded(child: input),
                hint,
              ],
            );
    }
    return Row(
      children: [
        widget.labelWidth != null ? SizedBox(width: widget.labelWidth! - (hint == null ? 0 : 24), child: label) : label,
        ?hint,
        const SizedBox(width: 4),
        Expanded(child: input),
      ],
    );
  }
}

/// What one axis of a [PointField] sets for itself, in place of the
/// control's option of the same name.
class PointAxisOptions {
  final num? min;
  final num? max;
  final num? step;

  /// A unit for this axis. An empty string draws none.
  final String? suffix;
  final InputState? state;

  const PointAxisOptions({this.min, this.max, this.step, this.suffix, this.state});
}

/// A 2D, 3D, or 4D vector.
class PointValue {
  final num x;
  final num y;
  final num? z;
  final num? w;

  const PointValue({required this.x, required this.y, this.z, this.w});

  PointValue copyWith({num? x, num? y, num? z, num? w}) => PointValue(x: x ?? this.x, y: y ?? this.y, z: z ?? this.z, w: w ?? this.w);

  @override
  bool operator ==(Object other) => other is PointValue && other.x == x && other.y == y && other.z == z && other.w == w;

  @override
  int get hashCode => Object.hash(x, y, z, w);

  @override
  String toString() => 'PointValue($x, $y${z != null ? ', $z' : ''}${w != null ? ', $w' : ''})';
}

/// A vector as one [NumberField] per axis (named `PointField` because
/// `dart:math` already has a `Point`): `x` and `y`, plus `z` and `w`
/// when they are set on [value].
///
/// ```dart
/// PointField(label: 'Position', step: 0.1, value: position, onChanged: setPosition)
/// ```
class PointField extends StatelessWidget {
  final PointValue value;
  final ValueChanged<PointValue>? onChanged;
  final String? label;

  /// Overrides for the axis labels, keyed `x`, `y`, `z`, `w`.
  final Map<String, String> labels;

  final num? min;
  final num? max;
  final num step;
  final bool disabled;

  /// Help text, shown in a tooltip from an info icon beside the label.
  final String? hint;

  /// A unit drawn at the end of every axis field.
  final String? suffix;

  /// Contextual state of every axis field.
  final InputState state;

  /// Options for single axes, keyed `x`, `y`, `z`, `w`, so a vector whose
  /// last axis has its own unit and range is still one field.
  final Map<String, PointAxisOptions> axes;

  /// Content under the fields, such as a message explaining a warn or error
  /// state.
  final Widget? details;

  const PointField({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.labels = const {},
    this.min,
    this.max,
    this.step = 1,
    this.disabled = false,
    this.hint,
    this.suffix,
    this.state = InputState.none,
    this.axes = const {},
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    final fields = <(String, num, PointValue Function(num))>[
      ('x', value.x, (next) => value.copyWith(x: next)),
      ('y', value.y, (next) => value.copyWith(y: next)),
      if (value.z != null) ('z', value.z!, (next) => value.copyWith(z: next)),
      if (value.w != null) ('w', value.w!, (next) => value.copyWith(w: next)),
    ];

    return Semantics(
      container: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          if (label != null)
            Row(
              children: [
                Flexible(
                  child: Text(label!, style: _controlLabelStyle(context, disabled: disabled)),
                ),
                if (hint != null) _ControlHint(label: label!, hint: hint!, disabled: disabled),
              ],
            ),
          Row(
            spacing: 4,
            children: [
              for (final (axis, current, update) in fields)
                Expanded(
                  child: NumberField(
                    label: labels[axis] ?? axis.toUpperCase(),
                    labelPlacement: NumberFieldLabelPlacement.inset,
                    value: current,
                    min: axes[axis]?.min ?? min,
                    max: axes[axis]?.max ?? max,
                    step: axes[axis]?.step ?? step,
                    suffix: axes[axis]?.suffix ?? suffix,
                    state: axes[axis]?.state ?? state,
                    disabled: disabled,
                    onChanged: (next) {
                      if (next != null) onChanged?.call(update(next));
                    },
                  ),
                ),
            ],
          ),
          ?details,
        ],
      ),
    );
  }
}

/// A compact, labelled text field for tool panels, in the same row layout as
/// [NumberField], [PointField] and [SliderField].
///
/// For a text box anywhere else, such as a form or a search bar, use [Input].
///
/// ```dart
/// TextField(label: 'Motion name', placeholder: 'builtin', onChanged: setName)
/// ```
class TextField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? label;

  /// Help text, shown in a tooltip from an info icon beside the label. Needs
  /// a [label].
  final String? hint;

  final String? placeholder;
  final InputState state;
  final bool disabled;
  final bool readOnly;

  /// Width reserved for the label so rows line up. Null sizes to the text.
  final double? labelWidth;

  const TextField({
    super.key,
    this.controller,
    this.onChanged,
    this.label,
    this.hint,
    this.placeholder,
    this.state = InputState.none,
    this.disabled = false,
    this.readOnly = false,
    this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    final input = Input(
      controller: controller,
      onChanged: onChanged,
      placeholder: placeholder,
      state: state,
      disabled: disabled,
      readOnly: readOnly,
      dense: true,
    );
    if (label == null) return input;
    final showHint = hint != null;
    final text = Text(
      label!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _controlLabelStyle(context, disabled: disabled),
    );
    return Row(
      children: [
        labelWidth != null ? SizedBox(width: labelWidth! - (showHint ? 24 : 0), child: text) : text,
        if (showHint) _ControlHint(label: label!, hint: hint!, disabled: disabled),
        const SizedBox(width: 4),
        Expanded(child: input),
      ],
    );
  }
}

/// A number on a range for tool panels: a slider with a [NumberField]
/// readout beside it.
///
/// ```dart
/// SliderField(label: 'Opacity', min: 0, max: 1, step: 0.01, value: opacity, onChanged: setOpacity)
/// ```
class SliderField extends StatelessWidget {
  final num value;
  final ValueChanged<num>? onChanged;
  final String? label;
  final num min;
  final num max;
  final num step;
  final bool disabled;

  /// Width reserved for the label so rows line up.
  final double labelWidth;

  /// Help text, shown in a tooltip from an info icon beside the label.
  final String? hint;

  /// A unit drawn at the end of the readout.
  final String? suffix;

  const SliderField({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.disabled = false,
    this.labelWidth = 72,
    this.hint,
    this.suffix,
  }) : assert(min < max);

  num _snap(double raw) {
    final snapped = min + ((raw - min) / step).round() * step;
    final text = step.toString();
    final dot = text.indexOf('.');
    final decimals = dot < 0 || text.endsWith('.0') ? 0 : text.length - dot - 1;
    final num result = step is int && min is int ? snapped.round() : double.parse(snapped.toStringAsFixed(decimals.clamp(0, 10)));
    return result.clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(min, max);
    return Row(
      children: [
        if (label != null) ...[
          SizedBox(
            width: labelWidth - (hint == null ? 0 : 24),
            child: Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _controlLabelStyle(context, disabled: disabled),
            ),
          ),
          if (hint != null) _ControlHint(label: label!, hint: hint!, disabled: disabled),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: IgnorePointer(
            ignoring: disabled,
            child: Opacity(
              opacity: disabled ? 0.4 : 1,
              child: Slider(
                value: clamped.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                onChanged: (raw) {
                  final next = _snap(raw);
                  if (next != value) onChanged?.call(next);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: suffix == null || suffix!.isEmpty ? 64 : 88,
          child: NumberField(
            suffix: suffix,
            value: clamped,
            min: min,
            max: max,
            step: step,
            disabled: disabled,
            onChanged: (next) {
              if (next != null && next >= min && next <= max) onChanged?.call(next);
            },
          ),
        ),
      ],
    );
  }
}

/// The former name of [TextField].
@Deprecated('Use TextField instead. Run `dart fix --apply` to migrate.')
typedef PanelTextField = TextField;
