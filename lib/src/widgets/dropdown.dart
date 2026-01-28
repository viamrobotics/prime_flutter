import 'dart:ui' as ui;

import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import '../theme/prime_theme_data.dart';
import 'prime_icons.dart';

/// A dropdown widget that lets the user choose a single value from a list.
///
/// Styled to match [Input] and other Prime form controls. Use [itemBuilder] to
/// customize how each option is displayed; otherwise [items] are shown using
/// [Object.toString].
///
/// Example:
///
/// ```dart
/// PrimeDropdown<String>(
///   value: selected,
///   placeholder: 'Select an option',
///   items: ['Apple', 'Banana', 'Orange'],
///   onChanged: (v) => setState(() => selected = v),
/// )
/// ```
class PrimeDropdown<T> extends StatefulWidget {
  /// The currently selected value, or null if none.
  final T? value;

  /// All selectable options.
  final List<T> items;

  /// Called when the selection changes.
  final ValueChanged<T?>? onChanged;

  /// Hint text when [value] is null.
  final String? placeholder;

  /// Optional builder for each option. Defaults to [Object.toString].
  final Widget Function(T)? itemBuilder;

  /// Whether the dropdown is disabled.
  final bool disabled;

  const PrimeDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.placeholder,
    this.itemBuilder,
    this.disabled = false,
  });

  @override
  State<PrimeDropdown<T>> createState() => _PrimeDropdownState<T>();
}

class _PrimeDropdownState<T> extends State<PrimeDropdown<T>> {
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _open() {
    if (widget.disabled || widget.items.isEmpty) return;
    if (_overlayEntry != null) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final theme = PrimeTheme.of(context);
    final triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (triggerBox == null || !triggerBox.hasSize) return;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _DropdownOverlay<T>(
        layerLink: _layerLink,
        triggerSize: triggerBox.size,
        triggerOffset: Offset.zero,
        theme: theme,
        value: widget.value,
        items: widget.items,
        itemBuilder: widget.itemBuilder,
        onSelected: (v) {
          _close();
          widget.onChanged?.call(v);
        },
        onDismiss: _close,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final isOpen = _overlayEntry != null;
        final hasValue = widget.value != null;

        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: widget.disabled ? null : _open,
            behavior: HitTestBehavior.opaque,
            child: MouseRegion(
              cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
              child: Container(
                key: _triggerKey,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceBase,
                  borderRadius: BorderRadius.circular(theme.cornerRadius),
                  border: Border.all(
                    color: isOpen ? theme.colorScheme.inputFocus : theme.colorScheme.borderSubtle,
                    width: isOpen ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle(
                        style: theme.textTheme.bodyDefault.copyWith(
                          color: hasValue ? theme.colorScheme.inputText : theme.colorScheme.textTertiary,
                          height: 1.25,
                        ),
                        child: hasValue
                            ? (widget.itemBuilder != null
                                ? widget.itemBuilder!(widget.value as T)
                                : Text('${widget.value}'))
                            : Text(widget.placeholder ?? ''),
                      ),
                    ),
                    Icon(
                      PrimeIcons.chevronDown,
                      size: 20,
                      color: theme.colorScheme.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DropdownOverlay<T> extends StatefulWidget {
  final LayerLink layerLink;
  final Size triggerSize;
  final Offset triggerOffset;
  final PrimeThemeData theme;
  final T? value;
  final List<T> items;
  final Widget Function(T)? itemBuilder;
  final ValueChanged<T?> onSelected;
  final VoidCallback onDismiss;

  const _DropdownOverlay({
    required this.layerLink,
    required this.triggerSize,
    required this.triggerOffset,
    required this.theme,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onSelected,
    required this.onDismiss,
  });

  @override
  State<_DropdownOverlay<T>> createState() => _DropdownOverlayState<T>();
}

class _DropdownOverlayState<T> extends State<_DropdownOverlay<T>> {
  static const double _maxHeight = 280;
  static const double _itemHeight = 44;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final listHeight = (widget.items.length * _itemHeight).clamp(0.0, _maxHeight);

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
        Positioned(
          width: widget.triggerSize.width,
          child: CompositedTransformFollower(
            link: widget.layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, widget.triggerSize.height + 4),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                constraints: BoxConstraints(maxHeight: listHeight),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceBase,
                  borderRadius: BorderRadius.circular(theme.cornerRadius),
                  border: Border.all(color: theme.colorScheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: ui.Color.fromARGB(38, 0, 0, 0),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.cornerRadius),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isSelected = item == widget.value;
                      return _DropdownItem<T>(
                        item: item,
                        theme: theme,
                        isSelected: isSelected,
                        itemBuilder: widget.itemBuilder,
                        onTap: () => widget.onSelected(item),
                      );
                    },
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

class _DropdownItem<T> extends StatefulWidget {
  final T item;
  final PrimeThemeData theme;
  final bool isSelected;
  final Widget Function(T)? itemBuilder;
  final VoidCallback onTap;

  const _DropdownItem({
    required this.item,
    required this.theme,
    required this.isSelected,
    required this.itemBuilder,
    required this.onTap,
  });

  @override
  State<_DropdownItem<T>> createState() => _DropdownItemState<T>();
}

class _DropdownItemState<T> extends State<_DropdownItem<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colors = theme.colorScheme;
    final bg = widget.isSelected
        ? colors.actionPrimaryBg
        : (_hovered ? colors.surfaceHighlight : colors.surfaceBase);
    final fg = widget.isSelected ? colors.actionPrimaryFg : colors.textPrimary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: _DropdownOverlayState._itemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: bg,
          alignment: Alignment.centerLeft,
          child: DefaultTextStyle(
            style: theme.textTheme.bodyDefault.copyWith(color: fg, height: 1.25),
            child: widget.itemBuilder != null
                ? widget.itemBuilder!(widget.item)
                : Text('${widget.item}'),
          ),
        ),
      ),
    );
  }
}
