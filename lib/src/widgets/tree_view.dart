import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'prime_icons.dart';

/// Whether one node or several can be selected at a time.
enum TreeSelectionMode { single, multiple }

/// What a tap, Enter, or Space on a branch row does. The chevron always
/// toggles.
enum TreeBranchClick {
  /// Opens or closes the branch and never selects it, for trees whose
  /// branches are folders rather than choices.
  toggle,

  /// Selects the branch and leaves opening it to the chevron.
  select,

  /// Does both.
  toggleAndSelect,
}

/// The state of one node, passed to [TreeView.nodeBuilder].
class TreeNodeState {
  /// The node's value from `nodeToValue`.
  final String value;

  /// The node has children, or `nodeToChildrenCount` says it may.
  final bool isBranch;

  /// The branch is open. Always false on a leaf.
  final bool expanded;
  final bool selected;

  /// The node holds the tree's roving keyboard focus.
  final bool focused;
  final bool disabled;

  /// Nesting depth, starting at 1 for a root node.
  final int depth;

  /// The index of the node and of each ancestor within its siblings.
  final List<int> indexPath;

  const TreeNodeState({
    required this.value,
    required this.isBranch,
    required this.expanded,
    required this.selected,
    required this.focused,
    required this.disabled,
    required this.depth,
    required this.indexPath,
  });
}

class _Row<T> {
  final T node;
  final TreeNodeState state;
  final String? parentValue;

  const _Row(this.node, this.state, this.parentValue);
}

/// A tree of expandable, selectable rows with full keyboard navigation.
///
/// The tree never inspects a node directly: the `nodeTo*` accessors describe
/// your node type, so any shape works.
///
/// ```dart
/// TreeView<FileNode>(
///   nodes: files,
///   nodeToValue: (file) => file.path,
///   nodeToString: (file) => file.name,
///   nodeToChildren: (file) => file.children,
///   expanded: expanded,
///   onExpandedChanged: (next) => setState(() => expanded = next),
///   selected: selected,
///   onSelectedChanged: (next) => setState(() => selected = next),
/// )
/// ```
///
/// Leave [expanded] or [selected] null to let the tree manage that state.
///
/// Keyboard: Up/Down move focus, Right expands or enters a branch, Left
/// collapses or moves to the parent, Home/End jump, Enter/Space activate,
/// `*` expands every sibling, and typing a character jumps to the next match.
class TreeView<T> extends StatefulWidget {
  /// The root nodes.
  final List<T> nodes;

  /// A stable, unique id for the node.
  final String Function(T node) nodeToValue;

  /// The node's label, used for the default row and for type-ahead.
  final String Function(T node) nodeToString;

  /// The node's children. Null or empty makes the node a leaf.
  final List<T>? Function(T node) nodeToChildren;

  /// Return a number for a branch that may have no children, such as an
  /// empty folder, so it still renders as a branch.
  final int? Function(T node)? nodeToChildrenCount;

  /// A disabled node cannot be selected or expanded.
  final bool Function(T node)? isNodeDisabled;

  /// Values of the expanded branches. Null lets the tree manage them,
  /// starting from [initiallyExpanded].
  final Set<String>? expanded;
  final Set<String> initiallyExpanded;
  final ValueChanged<Set<String>>? onExpandedChanged;

  /// Values of the selected nodes. Null lets the tree manage them.
  final Set<String>? selected;
  final ValueChanged<Set<String>>? onSelectedChanged;

  final TreeSelectionMode selectionMode;
  final TreeBranchClick branchClick;

  /// Renders a node's content, to the right of the chevron. Defaults to the
  /// `nodeToString` label.
  final Widget Function(BuildContext context, T node, TreeNodeState state)? nodeBuilder;

  /// Horizontal indent per nesting level.
  final double indent;

  /// Draws a vertical guide line for each ancestor level.
  final bool showIndentGuides;

  /// Accessible name of the tree.
  final String? semanticLabel;

  const TreeView({
    super.key,
    required this.nodes,
    required this.nodeToValue,
    required this.nodeToString,
    required this.nodeToChildren,
    this.nodeToChildrenCount,
    this.isNodeDisabled,
    this.expanded,
    this.initiallyExpanded = const {},
    this.onExpandedChanged,
    this.selected,
    this.onSelectedChanged,
    this.selectionMode = TreeSelectionMode.single,
    this.branchClick = TreeBranchClick.toggleAndSelect,
    this.nodeBuilder,
    this.indent = 16,
    this.showIndentGuides = false,
    this.semanticLabel,
  });

