import 'package:flutter/widgets.dart';
import '../../prime_flutter.dart';

/// A configuration class for a single item in a [FilterGroup].
class FilterItem<T> {
  /// The value identifying this item.
  final T value;

  /// The label widget to display.
  final Widget label;

  /// The color to use when this item is active.
  /// If null, defaults to the theme's actionPrimaryBg.
  final Color? activeColor;

  /// An optional leading widget (e.g. icon).
  final Widget? leading;

  const FilterItem({required this.value, required this.label, this.activeColor, this.leading});
}

/// A widget that manages a group of filter pills.
///
/// Supports multi-selection and individual coloring for active items.
class FilterGroup<T> extends StatelessWidget {
  /// The list of items to display.
  final List<FilterItem<T>> items;

  /// The currently selected values.
  final Set<T> selected;

  /// Callback when selection changes.
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// Whether multiple values can be selected.
  final bool multiSelect;

  const FilterGroup({super.key, required this.items, required this.selected, this.onSelectionChanged, this.multiSelect = true});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: items.map((item) => _buildItem(context, item)).toList());
  }

  Widget _buildItem(BuildContext context, FilterItem<T> item) {
    final isSelected = selected.contains(item.value);

    // activeColor logic is handled by passing color to FilterPill.
    // If item.activeColor is null, FilterPill uses theme default.
    // If item.activeColor is set, FilterPill uses it when selected.

    return FilterPill(
      label: item.label,
      leading: item.leading,
      isSelected: isSelected,
      color: item.activeColor,
      onTap: () => _handleTap(item.value),
    );
  }

  void _handleTap(T value) {
    if (onSelectionChanged == null) return;

    final newSelected = Set<T>.from(selected);

    if (multiSelect) {
      if (newSelected.contains(value)) {
        newSelected.remove(value);
      } else {
        newSelected.add(value);
      }
    } else {
      newSelected.clear();
      newSelected.add(value);
    }

    if (newSelected.length != selected.length || !newSelected.containsAll(selected)) {
      onSelectionChanged!(newSelected);
    }
  }
}
