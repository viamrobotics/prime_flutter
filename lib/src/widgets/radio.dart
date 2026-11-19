import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'prime_icons.dart';

/// One choice in a [Radio] group.
class RadioOption<T> {
  final String label;
  final T value;

  /// Secondary text under the label.
  final String? description;

  final bool disabled;

  /// Optional icon shown before the label.
  final IconData? icon;
  final Color? iconColor;

  /// Extra content rendered under the option. Shown only while the option is
  /// selected unless [alwaysShowContent] is true.
  final Widget? content;
  final bool alwaysShowContent;

  /// Error text shown beneath [content].
  final String? errorMessage;

  const RadioOption({
    required this.label,
    required this.value,
    this.description,
    this.disabled = false,
    this.icon,
    this.iconColor,
    this.content,
    this.alwaysShowContent = false,
    this.errorMessage,
  });
}

/// Lets the user choose one of a set of mutually exclusive options.
///
/// ```dart
/// Radio<String>(
///   legend: const Text('Frequency'),
///   options: const [
///     RadioOption(label: 'Daily', value: 'daily'),
///     RadioOption(label: 'Weekly', value: 'weekly', description: 'Every Monday'),
///   ],
///   selected: frequency,
///   onChanged: (value) => setState(() => frequency = value),
/// )
/// ```
class Radio<T> extends StatelessWidget {
  final List<RadioOption<T>> options;
  final T? selected;
  final ValueChanged<T>? onChanged;

  /// Disables every option.
  final bool disabled;

  /// Marks the legend with a red asterisk.
  final bool required;

  /// Optional group label.
  final Widget? legend;

  /// Lay options out in a column (default) or a row.
  final Axis direction;

  const Radio({
    super.key,
    required this.options,
    this.selected,
    this.onChanged,
    this.disabled = false,
    this.required = false,
    this.legend,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final legendStyle = theme.textTheme.bodySmall.copyWith(height: 1.3, color: c.textSecondary);
    final items = [for (final option in options) _buildOption(context, option)];

    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (legend != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: DefaultTextStyle(style: legendStyle, child: legend!),
                ),
                if (required) Text(' *', style: legendStyle.copyWith(color: c.statusDangerDark)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (direction == Axis.horizontal)
            Wrap(spacing: 16, runSpacing: 4, children: items)
          else
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: items),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, RadioOption<T> option) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final isDisabled = disabled || option.disabled;
    final isSelected = option.value == selected;
    final markColor = isDisabled ? c.iconDisabled : (isSelected ? c.iconPrimary : c.iconSecondary);
    final labelColor = isDisabled ? c.textPlaceholder : (isSelected ? c.textPrimary : c.textSecondary);
    final labelStyle = theme.textTheme.bodyDefault.copyWith(
      height: 1.25,
      color: labelColor,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
    );
    final showContent = option.content != null && (isSelected || option.alwaysShowContent);

    final row = Row(
      mainAxisSize: direction == Axis.horizontal ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(isSelected ? PrimeIcons.radioboxMarked : PrimeIcons.radioboxBlank, size: 20, color: markColor),
        const SizedBox(width: 8),
        if (option.icon != null) ...[
          Icon(option.icon, size: 20, color: isDisabled ? c.iconDisabled : (option.iconColor ?? c.textTertiary)),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(option.label, style: labelStyle),
              if (option.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    option.description!,
                    style: theme.textTheme.bodySmall.copyWith(height: 1.3, color: isDisabled ? c.textPlaceholder : c.textTertiary),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          inMutuallyExclusiveGroup: true,
          checked: isSelected,
          enabled: !isDisabled,
          child: MouseRegion(
            cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isDisabled || isSelected ? null : () => onChanged?.call(option.value),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: row),
            ),
          ),
        ),
        if (showContent)
          Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                option.content!,
                if (option.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(option.errorMessage!, style: theme.textTheme.bodySmall.copyWith(height: 1.3, color: c.statusDangerDark)),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