  @override
  State<TreeView<T>> createState() => _TreeViewState<T>();
}

class _TreeViewState<T> extends State<TreeView<T>> {
  late Set<String> _expanded = {...widget.initiallyExpanded};
  Set<String> _selected = {};
  String? _focusedValue;
  bool _hasFocus = false;
  final FocusNode _focusNode = FocusNode();
  final Map<String, GlobalKey> _rowKeys = {};

  Set<String> get _effectiveExpanded => widget.expanded ?? _expanded;
  Set<String> get _effectiveSelected => widget.selected ?? _selected;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool _isBranch(T node) {
    final count = widget.nodeToChildrenCount?.call(node);
    if (count != null) return true;
    return widget.nodeToChildren(node)?.isNotEmpty ?? false;
  }

  List<_Row<T>> _visibleRows() {
    final rows = <_Row<T>>[];
    final expanded = _effectiveExpanded;
    final selected = _effectiveSelected;

    void walk(List<T> nodes, int depth, List<int> path, String? parent) {
      for (int i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final value = widget.nodeToValue(node);
        final isBranch = _isBranch(node);
        final isExpanded = isBranch && expanded.contains(value);
        final indexPath = [...path, i];
        rows.add(
          _Row(
            node,
            TreeNodeState(
              value: value,
              isBranch: isBranch,
              expanded: isExpanded,
              selected: selected.contains(value),
              focused: value == _focusedValue,
              disabled: widget.isNodeDisabled?.call(node) ?? false,
              depth: depth,
              indexPath: indexPath,
            ),
            parent,
          ),
        );
        if (isExpanded) walk(widget.nodeToChildren(node) ?? const [], depth + 1, indexPath, value);
      }
    }

    walk(widget.nodes, 1, const [], null);
    return rows;
  }

  void _setExpanded(Set<String> next) {
    if (widget.expanded == null) setState(() => _expanded = next);
    widget.onExpandedChanged?.call(next);
  }

  void _toggle(_Row<T> row) {
    if (!row.state.isBranch || row.state.disabled) return;
    final next = {..._effectiveExpanded};
    if (!next.remove(row.state.value)) next.add(row.state.value);
    _setExpanded(next);
  }

  void _select(_Row<T> row, {bool extend = false}) {
    if (row.state.disabled) return;
    final value = row.state.value;
    final Set<String> next;
    if (widget.selectionMode == TreeSelectionMode.multiple && extend) {
      next = {..._effectiveSelected};
      if (!next.remove(value)) next.add(value);
    } else {
      next = {value};
    }
    if (widget.selected == null) setState(() => _selected = next);
    widget.onSelectedChanged?.call(next);
  }

  void _activate(_Row<T> row, {bool extend = false}) {
    if (row.state.disabled) return;
    if (!row.state.isBranch) {
      _select(row, extend: extend);
      return;
    }
    switch (widget.branchClick) {
      case TreeBranchClick.toggle:
        _toggle(row);
      case TreeBranchClick.select:
        _select(row, extend: extend);
      case TreeBranchClick.toggleAndSelect:
        _select(row, extend: extend);
        _toggle(row);
    }
  }

