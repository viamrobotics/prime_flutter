import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'field.dart';
import 'floating.dart';
import 'input.dart';
import 'internal/pressable.dart';
import 'pill.dart';
import 'prime_icons.dart';
import 'progress.dart';

/// An option for [SearchableSelect] and [Multiselect].
class SelectOption {
  /// The value reported to callbacks and matched against searches.
  final String value;

  /// Display text. Defaults to [value].
  final String? label;

  /// Secondary line shown under the label.
  final String? description;

  final IconData? icon;

  const SelectOption(this.value, {this.label, this.description, this.icon});

  String get display => label ?? value;

  /// Wraps plain strings as options.
  static List<SelectOption> fromStrings(Iterable<String> values) => [for (final value in values) SelectOption(value)];
}

/// How search results are ordered.
enum SelectSort {
  /// Matches first (prefix matches ahead of substring matches), then the rest.
  matchesFirst,

  /// Only matching options are shown.
  reduce,

  /// Options keep their order; nothing is filtered.
  off,
}

List<SelectOption> _search(List<SelectOption> options, String query, SelectSort sort) {
  final term = query.trim().toLowerCase();
  if (term.isEmpty || sort == SelectSort.off) return options;

  final prefix = <SelectOption>[];
  final contains = <SelectOption>[];
  final rest = <SelectOption>[];
  for (final option in options) {
    final text = option.display.toLowerCase();
    if (text.startsWith(term)) {
      prefix.add(option);
    } else if (text.contains(term) || option.value.toLowerCase().contains(term)) {
      contains.add(option);
    } else {
      rest.add(option);
    }
  }
  return [...prefix, ...contains, if (sort == SelectSort.matchesFirst) ...rest];
}

/// A text field that searches and selects from a list of options.
///
/// ```dart
/// SearchableSelect(
///   options: SelectOption.fromStrings(['Arm', 'Base', 'Camera']),
///   value: component,
///   exclusive: true,
///   onChanged: (value) => setState(() => component = value),
/// )
/// ```
class SearchableSelect extends StatefulWidget {
  final List<SelectOption> options;

  /// The currently selected value, or an empty string.
  final String value;

  /// Called when a value is committed: an option is picked, Enter is pressed,
  /// or the field loses focus.
  final ValueChanged<String>? onChanged;

  final String placeholder;

  /// When true only values in [options] can be committed. When false any
  /// typed text is accepted.
  final bool exclusive;

  final bool disabled;
  final InputState state;
  final SelectSort sort;

  /// Shows every option on focus until the user types, even when a value is
  /// already selected.
  final bool showAllOnFocus;

  /// Prefix for the "use what I typed" row shown when not [exclusive].
  final String otherOptionPrefix;

  /// Shows a spinner in the menu in place of the options.
  final bool isLoading;

  /// Clears the field after a selection instead of showing it.
  final bool clearValueOnSelect;

  /// Keeps the menu open after a selection.
  final bool closeOnSelect;

  /// Values drawn with a check mark, used by [Multiselect].
  final Set<String> checkedValues;

  final Widget? leading;

  /// Shown in the menu when nothing matches.
  final String emptyText;

  /// Fixed content above and below the options in the menu.
  final Widget? menuHeader;
  final Widget? menuFooter;

  /// Called with the text typed since the menu opened, and with an empty
  /// string when it closes.
  final ValueChanged<String>? onQueryChanged;

  const SearchableSelect({
    super.key,
    required this.options,
    this.value = '',
    this.onChanged,
    this.placeholder = '',
    this.exclusive = false,
    this.disabled = false,
    this.state = InputState.none,
    this.sort = SelectSort.matchesFirst,
    this.showAllOnFocus = false,
    this.otherOptionPrefix = '',
    this.isLoading = false,
    this.clearValueOnSelect = false,
    this.closeOnSelect = true,
    this.checkedValues = const {},
    this.leading,
    this.emptyText = 'No matching results',
    this.onQueryChanged,
    this.menuHeader,
    this.menuFooter,
  });

  @override
  State<SearchableSelect> createState() => _SearchableSelectState();
}

