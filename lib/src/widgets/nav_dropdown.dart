import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'floating.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';

/// A destination in a [NavDropdown].
class NavOption<T> {
  final String label;

  /// Short qualifier shown in parentheses after the label.
  final String? detail;

  /// Secondary line shown in the menu only.
  final String? description;

  /// Identifies the destination, e.g. a route path.
  final T value;

  /// Overrides what the closed control shows when this option is selected.
  final String? selectedText;

  const NavOption({required this.label, required this.value, this.detail, this.description, this.selectedText});
}

/// A dropdown for switching between destinations, such as the pages of a
/// section on a narrow screen.
///
/// ```dart
/// NavDropdown<String>(
///   options: const [
///     NavOption(label: 'Overview', value: '/overview'),
///     NavOption(label: 'Logs', value: '/logs', description: 'Live and historical'),
///   ],
///   selected: currentPath,
///   onSelected: (path) => router.go(path),
/// )
/// ```
class NavDropdown<T> extends StatefulWidget {
  final List<NavOption<T>> options;
  final T? selected;
  final ValueChanged<T>? onSelected;

  const NavDropdown({super.key, required this.options, this.selected, this.onSelected});

  @override
  State<NavDropdown<T>> createState() => _NavDropdownState<T>();
}

class _NavDropdownState<T> extends State<NavDropdown<T>> {
  bool _isOpen = false;

  /// The option the arrow keys are on while the menu is open.
  int _active = -1;

  void _setOpen(bool open) {
    if (_isOpen == open) return;
    setState(() {
      _isOpen = open;
      _active = open ? widget.options.indexWhere((option) => option.value == widget.selected) : -1;
    });
    if (open) {
      HardwareKeyboard.instance.addHandler(_handleKey);
    } else {
      HardwareKeyboard.instance.removeHandler(_handleKey);
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  /// Arrow keys walk the options and wrap; Enter or Space picks; Escape and Tab close.
  bool _handleKey(KeyEvent event) {
    if (event is KeyUpEvent || !_isOpen) return false;
    final key = event.logicalKey;
    final count = widget.options.length;
    if (key == LogicalKeyboardKey.escape) {
      _setOpen(false);
    } else if (key == LogicalKeyboardKey.tab) {
      _setOpen(false);
      return false;
    } else if (key == LogicalKeyboardKey.arrowDown && count > 0) {
      setState(() => _active = (_active + 1) % count);
    } else if (key == LogicalKeyboardKey.arrowUp && count > 0) {
      setState(() => _active = (_active - 1 + count) % count);
    } else if ((key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) && _active >= 0 && _active < count) {
      final value = widget.options[_active].value;
      _setOpen(false);
      widget.onSelected?.call(value);
    } else {
      return false;
    }
    return true;
  }

  Widget _optionText(BuildContext context, NavOption<T> option, {bool includeDescription = true}) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final style = theme.textTheme.bodyDefault.copyWith(height: 1.25);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: option.label,
            children: [
              if (option.detail != null)
                TextSpan(
                  text: ' (${option.detail})',
                  style: TextStyle(color: c.textPlaceholder),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
        if (includeDescription && option.description != null)
          Text(
            option.description!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, color: c.textPlaceholder),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final radius = BorderRadius.circular(theme.cornerRadius);
    NavOption<T>? selectedOption;
    for (final option in widget.options) {
      if (option.value == widget.selected) selectedOption = option;
    }

    return Floating(
      visible: _isOpen,
      matchWidth: true,
      onTapOutside: () => _setOpen(false),
      floatingBuilder: (context) => Container(
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          color: c.surfaceBase,
          borderRadius: radius,
          border: Border.all(color: c.iconDisabled),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, option) in widget.options.indexed)
                  Pressable(
                    onTap: () {
                      _setOpen(false);
                      widget.onSelected?.call(option.value);
                    },
                    builder: (context, hovered, pressed) => Semantics(
                      selected: option.value == widget.selected,
                      child: Container(
                        color: pressed
                            ? c.surfaceHighlight
                            : (hovered || index == _active ? c.surfaceHover : (option.value == widget.selected ? c.surfaceOffset : null)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: _optionText(context, option),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      child: Semantics(
        button: true,
        expanded: _isOpen,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _setOpen(!_isOpen),
            child: Container(
              height: 44,
              padding: const EdgeInsets.only(left: 16, right: 12),
              decoration: BoxDecoration(
                color: c.surfaceBase,
                borderRadius: radius,
                border: Border.all(color: _isOpen ? c.inputFocus : c.borderSubtle, width: _isOpen ? 2 : 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: selectedOption == null
                        ? const SizedBox.shrink()
                        : selectedOption.selectedText != null
                        ? Text(
                            selectedOption.selectedText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyDefault.copyWith(height: 1.25),
                          )
                        : _optionText(context, selectedOption, includeDescription: false),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(PrimeIcons.chevronDown, size: 20, color: c.iconSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
