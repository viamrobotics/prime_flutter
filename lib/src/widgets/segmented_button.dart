import 'package:flutter/material.dart';

import '../../prime_flutter.dart';

/// A segmented button widget.
///
/// Allows users to select one or multiple options from a set.
/// The look and feel matches the Secondary Button variant.
class SegmentedButton<T> extends StatelessWidget {
  /// The segments to display. Keys are the values, values are the labels (widgets).
  final Map<T, Widget> segments;

  /// The currently selected values.
  final Set<T> selected;

  /// Callback when selection changes.
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// Whether multiple values can be selected.
  final bool multiSelect;

  /// Whether the selection can be empty.
  /// If false, tapping the last selected item in single-select mode does nothing,
  /// and unselecting the last item in multi-select mode is prevented.
  final bool allowEmpty;

  const SegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    this.onSelectionChanged,
    this.multiSelect = false,
    this.allowEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final colors = theme.colorScheme;
        final cornerRadius = theme.cornerRadius;

        return Container(
          decoration: BoxDecoration(color: colors.surfaceHighlight, borderRadius: BorderRadius.circular(cornerRadius)),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in segments.entries)
                  _Segment<T>(
                    value: entry.key,
                    label: entry.value,
                    isSelected: selected.contains(entry.key),
                    isFirst: entry.key == segments.keys.first,
                    isLast: entry.key == segments.keys.last,
                    cornerRadius: cornerRadius,
                    onTap: () => _handleTap(entry.key),
                    theme: theme,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTap(T value) {
    if (onSelectionChanged == null) return;

    final newSelected = Set<T>.from(selected);

    if (multiSelect) {
      if (newSelected.contains(value)) {
        if (allowEmpty || newSelected.length > 1) {
          newSelected.remove(value);
        }
      } else {
        newSelected.add(value);
      }
    } else {
      if (newSelected.contains(value)) {
        if (allowEmpty) {
          newSelected.remove(value);
        }
      } else {
        newSelected.clear();
        newSelected.add(value);
      }
    }

    if (newSelected.length != selected.length || !newSelected.containsAll(selected)) {
      onSelectionChanged!(newSelected);
    }
  }
}

class _Segment<T> extends StatefulWidget {
  final T value;
  final Widget label;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final double cornerRadius;
  final VoidCallback onTap;
  final PrimeThemeData theme;

  const _Segment({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.cornerRadius,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_Segment<T>> createState() => _SegmentState<T>();
}

class _SegmentState<T> extends State<_Segment<T>> {
  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colorScheme;

    // Determine colors based on state
    Color backgroundColor = widget.isSelected ? colors.actionNeutralBg : colors.surfaceHighlight;
    Color foregroundColor = colors.textPrimary;

    // Border Radius: only outer corners should be rounded
    final radius = Radius.circular(widget.cornerRadius);
    final borderRadius = BorderRadius.horizontal(left: widget.isFirst ? radius : Radius.zero, right: widget.isLast ? radius : Radius.zero);

    // Border Logic
    final darkBorder = colors.textTertiary;
    final lightBorder = colors.borderSubtle;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            border: Border.all(color: widget.isSelected ? darkBorder : lightBorder, width: 1),
          ),
          child: DefaultTextStyle(
            style: widget.theme.textTheme.bodyDefault.copyWith(
              color: foregroundColor,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
              height: 1.0,
            ),
            child: widget.label,
          ),
        ),
      ),
    );
  }
}