class _SearchableSelectState extends State<SearchableSelect> {
  late final TextEditingController _controller = TextEditingController(text: _displayFor(widget.value));
  late final FocusNode _focusNode = FocusNode(onKeyEvent: _handleKey);
  bool _isOpen = false;
  bool _hasTyped = false;
  int _highlighted = -1;

  /// The last value sent to onChanged that the parent has not yet echoed
  /// back, so submit followed by blur does not report it twice.
  String? _pendingValue;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(SearchableSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pendingValue = null;
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = _displayFor(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _displayFor(String value) {
    for (final option in widget.options) {
      if (option.value == value) return option.display;
    }
    return value;
  }

  SelectOption? _optionFor(String text) {
    final term = text.trim().toLowerCase();
    for (final option in widget.options) {
      if (option.display.toLowerCase() == term || option.value.toLowerCase() == term) return option;
    }
    return null;
  }

  String get _query => widget.showAllOnFocus && !_hasTyped ? '' : _controller.text;

  List<SelectOption> get _results => _search(widget.options, _query, widget.sort);

  bool get _showOther {
    final text = _controller.text.trim();
    return !widget.exclusive && _hasTyped && text.isNotEmpty && _optionFor(text) == null;
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _hasTyped = false;
      _highlighted = -1;
      setState(() => _isOpen = true);
    } else {
      _commitTyped();
      widget.onQueryChanged?.call('');
      setState(() => _isOpen = false);
    }
  }

  void _select(String value) {
    // Remember it, so the blur that follows a pick does not report the same value again.
    if (!widget.clearValueOnSelect) _pendingValue = value;
    widget.onChanged?.call(value);
    _hasTyped = false;
    if (widget.clearValueOnSelect) {
      _controller.clear();
    } else {
      final text = _displayFor(value);
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    if (widget.closeOnSelect) {
      _focusNode.unfocus();
      // The parent may decline the choice, and then no rebuild arrives to restore the text.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus && !widget.clearValueOnSelect) _controller.text = _displayFor(widget.value);
      });
    } else {
      setState(() {});
    }
  }

  /// Resolves whatever is in the field when focus leaves or Enter is pressed.
  void _commitTyped() {
    if (widget.clearValueOnSelect) {
      _controller.clear();
      return;
    }
    final text = _controller.text.trim();
    final match = _optionFor(text);
    final String next;
    if (match != null) {
      next = match.value;
    } else if (text.isEmpty || widget.exclusive) {
      next = widget.exclusive ? widget.value : '';
    } else {
      next = text;
    }
    _controller.text = _displayFor(next);
    if (next != widget.value && next != _pendingValue) {
      _pendingValue = next;
      widget.onChanged?.call(next);
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final results = _results;
    final count = results.length + (_showOther ? 1 : 0);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowUp) {
      if (count == 0) return KeyEventResult.handled;
      final step = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
      setState(() {
        _isOpen = true;
        // From nothing highlighted, Down starts at the top and Up wraps to the bottom.
        _highlighted = _highlighted < 0 ? (step > 0 ? 0 : count - 1) : (_highlighted + step) % count;
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _controller.text = _displayFor(widget.value);
      _focusNode.unfocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter && _highlighted >= 0 && _highlighted < count) {
      _select(_highlighted < results.length ? results[_highlighted].value : _controller.text.trim());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final radius = BorderRadius.circular(theme.cornerRadius);

    return Floating(
      visible: _isOpen && !widget.disabled,
      matchWidth: true,
      onTapOutside: () => _focusNode.unfocus(),
      floatingBuilder: (context) {
        final results = _results;
        final showOther = _showOther;
        final Widget content;
        if (widget.isLoading) {
          content = const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Progress()),
          );
        } else if (results.isEmpty && !showOther) {
          content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(widget.emptyText, style: theme.textTheme.bodySmall.copyWith(color: c.textPlaceholder)),
          );
        } else {
          content = ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (int i = 0; i < results.length; i++)
                _OptionRow(
                  option: results[i],
                  highlighted: i == _highlighted,
                  selected: results[i].value == widget.value && !widget.clearValueOnSelect,
                  checked: widget.checkedValues.contains(results[i].value),
                  onTap: () => _select(results[i].value),
                ),
              if (showOther)
                _OptionRow(
                  option: SelectOption(_controller.text.trim(), label: '${widget.otherOptionPrefix} ${_controller.text.trim()}'.trim()),
                  highlighted: _highlighted == results.length,
                  selected: false,
                  checked: false,
                  onTap: () => _select(_controller.text.trim()),
                ),
            ],
          );
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 280),
          decoration: BoxDecoration(
            color: c.surfaceBase,
            borderRadius: radius,
            border: Border.all(color: c.iconDisabled),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: widget.menuHeader == null && widget.menuFooter == null
                ? content
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ?widget.menuHeader,
                      Flexible(child: content),
                      ?widget.menuFooter,
                    ],
                  ),
          ),
        );
      },
      child: Input(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widget.placeholder,
        disabled: widget.disabled,
        state: widget.state,
        leading: widget.leading,
        trailing: widget.state == InputState.none ? const Icon(PrimeIcons.chevronDown) : null,
        autocorrect: false,
        onChanged: (text) {
          widget.onQueryChanged?.call(text);
          _hasTyped = true;
          _highlighted = -1;
          setState(() => _isOpen = true);
        },
        onSubmitted: () {
          _commitTyped();
          _focusNode.unfocus();
        },
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final SelectOption option;
  final bool highlighted;
  final bool selected;
  final bool checked;
  final VoidCallback onTap;

  const _OptionRow({required this.option, required this.highlighted, required this.selected, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    return Pressable(
      onTap: onTap,
      builder: (context, hovered, pressed) => Semantics(
        selected: selected || checked,
        child: Container(
          color: pressed ? c.surfaceHighlight : (hovered || highlighted ? c.surfaceHover : (selected ? c.surfaceOffset : null)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (option.icon != null) ...[Icon(option.icon, size: 18, color: c.iconSecondary), const SizedBox(width: 8)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyDefault.copyWith(height: 1.25),
                    ),
                    if (option.description != null)
                      Text(
                        option.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, color: c.textPlaceholder),
                      ),
                  ],
                ),
              ),
              if (checked) ...[const SizedBox(width: 8), Icon(PrimeIcons.check, size: 18, color: c.iconPrimary)],
            ],
          ),
        ),
      ),
    );
  }
}