  void _focusRow(String value) {
    setState(() => _focusedValue = value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rowContext = _rowKeys[value]?.currentContext;
      if (rowContext != null && rowContext.mounted) {
        Scrollable.ensureVisible(rowContext, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
        Scrollable.ensureVisible(rowContext, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
      }
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final rows = _visibleRows();
    if (rows.isEmpty) return KeyEventResult.ignored;
    int index = rows.indexWhere((row) => row.state.value == _focusedValue);
    final key = event.logicalKey;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    void moveTo(int next) {
      final clamped = next.clamp(0, rows.length - 1);
      _focusRow(rows[clamped].state.value);
      if (shift && widget.selectionMode == TreeSelectionMode.multiple) _select(rows[clamped], extend: true);
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      moveTo(index + 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      moveTo(index < 0 ? 0 : index - 1);
    } else if (key == LogicalKeyboardKey.home) {
      moveTo(0);
    } else if (key == LogicalKeyboardKey.end) {
      moveTo(rows.length - 1);
    } else if (index < 0) {
      return KeyEventResult.ignored;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      final row = rows[index];
      if (row.state.isBranch && !row.state.expanded) {
        _toggle(row);
      } else if (row.state.expanded && index + 1 < rows.length) {
        moveTo(index + 1);
      }
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      final row = rows[index];
      if (row.state.expanded) {
        _toggle(row);
      } else if (row.parentValue != null) {
        _focusRow(row.parentValue!);
      }
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      _activate(rows[index], extend: HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed);
    } else if (event.character == '*') {
      final parent = rows[index].parentValue;
      final next = {..._effectiveExpanded};
      for (final row in rows) {
        if (row.parentValue == parent && row.state.isBranch && !row.state.disabled) next.add(row.state.value);
      }
      _setExpanded(next);
    } else if (event.character != null && event.character!.trim().isNotEmpty) {
      // Type-ahead: jump to the next visible row whose label starts with the character.
      final term = event.character!.toLowerCase();
      for (int offset = 1; offset <= rows.length; offset++) {
        final candidate = rows[(index + offset) % rows.length];
        if (widget.nodeToString(candidate.node).toLowerCase().startsWith(term)) {
          _focusRow(candidate.state.value);
          break;
        }
      }
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleRows();
    _rowKeys.removeWhere((value, _) => !rows.any((row) => row.state.value == value));

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKey,
        onFocusChange: (focused) {
          setState(() {
            _hasFocus = focused;
            if (focused && _focusedValue == null && rows.isNotEmpty) {
              final selected = _effectiveSelected;
              _focusedValue = rows.firstWhere((row) => selected.contains(row.state.value), orElse: () => rows.first).state.value;
            }
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final row in rows)
              _TreeRow<T>(
                key: _rowKeys.putIfAbsent(row.state.value, GlobalKey.new),
                row: row,
                tree: widget,
                showFocus: _hasFocus && row.state.focused,
                onToggle: () => _toggle(row),
                onActivate: () {
                  _focusNode.requestFocus();
                  setState(() => _focusedValue = row.state.value);
                  _activate(row, extend: HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TreeRow<T> extends StatefulWidget {
  final _Row<T> row;
  final TreeView<T> tree;
  final bool showFocus;
  final VoidCallback onToggle;
  final VoidCallback onActivate;

  const _TreeRow({super.key, required this.row, required this.tree, required this.showFocus, required this.onToggle, required this.onActivate});

  @override
  State<_TreeRow<T>> createState() => _TreeRowState<T>();
}

class _TreeRowState<T> extends State<_TreeRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final state = widget.row.state;
    final tree = widget.tree;
    final textColor = state.disabled ? c.textPlaceholder : c.textPrimary;

    final content =
        tree.nodeBuilder?.call(context, widget.row.node, state) ??
        Text(tree.nodeToString(widget.row.node), maxLines: 1, overflow: TextOverflow.ellipsis);

    return Semantics(
      selected: state.selected,
      expanded: state.isBranch ? state.expanded : null,
      enabled: !state.disabled,
      child: MouseRegion(
        cursor: state.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: state.disabled ? null : widget.onActivate,
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            decoration: BoxDecoration(
              color: state.selected ? c.surfaceHighlight : (_hovered && !state.disabled ? c.surfaceHover : null),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: widget.showFocus ? c.inputFocus : const Color(0x00000000), width: 2),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  for (int level = 1; level < state.depth; level++)
                    SizedBox(
                      width: tree.indent,
                      child: tree.showIndentGuides
                          ? Align(
                              alignment: Alignment.center,
                              child: Container(width: 1, color: c.borderSubtle),
                            )
                          : null,
                    ),
                  if (state.isBranch)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: state.disabled ? null : widget.onToggle,
                      child: Semantics(
                        button: true,
                        label: state.expanded ? 'Collapse' : 'Expand',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: AnimatedRotation(
                            turns: state.expanded ? 0.25 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: Icon(PrimeIcons.chevronRight, size: 18, color: state.disabled ? c.iconDisabled : c.iconSecondary),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 26),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                        child: IconTheme.merge(
                          data: IconThemeData(size: 18, color: state.disabled ? c.iconDisabled : c.iconSecondary),
                          child: DefaultTextStyle(
                            style: theme.textTheme.bodySmall.copyWith(
                              height: 1.3,
                              color: textColor,
                              fontWeight: state.selected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            child: content,
                          ),
                        ),
                      ),
                    ),
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
