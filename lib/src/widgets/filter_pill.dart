import 'package:flutter/widgets.dart';
import '../../prime_flutter.dart';

/// A filter pill widget. Used to filter data.
class FilterPill extends StatelessWidget {
  /// The label of the filter pill.
  final Widget? label;

  /// Whether the filter pill is selected.
  final bool isSelected;

  /// The callback function to be called when the filter pill is tapped.
  final VoidCallback? onTap;

  /// The color of the filter pill. If null, the theme's primary color is used.
  final Color? color;

  /// The leading widget of the filter pill. A widget to be displayed before the label.
  final Widget? leading;

  const FilterPill({super.key, this.label, this.isSelected = false, this.onTap, this.color, this.leading});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final selectedColor = color ?? theme.colorScheme.actionPrimaryBg;
        final backgroundColor = isSelected ? selectedColor : theme.colorScheme.surfaceBase;
        final borderColor = isSelected ? selectedColor : theme.colorScheme.borderSubtle;
        final textColor = isSelected ? theme.colorScheme.actionPrimaryFg : theme.colorScheme.textSecondary;

        return IconTheme(
          data: IconThemeData(color: textColor),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(100), // Stadium shape
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
                  DefaultTextStyle(
                    style: theme.textTheme.bodyDefault.copyWith(color: textColor, fontWeight: FontWeight.w500),
                    child: label ?? const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