/// A searchable field for choosing several options, shown as removable pills
/// above the field.
///
/// For a non-searchable picker, use [PrimeMultiDropdown].
///
/// ```dart
/// Multiselect(
///   options: SelectOption.fromStrings(['Arm', 'Base', 'Camera']),
///   selected: components,
///   onChanged: (values) => setState(() => components = values),
/// )
/// ```
class Multiselect extends StatelessWidget {
  final List<SelectOption> options;

  /// The selected values, in selection order.
  final List<String> selected;

  /// Called with the full updated selection.
  final ValueChanged<List<String>>? onChanged;

  final String placeholder;
  final bool disabled;
  final InputState state;
  final SelectSort sort;

  /// Whether selected values are listed as pills above the field.
  final bool showPills;

  /// Shows a "Clear all" control when anything is selected.
  final bool clearable;

  final bool isLoading;

  /// A heading at the top of the menu.
  final String? heading;

  /// A call-to-action at the bottom of the menu, such as "Add new".
  final String? buttonText;
  final IconData? buttonIcon;
  final VoidCallback? onButtonPressed;

  const Multiselect({
    super.key,
    required this.options,
    this.selected = const [],
    this.onChanged,
    this.placeholder = '',
    this.disabled = false,
    this.state = InputState.none,
    this.sort = SelectSort.reduce,
    this.showPills = true,
    this.clearable = false,
    this.isLoading = false,
    this.heading,
    this.buttonText,
    this.buttonIcon,
    this.onButtonPressed,
  });

  void _toggle(String value) {
    if (value.isEmpty) return;
    onChanged?.call(
      selected.contains(value)
          ? [
              for (final item in selected)
                if (item != value) item,
            ]
          : [...selected, value],
    );
  }

