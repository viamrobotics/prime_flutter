import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'input.dart';
import 'prime_icons.dart';
import 'progress.dart';

/// Groups a label, a control, and hints, and shares `disabled`, `required`
/// and `state` with them.
///
/// [Label], [Input], [Textarea], [Checkbox] and [Hint] placed inside read
/// those values from the field; a value set on a part directly still wins.
///
/// ```dart
/// Field(
///   required: true,
///   state: InputState.error,
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     spacing: 4,
///     children: [
///       Label(label: Text('Email')),
///       Input(keyboardType: TextInputType.emailAddress),
///       Hint(child: Text('Enter a valid address.')),
///     ],
///   ),
/// )
/// ```
class Field extends InheritedWidget {
  final bool disabled;
  final bool required;
  final InputState state;

  const Field({super.key, this.disabled = false, this.required = false, this.state = InputState.none, required super.child});

  /// The enclosing field, if any.
  static Field? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Field>();

  @override
  bool updateShouldNotify(Field oldWidget) => disabled != oldWidget.disabled || required != oldWidget.required || state != oldWidget.state;
}

/// Muted helper text for a form field. Inside a [Field] it follows the
/// field's `disabled` and `state`.
class Hint extends StatelessWidget {
  final Widget child;
  final bool disabled;
  final InputState state;

  const Hint({super.key, required this.child, this.disabled = false, this.state = InputState.none});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final field = Field.maybeOf(context);
    final isDisabled = disabled || (field?.disabled ?? false);
    final current = state != InputState.none ? state : (field?.state ?? InputState.none);
    final color = isDisabled
        ? c.textPlaceholder
        : switch (current) {
            InputState.error => c.statusDangerDark,
            InputState.warn => c.statusWarningDark,
            InputState.info => c.statusInfoDark,
            InputState.none => c.textSecondary,
          };
    return DefaultTextStyle(
      style: theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, color: color),
      child: child,
    );
  }
}

/// A checkbox with an optional indeterminate state.
///
/// ```dart
/// Checkbox(
///   checked: accepted,
///   onChanged: (value) => setState(() => accepted = value),
///   label: const Text('Accept the terms'),
/// )
/// ```
class Checkbox extends StatelessWidget {
  final bool checked;

  /// Shows the mixed state regardless of [checked]. A tap clears it by
  /// reporting `true`.
  final bool indeterminate;

  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final InputState state;

  /// Optional label; tapping it toggles the checkbox too.
  final Widget? label;

  const Checkbox({
    super.key,
    required this.checked,
    this.indeterminate = false,
    this.onChanged,
    this.disabled = false,
    this.state = InputState.none,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final field = Field.maybeOf(context);
    final isDisabled = disabled || (field?.disabled ?? false);
    final isError = (state != InputState.none ? state : field?.state) == InputState.error;
    final isOn = checked || indeterminate;
    final color = isDisabled ? c.iconDisabled : (isError ? c.statusDangerDark : (isOn ? c.iconPrimary : c.iconSecondary));
    final icon = indeterminate ? PrimeIcons.checkboxIndeterminate : (checked ? PrimeIcons.checkboxMarked : PrimeIcons.checkboxBlankOutline);

    return Semantics(
      checked: indeterminate ? null : checked,
      mixed: indeterminate ? true : null,
      enabled: !isDisabled,
      child: MouseRegion(
        cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isDisabled ? null : () => onChanged?.call(indeterminate ? true : !checked),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: color),
                if (label != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: DefaultTextStyle(
                      style: theme.textTheme.bodyDefault.copyWith(height: 1.25, color: isDisabled ? c.textPlaceholder : c.textPrimary),
                      child: label!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A multi-line text input that grows with its content.
///
/// ```dart
/// Textarea(placeholder: 'Notes', rows: 3, onChanged: (text) {})
/// ```
class Textarea extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;

  /// The number of lines shown before the field starts to grow.
  final int rows;

  /// The most lines to grow to before scrolling. Null grows without limit.
  final int? maxRows;

  final ValueChanged<String>? onChanged;
  final bool disabled;
  final bool readOnly;
  final InputState state;
  final FocusNode? focusNode;
  final bool autofocus;

  const Textarea({
    super.key,
    this.controller,
    this.placeholder,
    this.rows = 3,
    this.maxRows,
    this.onChanged,
    this.disabled = false,
    this.readOnly = false,
    this.state = InputState.none,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Input(
      controller: controller,
      placeholder: placeholder,
      minLines: rows,
      maxLines: maxRows,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      disabled: disabled,
      readOnly: readOnly,
      state: state,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }
}

enum StatusDotState { info, warning, success, danger, disabled }

enum StatusDotVariant { solid, hollow }

/// An 8px dot showing a state, gray when there is none.
///
/// ```dart
/// StatusDot(state: StatusDotState.success, label: 'Online')
/// StatusDot(state: StatusDotState.danger, variant: StatusDotVariant.hollow, working: true, label: 'Reconnecting')
/// ```
class StatusDot extends StatelessWidget {
  final StatusDotState? state;
  final StatusDotVariant variant;

  /// Replaces the dot with a spinner in the state's color.
  final bool working;

  /// The accessible name of the dot.
  final String label;

  const StatusDot({super.key, this.state, this.variant = StatusDotVariant.solid, this.working = false, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    final color = switch (state) {
      StatusDotState.info => c.statusInfoDark,
      StatusDotState.warning => c.statusWarningBright,
      StatusDotState.success => c.statusSuccessDark,
      StatusDotState.danger => c.statusDangerDark,
      StatusDotState.disabled => c.iconDisabled,
      null => c.iconSecondary,
    };

    return Semantics(
      image: true,
      label: label,
      child: working
          ? Progress(size: 10, color: color)
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: variant == StatusDotVariant.solid ? color : null,
                border: variant == StatusDotVariant.hollow ? Border.all(color: color, width: 1.5) : null,
              ),
            ),
    );
  }
}
