import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'field.dart';

enum LabelPosition { top, left }

/// Labels a form control.
///
/// ```dart
/// Label(
///   label: const Text('Name'),
///   required: true,
///   child: Input(placeholder: 'Machine name'),
/// )
/// ```
class Label extends StatelessWidget {
  /// The label content.
  final Widget label;

  /// The control being labelled.
  final Widget? child;

  /// Where the label sits relative to [child].
  final LabelPosition position;

  /// Appends a red asterisk.
  final bool required;

  final bool disabled;

  /// Additional muted text after the label, such as "(optional)".
  final String? detail;

  const Label({
    super.key,
    required this.label,
    this.child,
    this.position = LabelPosition.top,
    this.required = false,
    this.disabled = false,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final field = Field.maybeOf(context);
    final disabled = this.disabled || (field?.disabled ?? false);
    final required = this.required || (field?.required ?? false);
    final style = theme.textTheme.bodySmall.copyWith(height: 1.3, color: disabled ? c.textPlaceholder : c.textSecondary);

    final text = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: DefaultTextStyle(style: style, child: label)),
        if (required) Text(' *', style: style.copyWith(color: c.statusDangerDark)),
        if (detail != null && detail!.isNotEmpty) Text(' $detail', style: style.copyWith(color: c.textPlaceholder)),
      ],
    );

    if (child == null) return text;
    if (position == LabelPosition.left) {
      return Row(children: [text, const SizedBox(width: 8), Expanded(child: child!)]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [text, const SizedBox(height: 4), child!],
    );
  }
}