  String _displayFor(String value) {
    for (final option in options) {
      if (option.value == value) return option.display;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Above the field, so the open menu never covers them.
        if (showPills && selected.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final value in selected) Pill(value: _displayFor(value), disabled: disabled, onRemove: (_) => _toggle(value)),
              if (clearable && !disabled)
                GestureDetector(
                  onTap: () => onChanged?.call(const []),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text('Clear all', style: theme.textTheme.link.copyWith(fontSize: 12)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SearchableSelect(
          options: options,
          placeholder: placeholder,
          disabled: disabled,
          state: state,
          sort: sort,
          isLoading: isLoading,
          exclusive: true,
          showAllOnFocus: true,
          clearValueOnSelect: true,
          closeOnSelect: false,
          checkedValues: selected.toSet(),
          onChanged: _toggle,
          menuHeader: heading == null
              ? null
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Text(
                    heading!,
                    style: theme.textTheme.bodySmall.copyWith(
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.textTertiary,
                    ),
                  ),
                ),
          menuFooter: buttonText == null
              ? null
              : Pressable(
                  onTap: onButtonPressed,
                  builder: (context, hovered, pressed) => Container(
                    decoration: BoxDecoration(
                      color: pressed ? theme.colorScheme.surfaceHighlight : (hovered ? theme.colorScheme.surfaceHover : null),
                      border: Border(top: BorderSide(color: theme.colorScheme.borderSubtle)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        if (buttonIcon != null) ...[
                          Icon(buttonIcon, size: 18, color: theme.colorScheme.iconSecondary),
                          const SizedBox(width: 8),
                        ],
                        Flexible(child: Text(buttonText!, style: theme.textTheme.bodyDefault.copyWith(height: 1.25))),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// One option of a [Combobox].
class ComboboxItem<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;

  const ComboboxItem({required this.value, required this.label, this.description, this.icon});
}

/// A text input that filters a list of options as the user types and selects
/// one of them. Only listed options can be chosen; to accept free text, use
/// [SearchableSelect], and to pick without typing, use [PrimeDropdown].
///
/// ```dart
/// Combobox<String>(
///   items: const [
///     ComboboxItem(value: 'us-east', label: 'US East'),
///     ComboboxItem(value: 'us-west', label: 'US West'),
///   ],
///   value: region,
///   placeholder: 'Search regions',
///   emptyText: 'No matching region',
///   onChanged: (next) => setState(() => region = next),
/// )
/// ```
class Combobox<T> extends StatelessWidget {
  /// The single source of truth for the options.
  final List<ComboboxItem<T>> items;

  /// The selected value, or null.
  final T? value;

  /// Called with the new selection, or null when it is cleared. Leave your
  /// state as it was to decline a choice.
  final ValueChanged<T?>? onChanged;

  /// Called with the text typed since the list opened; empty when it closes.
  final ValueChanged<String>? onQueryChanged;

  final String placeholder;

  /// Shown when nothing matches.
  final String emptyText;

  /// Whether picking the selected option again clears the selection.
  final bool allowDeselect;

  final bool disabled;
  final InputState state;

  const Combobox({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.onQueryChanged,
    this.placeholder = '',
    this.emptyText = 'No matching results',
    this.allowDeselect = false,
    this.disabled = false,
    this.state = InputState.none,
  });

  @override
  Widget build(BuildContext context) {
    // Options are addressed by position, so any value type works and labels may repeat.
    String keyOf(int index) => '$index';
    final selected = items.indexWhere((item) => item.value == value);
    final field = Field.maybeOf(context);

    return SearchableSelect(
      options: [
        for (int i = 0; i < items.length; i++)
          SelectOption(keyOf(i), label: items[i].label, description: items[i].description, icon: items[i].icon),
      ],
      value: selected < 0 ? '' : keyOf(selected),
      checkedValues: selected < 0 ? const {} : {keyOf(selected)},
      exclusive: true,
      sort: SelectSort.reduce,
      showAllOnFocus: true,
      placeholder: placeholder,
      emptyText: emptyText,
      disabled: disabled || (field?.disabled ?? false),
      state: state,
      onQueryChanged: onQueryChanged,
      onChanged: (key) {
        final index = int.tryParse(key);
        if (index == null || index < 0 || index >= items.length) {
          if (value != null) onChanged?.call(null);
        } else if (index == selected) {
          if (allowDeselect) onChanged?.call(null);
        } else {
          onChanged?.call(items[index].value);
        }
      },
    );
  }
}
