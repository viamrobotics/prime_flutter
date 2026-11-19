import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'prime_icons.dart';

/// How a split arranges its two children. [row] places `first` to the left
/// of `second`; [column] places `first` above `second`.
enum SplitDirection { row, column }

/// The child slot of a split that a node occupies.
enum SplitKey { first, second }

/// A layout tree, or any subtree of one. Layout nodes are immutable: every
/// tree operation returns a new root.
sealed class LayoutNode<T> {
  /// Unique within the layout.
  final String id;

  const LayoutNode({required this.id});
}

/// A leaf of the layout. Its [data] belongs to you; [Panes] never reads it.
class PaneNode<T> extends LayoutNode<T> {
  final T data;

  const PaneNode({required super.id, required this.data});
}

/// Divides its area between two children along [direction].
class SplitNode<T> extends LayoutNode<T> {
  final SplitDirection direction;

  /// The share of the split given to [first], strictly between 0 and 1.
  final double ratio;
  final LayoutNode<T> first;
  final LayoutNode<T> second;

  const SplitNode({required super.id, required this.direction, this.ratio = 0.5, required this.first, required this.second});

  SplitNode<T> copyWith({SplitDirection? direction, double? ratio, LayoutNode<T>? first, LayoutNode<T>? second}) => SplitNode(
    id: id,
    direction: direction ?? this.direction,
    ratio: ratio ?? this.ratio,
    first: first ?? this.first,
    second: second ?? this.second,
  );
}

/// Several panes sharing one slot, one shown at a time behind tabs.
class StackNode<T> extends LayoutNode<T> {
  /// In tab order. Holds at least two panes.
  final List<PaneNode<T>> panes;

  /// The id of the shown pane. When it names none of [panes], the first shows.
  final String activeId;

  const StackNode({required super.id, required this.panes, required this.activeId});

  PaneNode<T> get activePane => panes.firstWhere((pane) => pane.id == activeId, orElse: () => panes.first);
}

/// A window's position and size in logical pixels, relative to the box of
/// the [FloatNode] that holds it.
@immutable
class FloatRect {
  final double x;
  final double y;
  final double width;
  final double height;

  const FloatRect({required this.x, required this.y, required this.width, required this.height});

  FloatRect copyWith({double? x, double? y, double? width, double? height}) =>
      FloatRect(x: x ?? this.x, y: y ?? this.y, width: width ?? this.width, height: height ?? this.height);

  @override
  bool operator ==(Object other) => other is FloatRect && other.x == x && other.y == y && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(x, y, width, height);
}

/// One window of a [FloatNode].
class FloatEntry<T> {
  /// Unique within the layout. Stays the same when [content] is replaced.
  final String id;
  final FloatRect rect;
  final LayoutNode<T> content;

  const FloatEntry({required this.id, required this.rect, required this.content});
}

/// Windows drawn over a base node, inside the float node's box. A float node
/// left with no windows is replaced by its [base].
class FloatNode<T> extends LayoutNode<T> {
  /// Fills the box behind the windows. Null once its last pane leaves.
  final LayoutNode<T>? base;

  /// In stacking order, the last on top.
  final List<FloatEntry<T>> floats;

  const FloatNode({required super.id, this.base, required this.floats});
}

/// The state of one pane, passed to [Panes.paneBuilder].
class PaneState {
  /// The pane shares its slot with other panes in a stack.
  final bool isStacked;

  /// The pane is the one shown in its slot. Always true outside a stack.
  final bool isActive;

  /// The pane is being moved in move mode (see [PaneMoveTrigger]).
  final bool isMoving;

  /// The pane is inside a floating window.
  final bool isFloating;

  /// The id of the float entry holding the pane, for [removeFloat] and
  /// [raiseFloat]. Null outside a float.
  final String? floatEntryId;

  const PaneState({required this.isStacked, required this.isActive, this.isMoving = false, this.isFloating = false, this.floatEntryId});
}

// --- Tree operations -------------------------------------------------------

/// Rebuilds [node] bottom-up. [visit] may replace a node or return null to
/// remove it; a split that loses a child collapses to the other, and a stack
/// left with one pane becomes that pane.
LayoutNode<T>? _rewrite<T>(LayoutNode<T> node, LayoutNode<T>? Function(LayoutNode<T> node) visit) {
  switch (node) {
    case PaneNode<T>():
      return visit(node);
    case SplitNode<T>():
      final first = _rewrite(node.first, visit);
      final second = _rewrite(node.second, visit);
      if (first == null) return second;
      if (second == null) return first;
      final rebuilt = identical(first, node.first) && identical(second, node.second) ? node : node.copyWith(first: first, second: second);
      return visit(rebuilt);
    case StackNode<T>():
      final panes = <PaneNode<T>>[];
      bool changed = false;
      for (final pane in node.panes) {
        final next = visit(pane);
        if (!identical(next, pane)) changed = true;
        if (next is PaneNode<T>) panes.add(next);
      }
      if (panes.isEmpty) return null;
      if (panes.length == 1) return panes.first;
      final rebuilt = changed ? StackNode<T>(id: node.id, panes: panes, activeId: node.activeId) : node;
      return visit(rebuilt);
    case FloatNode<T>():
      final base = node.base == null ? null : _rewrite(node.base!, visit);
      final floats = <FloatEntry<T>>[];
      bool changed = !identical(base, node.base);
      for (final entry in node.floats) {
        final content = _rewrite(entry.content, visit);
        if (!identical(content, entry.content)) changed = true;
        if (content != null) {
          floats.add(identical(content, entry.content) ? entry : FloatEntry<T>(id: entry.id, rect: entry.rect, content: content));
        }
      }
      if (floats.isEmpty) return base;
      return visit(changed ? FloatNode<T>(id: node.id, base: base, floats: floats) : node);
  }
}

/// Finds the node with [id] anywhere in [root].
LayoutNode<T>? findLayoutNode<T>(LayoutNode<T>? root, String id) {
  if (root == null) return null;
  if (root.id == id) return root;
  switch (root) {
    case PaneNode<T>():
      return null;
    case SplitNode<T>():
      return findLayoutNode(root.first, id) ?? findLayoutNode(root.second, id);
    case StackNode<T>():
      for (final pane in root.panes) {
        if (pane.id == id) return pane;
      }
      return null;
    case FloatNode<T>():
      final inBase = findLayoutNode(root.base, id);
      if (inBase != null) return inBase;
      for (final entry in root.floats) {
        final found = findLayoutNode(entry.content, id);
        if (found != null) return found;
      }
      return null;
  }
}

/// Every pane in [root], in reading order.
List<PaneNode<T>> listPanes<T>(LayoutNode<T>? root) {
  switch (root) {
    case null:
      return const [];
    case PaneNode<T>():
      return [root];
    case SplitNode<T>():
      return [...listPanes(root.first), ...listPanes(root.second)];
    case StackNode<T>():
      return root.panes;
    case FloatNode<T>():
      return [...listPanes(root.base), for (final entry in root.floats) ...listPanes(entry.content)];
  }
}

/// Sets the ratio of the split whose id is [splitId].
LayoutNode<T>? setSplitRatio<T>(LayoutNode<T>? root, String splitId, double ratio) {
  if (root == null) return null;
  return _rewrite(root, (node) => node is SplitNode<T> && node.id == splitId && node.ratio != ratio ? node.copyWith(ratio: ratio) : node);
}

/// Removes a pane. Its parent split collapses to the sibling, and a stack
/// left with one pane becomes that pane. Returns null when the last pane goes.
LayoutNode<T>? removePane<T>(LayoutNode<T>? root, String paneId) {
  if (root == null) return null;
  return _rewrite(root, (node) => node is PaneNode<T> && node.id == paneId ? null : node);
}

/// Replaces the data of one pane.
LayoutNode<T>? updatePaneData<T>(LayoutNode<T>? root, String paneId, T data) {
  if (root == null) return null;
  return _rewrite(root, (node) => node is PaneNode<T> && node.id == paneId ? PaneNode<T>(id: paneId, data: data) : node);
}

/// Exchanges the positions of two panes.
LayoutNode<T>? swapPanes<T>(LayoutNode<T>? root, String firstId, String secondId) {
  final first = findLayoutNode(root, firstId);
  final second = findLayoutNode(root, secondId);
  if (root == null || first is! PaneNode<T> || second is! PaneNode<T> || firstId == secondId) return root;
  return _rewrite(root, (node) {
    if (node is StackNode<T>) {
      // Keep the stack showing whichever pane now sits in the active tab.
      if (node.activeId == firstId && !node.panes.any((pane) => pane.id == firstId)) {
        return StackNode<T>(id: node.id, panes: node.panes, activeId: secondId);
      }
      if (node.activeId == secondId && !node.panes.any((pane) => pane.id == secondId)) {
        return StackNode<T>(id: node.id, panes: node.panes, activeId: firstId);
      }
      return node;
    }
    if (node is! PaneNode<T>) return node;
    if (node.id == firstId) return second;
    if (node.id == secondId) return first;
    return node;
  });
}

/// Shows [paneId] in its stack. No effect on a pane outside a stack.
LayoutNode<T>? selectPane<T>(LayoutNode<T>? root, String paneId) {
  if (root == null) return null;
  return _rewrite(root, (node) {
    if (node is StackNode<T> && node.activeId != paneId && node.panes.any((pane) => pane.id == paneId)) {
      return StackNode<T>(id: node.id, panes: node.panes, activeId: paneId);
    }
    return node;
  });
}

/// Moves a pane (or, when [targetId] names a stack, places it beside the
/// whole stack) into a new split next to [targetId]. [key] says which side of
/// the new split the moved pane takes.
LayoutNode<T>? movePane<T>(LayoutNode<T>? root, String paneId, String targetId, SplitDirection direction, SplitKey key, String newSplitId) {
  final pane = findLayoutNode(root, paneId);
  if (root == null || pane is! PaneNode<T> || paneId == targetId || findLayoutNode(root, targetId) == null) return root;
  final without = removePane(root, paneId);
  if (without == null) return root;

  // The target may have been a two-pane stack that just collapsed to its other pane.
  LayoutNode<T>? target = findLayoutNode(without, targetId);
  if (target == null) return root;
  if (target is PaneNode<T>) {
    // A pane inside a stack is not a slot of its own; split around the stack.
    target = _stackHolding(without, target.id) ?? target;
  }
  final slotId = target.id;
  return _rewrite(without, (node) {
    if (node.id != slotId || (node is PaneNode<T> && target is StackNode<T>)) return node;
    return SplitNode<T>(
      id: newSplitId,
      direction: direction,
      first: key == SplitKey.first ? pane : node,
      second: key == SplitKey.first ? node : pane,
    );
  });
}

StackNode<T>? _stackHolding<T>(LayoutNode<T> root, String paneId) {
  switch (root) {
    case PaneNode<T>():
      return null;
    case SplitNode<T>():
      return _stackHolding(root.first, paneId) ?? _stackHolding(root.second, paneId);
    case StackNode<T>():
      return root.panes.any((pane) => pane.id == paneId) ? root : null;
    case FloatNode<T>():
      final inBase = root.base == null ? null : _stackHolding(root.base!, paneId);
      if (inBase != null) return inBase;
      for (final entry in root.floats) {
        final found = _stackHolding(entry.content, paneId);
        if (found != null) return found;
      }
      return null;
  }
}

/// Finds the float entry with [entryId], and the float node that holds it.
({FloatNode<T> node, FloatEntry<T> entry})? _findFloat<T>(LayoutNode<T>? root, String entryId) {
  switch (root) {
    case null || PaneNode<T>() || StackNode<T>():
      return null;
    case SplitNode<T>():
      return _findFloat(root.first, entryId) ?? _findFloat(root.second, entryId);
    case FloatNode<T>():
      for (final entry in root.floats) {
        if (entry.id == entryId) return (node: root, entry: entry);
      }
      final inBase = _findFloat(root.base, entryId);
      if (inBase != null) return inBase;
      for (final entry in root.floats) {
        final found = _findFloat(entry.content, entryId);
        if (found != null) return found;
      }
      return null;
  }
}

/// The id of the float entry holding the node with [id], or null outside a float.
String? floatEntryOf<T>(LayoutNode<T>? root, String id) {
  switch (root) {
    case null || PaneNode<T>() || StackNode<T>():
      return null;
    case SplitNode<T>():
      return floatEntryOf(root.first, id) ?? floatEntryOf(root.second, id);
    case FloatNode<T>():
      for (final entry in root.floats) {
        if (findLayoutNode(entry.content, id) != null) return floatEntryOf(entry.content, id) ?? entry.id;
      }
      return floatEntryOf(root.base, id);
  }
}

LayoutNode<T>? _replaceFloatNode<T>(LayoutNode<T> root, String floatId, LayoutNode<T>? Function(FloatNode<T> node) update) {
  return _rewrite(root, (node) => node is FloatNode<T> && node.id == floatId ? update(node) : node);
}

LayoutNode<T>? _floatNode<T>(LayoutNode<T>? root, String id, FloatRect rect, String newEntryId, String newFloatId, String? hostId) {
  final moving = findLayoutNode(root, id);
  if (root == null || moving == null || moving is SplitNode<T> || moving is FloatNode<T>) return root;
  // Lift the node out, then hang it from the host as a window.
  final without = _rewrite(root, (node) => node.id == id ? null : node);
  final entry = FloatEntry<T>(id: newEntryId, rect: rect, content: moving);
  if (without == null) return FloatNode<T>(id: newFloatId, floats: [entry]);
  final host = (hostId == null ? null : findLayoutNode(without, hostId)) ?? without;
  final hostNodeId = host.id;
  bool placed = false;
  return _rewrite(without, (node) {
    if (placed || node.id != hostNodeId) return node;
    placed = true;
    if (node is FloatNode<T>) return FloatNode<T>(id: node.id, base: node.base, floats: [...node.floats, entry]);
    return FloatNode<T>(id: newFloatId, base: node, floats: [entry]);
  });
}

/// Lifts a pane out of the layout into a floating window at [rect].
///
/// The window hangs from the node with [hostId], or from the root. When the
/// host is already a [FloatNode] the window joins it; otherwise the host is
/// wrapped in a new float node with id [newFloatId].
LayoutNode<T>? floatPane<T>(LayoutNode<T>? root, String paneId, FloatRect rect, String newEntryId, String newFloatId, [String? hostId]) {
  if (findLayoutNode(root, paneId) is! PaneNode<T>) return root;
  return _floatNode(root, paneId, rect, newEntryId, newFloatId, hostId);
}

/// Lifts a whole stack into a floating window. See [floatPane].
LayoutNode<T>? floatStack<T>(LayoutNode<T>? root, String stackId, FloatRect rect, String newEntryId, String newFloatId, [String? hostId]) {
  if (findLayoutNode(root, stackId) is! StackNode<T>) return root;
  return _floatNode(root, stackId, rect, newEntryId, newFloatId, hostId);
}

/// Moves or resizes the window with [entryId].
LayoutNode<T>? setFloatRect<T>(LayoutNode<T>? root, String entryId, FloatRect rect) {
  final found = _findFloat(root, entryId);
  if (root == null || found == null || found.entry.rect == rect) return root;
  return _replaceFloatNode(
    root,
    found.node.id,
    (node) => FloatNode<T>(
      id: node.id,
      base: node.base,
      floats: [
        for (final entry in node.floats) entry.id == entryId ? FloatEntry<T>(id: entry.id, rect: rect, content: entry.content) : entry,
      ],
    ),
  );
}

/// Brings the window with [entryId] to the top of its float node.
LayoutNode<T>? raiseFloat<T>(LayoutNode<T>? root, String entryId) {
  final found = _findFloat(root, entryId);
  if (root == null || found == null || found.node.floats.last.id == entryId) return root;
  return _replaceFloatNode(
    root,
    found.node.id,
    (node) => FloatNode<T>(id: node.id, base: node.base, floats: [...node.floats.where((entry) => entry.id != entryId), found.entry]),
  );
}

/// Closes the window with [entryId], discarding the panes inside it. A float
/// node left with no windows is replaced by its base.
LayoutNode<T>? removeFloat<T>(LayoutNode<T>? root, String entryId) {
  final found = _findFloat(root, entryId);
  if (root == null || found == null) return root;
  return _replaceFloatNode(root, found.node.id, (node) {
    final floats = [...node.floats.where((entry) => entry.id != entryId)];
    return floats.isEmpty ? node.base : FloatNode<T>(id: node.id, base: node.base, floats: floats);
  });
}

/// Moves a whole stack into a new split next to the slot holding
/// [targetPaneId]. [key] says which side of the new split the stack takes.
LayoutNode<T>? moveStack<T>(
  LayoutNode<T>? root,
  String stackId,
  String targetPaneId,
  SplitDirection direction,
  SplitKey key,
  String newSplitId,
) {
  final stack = findLayoutNode(root, stackId);
  if (root == null || stack is! StackNode<T> || stack.panes.any((pane) => pane.id == targetPaneId)) return root;
  if (findLayoutNode(root, targetPaneId) is! PaneNode<T>) return root;
  final without = _rewrite(root, (node) => node.id == stackId ? null : node);
  if (without == null) return root;
  // A target inside another stack is not a slot of its own; split around that stack.
  final slotId = (_stackHolding(without, targetPaneId) ?? findLayoutNode(without, targetPaneId))?.id;
  if (slotId == null) return root;
  bool placed = false;
  return _rewrite(without, (node) {
    if (placed || node.id != slotId) return node;
    placed = true;
    return SplitNode<T>(
      id: newSplitId,
      direction: direction,
      first: key == SplitKey.first ? stack : node,
      second: key == SplitKey.first ? node : stack,
    );
  });
}

/// Exchanges two whole slots, each a pane or a stack with everything in it.
/// A slot is named by its own id or by the id of a pane inside it.
LayoutNode<T>? swapSlots<T>(LayoutNode<T>? root, String firstId, String secondId) {
  if (root == null) return null;
  LayoutNode<T>? slotOf(String id) {
    final node = findLayoutNode(root, id);
    if (node is PaneNode<T>) return _stackHolding(root, id) ?? node;
    return node is StackNode<T> ? node : null;
  }

  final first = slotOf(firstId), second = slotOf(secondId);
  if (first == null || second == null || first.id == second.id) return root;
  return _rewrite(root, (node) {
    if (identical(node, first)) return second;
    if (identical(node, second)) return first;
    return node;
  });
}

/// Stacks pane [sourceId] behind tabs with [targetPaneId], creating a stack
/// with id [newStackId] when the target is not in one yet. The moved pane
/// becomes the active tab, inserted at [index] or the end.
LayoutNode<T>? stackPanes<T>(LayoutNode<T>? root, String targetPaneId, String sourceId, String newStackId, [int? index]) {
  final source = findLayoutNode(root, sourceId);
  if (root == null || source is! PaneNode<T> || sourceId == targetPaneId || findLayoutNode(root, targetPaneId) is! PaneNode<T>) return root;
  final without = removePane(root, sourceId);
  if (without == null) return root;

  final existing = _stackHolding(without, targetPaneId);
  if (existing != null) {
    final panes = [...existing.panes];
    panes.insert((index ?? panes.length).clamp(0, panes.length), source);
    return _rewrite(
      without,
      (node) => node.id == existing.id && node is StackNode<T> ? StackNode<T>(id: node.id, panes: panes, activeId: sourceId) : node,
    );
  }
  return _rewrite(without, (node) {
    if (node is! PaneNode<T> || node.id != targetPaneId) return node;
    final panes = <PaneNode<T>>[node];
    panes.insert((index ?? 1).clamp(0, 1), source);
    return StackNode<T>(id: newStackId, panes: panes, activeId: sourceId);
  });
}

/// Moves a stacked pane to [index] within its stack's tab order.
LayoutNode<T>? reorderPane<T>(LayoutNode<T>? root, String paneId, int index) {
  if (root == null) return null;
  return _rewrite(root, (node) {
    if (node is! StackNode<T>) return node;
    final from = node.panes.indexWhere((pane) => pane.id == paneId);
    if (from < 0) return node;
    final panes = [...node.panes];
    final pane = panes.removeAt(from);
    panes.insert(index.clamp(0, panes.length), pane);
    return StackNode<T>(id: node.id, panes: panes, activeId: node.activeId);
  });
}

/// Adds [pane] beside the upper-right slot of the layout, in a new row split.
/// With no layout yet, the pane becomes the root.
LayoutNode<T> addPaneToUpperRight<T>(LayoutNode<T>? root, PaneNode<T> pane, String newSplitId) {
  if (root == null) return pane;
  LayoutNode<T> slot = root;
  while (true) {
    if (slot is SplitNode<T>) {
      slot = slot.direction == SplitDirection.row ? slot.second : slot.first;
    } else if (slot is FloatNode<T> && slot.base != null) {
      slot = slot.base!;
    } else {
      break;
    }
  }
  final slotId = slot.id;
  return _rewrite(root, (node) {
        if (node.id != slotId) return node;
        return SplitNode<T>(id: newSplitId, direction: SplitDirection.row, first: node, second: pane);
      }) ??
      pane;
}

// --- Widgets ---------------------------------------------------------------

/// Two children separated by a draggable divider.
///
/// This is the primitive behind [Panes]; use it directly for a fixed
/// two-pane layout.
///
/// ```dart
/// SplitPane(
///   direction: SplitDirection.row,
///   ratio: ratio,
///   onRatioChanged: (next) => setState(() => ratio = next),
///   first: const FileTree(),
///   second: const Editor(),
/// )
/// ```
class SplitPane extends StatefulWidget {
  final SplitDirection direction;

  /// The share of the space given to [first], between 0 and 1.
  final double ratio;

  /// Called when a drag ends with the new ratio. When null the divider is
  /// fixed.
  final ValueChanged<double>? onRatioChanged;

  final Widget first;
  final Widget second;

  /// Neither child can be dragged smaller than this.
  final double minSize;

  const SplitPane({
    super.key,
    this.direction = SplitDirection.row,
    this.ratio = 0.5,
    this.onRatioChanged,
    required this.first,
    required this.second,
    this.minSize = 40,
  });

  @override
  State<SplitPane> createState() => _SplitPaneState();
}

class _SplitPaneState extends State<SplitPane> {
  /// The ratio while a drag is in flight; null otherwise.
  double? _dragRatio;
  bool _hovered = false;

  static const double _hitSize = 12;

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    final isRow = widget.direction == SplitDirection.row;
    final resizable = widget.onRatioChanged != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = isRow ? constraints.maxWidth : constraints.maxHeight;
        final min = total > widget.minSize * 2 ? widget.minSize / total : 0.5;
        final ratio = (_dragRatio ?? widget.ratio).clamp(min, 1 - min).toDouble();
        final firstSize = total * ratio;
        final active = _hovered || _dragRatio != null;

        void handleUpdate(DragUpdateDetails details) {
          final delta = isRow ? details.delta.dx : details.delta.dy;
          setState(() => _dragRatio = (ratio + delta / total).clamp(min, 1 - min).toDouble());
        }

        void handleEnd([DragEndDetails? details]) {
          final next = _dragRatio;
          setState(() => _dragRatio = null);
          if (next != null && (next - widget.ratio).abs() > 0.0001) widget.onRatioChanged?.call(next);
        }

        final divider = MouseRegion(
          cursor: !resizable ? MouseCursor.defer : (isRow ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow),
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: Semantics(
            label: 'Resize panes',
            slider: true,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: resizable && isRow ? handleUpdate : null,
              onHorizontalDragEnd: resizable && isRow ? handleEnd : null,
              onHorizontalDragCancel: resizable && isRow ? handleEnd : null,
              onVerticalDragUpdate: resizable && !isRow ? handleUpdate : null,
              onVerticalDragEnd: resizable && !isRow ? handleEnd : null,
              onVerticalDragCancel: resizable && !isRow ? handleEnd : null,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: isRow ? (active && resizable ? 2 : 1) : double.infinity,
                  height: isRow ? double.infinity : (active && resizable ? 2 : 1),
                  color: active && resizable ? c.iconSecondary : c.borderSubtle,
                ),
              ),
            ),
          ),
        );

        return Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: isRow ? firstSize : constraints.maxWidth,
              height: isRow ? constraints.maxHeight : firstSize,
              child: widget.first,
            ),
            Positioned(left: isRow ? firstSize : 0, top: isRow ? 0 : firstSize, right: 0, bottom: 0, child: widget.second),
            Positioned(
              left: isRow ? firstSize - _hitSize / 2 : 0,
              top: isRow ? 0 : firstSize - _hitSize / 2,
              width: isRow ? _hitSize : constraints.maxWidth,
              height: isRow ? constraints.maxHeight : _hitSize,
              child: divider,
            ),
          ],
        );
      },
    );
  }
}

/// What dropping a dragged pane on the middle of another pane does.
enum PaneCenterDrop {
  /// The two panes trade places.
  swap,

  /// The dragged pane joins the target behind tabs.
  stack,
}

enum _DropRegion { left, right, top, bottom, center, tabs }

class _PanesScope extends InheritedWidget {
  final _PanesState<dynamic> state;
  final String? paneId;

  const _PanesScope({required this.state, this.paneId, required super.child});

  @override
  bool updateShouldNotify(_PanesScope oldWidget) => paneId != oldWidget.paneId;
}

/// Makes its child a handle that drags the enclosing pane to a new place.
///
/// Put it around a pane's header inside [Panes.paneBuilder]. While dragging,
/// the pane under the pointer highlights where a drop would land: an edge
/// splits that pane, the middle swaps (or stacks, see [Panes.centerDrop]),
/// and a tab strip adds the pane to that stack.
///
/// ```dart
/// paneBuilder: (context, pane, state) => Column(
///   children: [
///     PaneDragTrigger(child: Header(title: pane.data.title)),
///     Expanded(child: Body(pane)),
///   ],
/// )
/// ```
class PaneDragTrigger extends StatelessWidget {
  final Widget child;

  const PaneDragTrigger({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_PanesScope>();
    final paneId = scope?.paneId;
    if (scope == null || paneId == null || !scope.state.canReorder) return child;
    return _DragHandle(state: scope.state, paneId: paneId, child: child);
  }
}

class _DragHandle extends StatelessWidget {
  final _PanesState<dynamic> state;
  final String paneId;
  final Widget child;

  const _DragHandle({required this.state, required this.paneId, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) => state.startDrag(paneId, details.globalPosition),
        onPanUpdate: (details) => state.updateDrag(details.globalPosition),
        onPanEnd: (_) => state.endDrag(),
        onPanCancel: state.cancelDrag,
        child: child,
      ),
    );
  }
}

/// A button that toggles move mode for the enclosing pane, which rearranges
/// panes without dragging.
///
/// In move mode the arrow keys walk across the other panes and their left,
/// middle, right, top and bottom regions, Tab steps through every
/// destination, Enter or Space places the pane, and Escape cancels. A tap on
/// a destination places it too. Give every pane with a [PaneDragTrigger] one
/// of these, so rearranging never depends on a drag.
///
/// ```dart
/// PaneMoveTrigger(child: const Icon(PrimeIcons.cursorMove))
/// ```
class PaneMoveTrigger extends StatelessWidget {
  final Widget child;

  /// Accessible name of the button.
  final String label;

  const PaneMoveTrigger({super.key, required this.child, this.label = 'Move pane'});

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_PanesScope>();
    final paneId = scope?.paneId;
    if (scope == null || paneId == null || !scope.state.canReorder) return child;
    return Semantics(
      button: true,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => scope.state.toggleMove(paneId), child: child),
      ),
    );
  }
}

/// A resizable, rearrangeable split-pane layout driven by a binary
/// [LayoutNode] tree.
///
/// You own the tree: [Panes] reports each change through [onLayoutChanged]
/// and you feed the new root back in. Users resize by dragging dividers, and
/// panes that share a slot in a [StackNode] sit behind tabs. They rearrange
/// by dragging a tab or a [PaneDragTrigger] onto another pane, or from the
/// keyboard with a [PaneMoveTrigger]. A [FloatNode] draws panes in movable,
/// resizable windows over the rest of the layout. From code, use
/// the tree operations ([movePane], [swapPanes], [stackPanes], [removePane],
/// [addPaneToUpperRight], ...).
///
/// ```dart
/// Panes<String>(
///   layout: layout,
///   onLayoutChanged: (next) => setState(() => layout = next),
///   paneLabel: (pane) => pane.data,
///   paneBuilder: (context, pane, state) => Center(child: Text(pane.data)),
/// )
/// ```
///
/// The widget fills its parent, so give it a bounded size.
class Panes<T> extends StatefulWidget {
  /// The root of the layout. Null renders [emptyBuilder].
  final LayoutNode<T>? layout;

  /// Called with a new root after a resize, a tab selection, or a drop.
  final ValueChanged<LayoutNode<T>?>? onLayoutChanged;

  /// Builds the content of one pane.
  final Widget Function(BuildContext context, PaneNode<T> pane, PaneState state) paneBuilder;

  /// Names a pane on its tab and on the drag ghost. Defaults to the pane id.
  final String Function(PaneNode<T> pane)? paneLabel;

  /// Builds a custom tab for a stacked pane.
  final Widget Function(BuildContext context, PaneNode<T> pane, bool isActive)? tabBuilder;

  /// Whether dividers can be dragged.
  final bool resizable;

  /// Whether tabs and [PaneDragTrigger]s can drag panes to new places.
  final bool reorderable;

  /// What a drop on the middle of a pane does.
  final PaneCenterDrop centerDrop;

  /// Keeps the inactive panes of a stack mounted so they retain state.
  final bool keepInactiveMounted;

  /// The smallest size a pane can be dragged to.
  final double minPaneSize;

  /// Shown when [layout] is null.
  final WidgetBuilder? emptyBuilder;

  /// Makes the id for a split or stack created by a drop. Defaults to a
  /// timestamp-based id.
  final String Function(String kind)? idGenerator;

  /// Builds your own chrome for a floating window in place of the default
  /// title bar, close button, and resize grip. Wrap the parts that should
  /// move or resize the window with [FloatWindowControls.dragHandle] and
  /// [FloatWindowControls.resizeHandle], and place `content` inside.
  ///
  /// ```dart
  /// floatBuilder: (context, entry, controls, content) => Column(
  ///   children: [
  ///     controls.dragHandle(child: MyTitleBar(onClose: controls.close)),
  ///     Expanded(child: content),
  ///   ],
  /// )
  /// ```
  final Widget Function(BuildContext context, FloatEntry<T> entry, FloatWindowControls controls, Widget content)? floatBuilder;

  const Panes({
    super.key,
    required this.layout,
    required this.paneBuilder,
    this.onLayoutChanged,
    this.paneLabel,
    this.tabBuilder,
    this.resizable = true,
    this.reorderable = true,
    this.centerDrop = PaneCenterDrop.swap,
    this.keepInactiveMounted = false,
    this.minPaneSize = 40,
    this.emptyBuilder,
    this.idGenerator,
    this.floatBuilder,
  });

  @override
  State<Panes<T>> createState() => _PanesState<T>();
}

class _PanesState<T> extends State<Panes<T>> {
  /// One key per slot (a pane, or a whole stack), for hit-testing drops.
  final Map<String, GlobalKey> _slotKeys = {};

  /// Stacking depth of each slot: 0 in the base layout, higher inside floats.
  Map<String, int> _slotDepth = {};

  /// The box of each float node, so its windows can be kept inside it.
  final Map<String, GlobalKey> _floatKeys = {};
  final Map<String, Size> _floatSizes = {};

  /// Reads each float node's size after layout and rebuilds when one changed.
  void _measureFloats() {
    bool changed = false;
    _floatKeys.removeWhere((id, key) => key.currentContext == null);
    _floatSizes.removeWhere((id, _) => !_floatKeys.containsKey(id));
    for (final entry in _floatKeys.entries) {
      final size = entry.value.currentContext?.size;
      if (size != null && _floatSizes[entry.key] != size) {
        _floatSizes[entry.key] = size;
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }

  final GlobalKey _rootKey = GlobalKey();
  final FocusNode _moveFocus = FocusNode(debugLabel: 'Panes move mode');

  /// The pane being placed in move mode.
  String? _movingId;
  int _idCounter = 0;

  String? _dragId;
  Offset? _dragPosition;
  String? _targetSlotId;
  _DropRegion? _targetRegion;

  static const double _tabStripHeight = 36;

  bool get canReorder => widget.reorderable && widget.onLayoutChanged != null;

  String _newId(String kind) => widget.idGenerator?.call(kind) ?? '$kind-${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}';

  void startDrag(String paneId, Offset position) {
    if (!canReorder) return;
    setState(() {
      _dragId = paneId;
      _dragPosition = position;
      _targetSlotId = null;
      _targetRegion = null;
    });
  }

  /// The slot under [position] and the drop region within it, for [sourceId].
  ({String slotId, _DropRegion region})? _hit(Offset position, String sourceId) {
    String? bestId;
    RenderBox? bestBox;
    int bestDepth = -1;
    for (final entry in _slotKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final local = box.globalToLocal(position);
      if (local.dx < 0 || local.dy < 0 || local.dx > box.size.width || local.dy > box.size.height) continue;
      // A floating window covers whatever sits under it.
      final depth = _slotDepth[entry.key] ?? 0;
      if (depth > bestDepth) {
        bestId = entry.key;
        bestBox = box;
        bestDepth = depth;
      }
    }
    if (bestId == null || bestBox == null) return null;
    final local = bestBox.globalToLocal(position);
    final fx = local.dx / bestBox.size.width, fy = local.dy / bestBox.size.height;
    final isStack = findLayoutNode(widget.layout, bestId) is StackNode<T>;
    final _DropRegion region;
    if (isStack && local.dy <= _tabStripHeight) {
      region = _DropRegion.tabs;
    } else if (fx > 0.25 && fx < 0.75 && fy > 0.25 && fy < 0.75) {
      region = _DropRegion.center;
    } else {
      final distances = {_DropRegion.left: fx, _DropRegion.right: 1 - fx, _DropRegion.top: fy, _DropRegion.bottom: 1 - fy};
      region = distances.entries.reduce((a, b) => a.value <= b.value ? a : b).key;
    }
    return _isValid(sourceId, bestId, region) ? (slotId: bestId, region: region) : null;
  }

  /// Whether placing [sourceId] at [region] of [slotId] would change anything.
  bool _isValid(String sourceId, String slotId, _DropRegion region) {
    // A pane cannot be dropped on its own slot.
    if (slotId == sourceId) return false;
    final node = findLayoutNode(widget.layout, slotId);
    if (node == null) return false;
    if (region == _DropRegion.tabs && node is! StackNode<T>) return false;
    // A stacked pane can leave by an edge of its own stack, but not join it again.
    if (node is StackNode<T> && node.panes.any((pane) => pane.id == sourceId)) {
      return region != _DropRegion.center && region != _DropRegion.tabs;
    }
    return true;
  }

  void updateDrag(Offset position) {
    final dragId = _dragId;
    if (dragId == null) return;
    final hit = _hit(position, dragId);
    setState(() {
      _dragPosition = position;
      _targetSlotId = hit?.slotId;
      _targetRegion = hit?.region;
    });
  }

  void cancelDrag() {
    if (_dragId == null) return;
    setState(() {
      _dragId = null;
      _dragPosition = null;
      _targetSlotId = null;
      _targetRegion = null;
    });
  }

  void endDrag() {
    final sourceId = _dragId, slotId = _targetSlotId, region = _targetRegion;
    cancelDrag();
    if (sourceId == null || slotId == null || region == null) return;
    _place(sourceId, slotId, region);
  }

  // --- Move mode ---

  void toggleMove(String paneId) {
    if (_movingId == paneId) {
      cancelMove();
      return;
    }
    if (!canReorder) return;
    final first = _destinations(paneId).firstOrNull;
    setState(() {
      _movingId = paneId;
      _targetSlotId = first?.slotId;
      _targetRegion = first?.region;
    });
    _moveFocus.requestFocus();
  }

  void cancelMove() {
    if (_movingId == null) return;
    setState(() {
      _movingId = null;
      _targetSlotId = null;
      _targetRegion = null;
    });
  }

  Rect? _slotRect(String slotId) {
    final box = _slotKeys[slotId]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Every place the moving pane could go, slot by slot.
  List<({String slotId, _DropRegion region})> _destinations(String sourceId) => [
    for (final slotId in _slotKeys.keys)
      for (final region in const [
        _DropRegion.tabs,
        _DropRegion.left,
        _DropRegion.top,
        _DropRegion.center,
        _DropRegion.bottom,
        _DropRegion.right,
      ])
        if (_isValid(sourceId, slotId, region)) (slotId: slotId, region: region),
  ];

  /// The nearest other slot in [direction] from [fromId].
  String? _neighbor(String sourceId, String fromId, AxisDirection direction) {
    final from = _slotRect(fromId);
    if (from == null) return null;
    String? best;
    double bestScore = double.infinity;
    for (final slotId in _slotKeys.keys) {
      if (slotId == fromId || slotId == sourceId) continue;
      final rect = _slotRect(slotId);
      if (rect == null) continue;
      final delta = rect.center - from.center;
      final (double along, double across) = switch (direction) {
        AxisDirection.right => (delta.dx, delta.dy),
        AxisDirection.left => (-delta.dx, delta.dy),
        AxisDirection.down => (delta.dy, delta.dx),
        AxisDirection.up => (-delta.dy, delta.dx),
      };
      if (along <= 1) continue;
      final score = along + across.abs() * 2;
      if (score < bestScore) {
        bestScore = score;
        best = slotId;
      }
    }
    return best;
  }

  void _moveTarget(AxisDirection direction) {
    final sourceId = _movingId, slotId = _targetSlotId, region = _targetRegion;
    if (sourceId == null) return;
    if (slotId == null || region == null) {
      final first = _destinations(sourceId).firstOrNull;
      setState(() {
        _targetSlotId = first?.slotId;
        _targetRegion = first?.region;
      });
      return;
    }
    // Within a pane the regions run near edge, middle, far edge; past the far edge is the next pane.
    final (near, far) = switch (direction) {
      AxisDirection.right => (_DropRegion.left, _DropRegion.right),
      AxisDirection.left => (_DropRegion.right, _DropRegion.left),
      AxisDirection.down => (_DropRegion.top, _DropRegion.bottom),
      AxisDirection.up => (_DropRegion.bottom, _DropRegion.top),
    };
    final candidates = <({String slotId, _DropRegion region})>[
      if (region == near) (slotId: slotId, region: _DropRegion.center),
      if (region != far) (slotId: slotId, region: far),
    ];
    final next = _neighbor(sourceId, slotId, direction);
    if (next != null) {
      candidates.addAll([(slotId: next, region: near), (slotId: next, region: _DropRegion.center), (slotId: next, region: far)]);
    }
    for (final candidate in candidates) {
      if (_isValid(sourceId, candidate.slotId, candidate.region)) {
        setState(() {
          _targetSlotId = candidate.slotId;
          _targetRegion = candidate.region;
        });
        return;
      }
    }
  }

  KeyEventResult _handleMoveKey(FocusNode node, KeyEvent event) {
    final sourceId = _movingId;
    if (sourceId == null || event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      cancelMove();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _moveTarget(AxisDirection.right);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _moveTarget(AxisDirection.left);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _moveTarget(AxisDirection.down);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveTarget(AxisDirection.up);
    } else if (key == LogicalKeyboardKey.tab) {
      final all = _destinations(sourceId);
      if (all.isNotEmpty) {
        final current = all.indexWhere((item) => item.slotId == _targetSlotId && item.region == _targetRegion);
        final step = HardwareKeyboard.instance.isShiftPressed ? -1 : 1;
        final next = all[(current + step) % all.length];
        setState(() {
          _targetSlotId = next.slotId;
          _targetRegion = next.region;
        });
      }
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter || key == LogicalKeyboardKey.space) {
      final slotId = _targetSlotId, region = _targetRegion;
      cancelMove();
      if (slotId != null && region != null) _place(sourceId, slotId, region);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  static String _regionWording(_DropRegion region) => switch (region) {
    _DropRegion.left => 'Left of',
    _DropRegion.right => 'Right of',
    _DropRegion.top => 'Above',
    _DropRegion.bottom => 'Below',
    _DropRegion.center => 'In place of',
    _DropRegion.tabs => 'Stack with',
  };

  String _labelFor(String id) {
    final node = findLayoutNode(widget.layout, id);
    final pane = node is StackNode<T> ? node.activePane : (node is PaneNode<T> ? node : null);
    return pane == null ? id : (widget.paneLabel?.call(pane) ?? pane.id);
  }

  @override
  void dispose() {
    _moveFocus.dispose();
    super.dispose();
  }

  /// Applies a drop or a move-mode placement.
  void _place(String sourceId, String slotId, _DropRegion region) {
    final root = widget.layout;
    final slot = findLayoutNode(root, slotId);
    if (slot == null) return;
    // Tree operations address panes, so a stack is reached through one of its panes.
    final targetPaneId = slot is StackNode<T>
        ? slot.panes.firstWhere((pane) => pane.id != sourceId, orElse: () => slot.activePane).id
        : slotId;
    final stackIt =
        region == _DropRegion.tabs || (region == _DropRegion.center && (slot is StackNode<T> || widget.centerDrop == PaneCenterDrop.stack));

    final LayoutNode<T>? next;
    if (stackIt) {
      next = stackPanes(root, targetPaneId, sourceId, _newId('stack'));
    } else if (region == _DropRegion.center) {
      next = swapPanes(root, sourceId, targetPaneId);
    } else {
      final isRow = region == _DropRegion.left || region == _DropRegion.right;
      final isFirst = region == _DropRegion.left || region == _DropRegion.top;
      next = movePane(
        root,
        sourceId,
        // movePane splits around the whole stack when the target sits in one.
        targetPaneId,
        isRow ? SplitDirection.row : SplitDirection.column,
        isFirst ? SplitKey.first : SplitKey.second,
        _newId('split'),
      );
    }
    if (!identical(next, root)) widget.onLayoutChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final root = widget.layout;
    if (root == null) return widget.emptyBuilder?.call(context) ?? const SizedBox.expand();

    final liveSlots = <String, int>{};
    final tree = _buildNode(context, root, liveSlots);
    _slotKeys.removeWhere((id, _) => !liveSlots.containsKey(id));
    _slotDepth = liveSlots;
    final movingId = _movingId;
    final moveHint = movingId == null
        ? null
        : (_targetSlotId == null || _targetRegion == null
              ? 'Moving ${_labelFor(movingId)}. No other pane to move to. Escape to cancel.'
              : '${_regionWording(_targetRegion!)} ${_labelFor(_targetSlotId!)}. Enter to place ${_labelFor(movingId)}, Escape to cancel.');

    final dragId = _dragId, dragPosition = _dragPosition;
    final dragged = dragId == null ? null : findLayoutNode(root, dragId);
    Offset? ghostOffset;
    if (dragPosition != null) {
      final box = _rootKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) ghostOffset = box.globalToLocal(dragPosition);
    }
    final theme = PrimeTheme.of(context);

    return _PanesScope(
      state: this,
      child: Stack(
        key: _rootKey,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Focus(
              focusNode: _moveFocus,
              onKeyEvent: _handleMoveKey,
              // Moving focus out of the view cancels the move.
              onFocusChange: (focused) {
                if (!focused) cancelMove();
              },
              child: tree,
            ),
          ),
          if (moveHint != null)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: IgnorePointer(
                child: Center(
                  child: Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: theme.colorScheme.statusInfoLight, borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        moveHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, color: theme.colorScheme.statusInfoDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (dragged is PaneNode<T> && ghostOffset != null)
            Positioned(
              left: ghostOffset.dx + 12,
              top: ghostOffset.dy + 12,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.statusInfoLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: theme.colorScheme.statusInfoDark),
                  ),
                  child: Text(
                    widget.paneLabel?.call(dragged) ?? dragged.id,
                    style: theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, color: theme.colorScheme.statusInfoDark),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Wraps a slot so drops can find it, and paints the drop preview over it.
  Widget _slot(BuildContext context, String id, Widget child, Map<String, int> liveSlots, int depth) {
    liveSlots[id] = depth;
    final region = _targetSlotId == id ? _targetRegion : null;
    final c = PrimeTheme.of(context).colorScheme;
    final movingId = _movingId;
    return Stack(
      key: _slotKeys.putIfAbsent(id, GlobalKey.new),
      fit: StackFit.expand,
      children: [
        child,
        // In move mode a tap on another pane places the moving one there.
        if (movingId != null && id != movingId)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final hit = _hit(details.globalPosition, movingId);
                cancelMove();
                if (hit != null) _place(movingId, hit.slotId, hit.region);
              },
            ),
          ),
        if (region != null)
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: switch (region) {
                  _DropRegion.left => Alignment.centerLeft,
                  _DropRegion.right => Alignment.centerRight,
                  _DropRegion.top || _DropRegion.tabs => Alignment.topCenter,
                  _DropRegion.bottom => Alignment.bottomCenter,
                  _DropRegion.center => Alignment.center,
                },
                child: FractionallySizedBox(
                  widthFactor: region == _DropRegion.left || region == _DropRegion.right ? 0.5 : 1,
                  heightFactor: region == _DropRegion.top || region == _DropRegion.bottom ? 0.5 : (region == _DropRegion.tabs ? null : 1),
                  child: Container(
                    height: region == _DropRegion.tabs ? _tabStripHeight : null,
                    decoration: BoxDecoration(
                      color: c.statusInfoDark.withValues(alpha: 0.14),
                      border: Border.all(color: c.statusInfoDark, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPane(BuildContext context, PaneNode<T> pane, {required bool isStacked, required bool isActive, String? floatEntryId}) {
    final isMoving = _movingId == pane.id;
    final state = PaneState(
      isStacked: isStacked,
      isActive: isActive,
      isMoving: isMoving,
      isFloating: floatEntryId != null,
      floatEntryId: floatEntryId,
    );
    return _PanesScope(
      state: this,
      paneId: pane.id,
      child: Opacity(
        key: ValueKey('pane-${pane.id}'),
        opacity: _dragId == pane.id || isMoving ? 0.5 : 1,
        child: widget.paneBuilder(context, pane, state),
      ),
    );
  }

  Widget _buildNode(BuildContext context, LayoutNode<T> node, Map<String, int> liveSlots, {String? floatEntryId, int depth = 0}) {
    final onLayoutChanged = widget.onLayoutChanged;
    switch (node) {
      case PaneNode<T>():
        return _slot(
          context,
          node.id,
          _buildPane(context, node, isStacked: false, isActive: true, floatEntryId: floatEntryId),
          liveSlots,
          depth,
        );
      case SplitNode<T>():
        return SplitPane(
          key: ValueKey('split-${node.id}'),
          direction: node.direction,
          ratio: node.ratio,
          minSize: widget.minPaneSize,
          onRatioChanged: widget.resizable && onLayoutChanged != null
              ? (ratio) => onLayoutChanged(setSplitRatio(widget.layout, node.id, ratio))
              : null,
          first: _buildNode(context, node.first, liveSlots, floatEntryId: floatEntryId, depth: depth),
          second: _buildNode(context, node.second, liveSlots, floatEntryId: floatEntryId, depth: depth),
        );
      case StackNode<T>():
        return _slot(context, node.id, _buildStack(context, node, floatEntryId), liveSlots, depth);
      case FloatNode<T>():
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureFloats());
        return Stack(
          key: _floatKeys.putIfAbsent(node.id, GlobalKey.new),
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            if (node.base != null) _buildNode(context, node.base!, liveSlots, floatEntryId: floatEntryId, depth: depth),
            for (int i = 0; i < node.floats.length; i++)
              _FloatWindow(
                key: ValueKey('float-${node.floats[i].id}'),
                rect: node.floats[i].rect,
                bounds: _floatSizes[node.id],
                title: _labelFor(node.floats[i].content.id),
                editable: onLayoutChanged != null,
                onRaise: () {
                  final next = raiseFloat(widget.layout, node.floats[i].id);
                  if (!identical(next, widget.layout)) onLayoutChanged?.call(next);
                },
                // Raise again here: a quick drag can finish before the raise from its press has come back in.
                onRectChanged: (rect) =>
                    onLayoutChanged?.call(setFloatRect(raiseFloat(widget.layout, node.floats[i].id), node.floats[i].id, rect)),
                onClose: () => onLayoutChanged?.call(removeFloat(widget.layout, node.floats[i].id)),
                chromeBuilder: widget.floatBuilder == null
                    ? null
                    : (context, controls, content) => widget.floatBuilder!(context, node.floats[i], controls, content),
                child: _buildNode(context, node.floats[i].content, liveSlots, floatEntryId: node.floats[i].id, depth: depth + 1 + i),
              ),
          ],
        );
    }
  }

  Widget _buildStack(BuildContext context, StackNode<T> stack, String? floatEntryId) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final active = stack.activePane;
    final onLayoutChanged = widget.onLayoutChanged;

    final Widget body;
    if (widget.keepInactiveMounted) {
      body = IndexedStack(
        index: stack.panes.indexOf(active),
        sizing: StackFit.expand,
        children: [
          for (final pane in stack.panes)
            _buildPane(context, pane, isStacked: true, isActive: pane.id == active.id, floatEntryId: floatEntryId),
        ],
      );
    } else {
      body = _buildPane(context, active, isStacked: true, isActive: true, floatEntryId: floatEntryId);
    }

    Widget tab(PaneNode<T> pane) {
      final Widget tab = _PaneTab(
        isActive: pane.id == active.id,
        onTap: onLayoutChanged == null ? null : () => onLayoutChanged(selectPane(widget.layout, pane.id)),
        child: widget.tabBuilder?.call(context, pane, pane.id == active.id) ?? Text(widget.paneLabel?.call(pane) ?? pane.id),
      );
      return canReorder ? _DragHandle(state: this, paneId: pane.id, child: tab) : tab;
    }

    return Column(
      key: ValueKey('stack-${stack.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: _tabStripHeight,
          decoration: BoxDecoration(
            color: c.surfaceOffset,
            border: Border(bottom: BorderSide(color: c.borderSubtle)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [for (final pane in stack.panes) tab(pane)]),
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _PaneTab extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onTap;
  final Widget child;

  const _PaneTab({required this.isActive, required this.onTap, required this.child});

  @override
  State<_PaneTab> createState() => _PaneTabState();
}

class _PaneTabState extends State<_PaneTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    return Semantics(
      button: true,
      selected: widget.isActive,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.isActive ? c.surfaceBase : (_hovered ? c.surfaceHover : null),
              border: Border(bottom: BorderSide(color: widget.isActive ? c.actionPrimaryBg : const Color(0x00000000), width: 2)),
            ),
            child: DefaultTextStyle(
              style: theme.textTheme.bodySmall.copyWith(
                height: 1.2,
                color: widget.isActive ? c.textPrimary : c.textTertiary,
                fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// What a custom floating window's chrome can do, passed to
/// [Panes.floatBuilder].
class FloatWindowControls {
  /// Makes [child] a handle that drags the window.
  final Widget Function({required Widget child}) dragHandle;

  /// Makes [child] a handle that resizes the window from its bottom-right
  /// corner.
  final Widget Function({required Widget child}) resizeHandle;

  /// Closes the window, discarding the panes inside it.
  final VoidCallback close;

  /// Brings the window to the front. Any press on it already does.
  final VoidCallback raise;

  const FloatWindowControls({required this.dragHandle, required this.resizeHandle, required this.close, required this.raise});
}

/// One floating window: a title bar that drags, a body, and a resize grip.
class _FloatWindow extends StatefulWidget {
  final FloatRect rect;

  /// The size of the box the window lives in, once known.
  final Size? bounds;
  final String title;
  final bool editable;
  final VoidCallback onRaise;
  final ValueChanged<FloatRect> onRectChanged;
  final VoidCallback onClose;
  final Widget Function(BuildContext context, FloatWindowControls controls, Widget content)? chromeBuilder;
  final Widget child;

  const _FloatWindow({
    super.key,
    required this.rect,
    this.bounds,
    required this.title,
    required this.editable,
    required this.onRaise,
    required this.onRectChanged,
    required this.onClose,
    this.chromeBuilder,
    required this.child,
  });

  @override
  State<_FloatWindow> createState() => _FloatWindowState();
}

class _FloatWindowState extends State<_FloatWindow> {
  /// The rect while a move or resize is in flight; null otherwise.
  FloatRect? _live;

  static const double _minWidth = 160;
  static const double _minHeight = 96;
  static const double _headerHeight = 28;

  void _update(FloatRect Function(FloatRect rect) change) {
    setState(() => _live = _fit(change(_live ?? _fit(widget.rect))));
  }

  /// Keeps the window inside its box, so it can always be reached: on a
  /// small screen a stored rect can otherwise sit partly or wholly outside.
  FloatRect _fit(FloatRect rect) {
    final bounds = widget.bounds;
    if (bounds == null || bounds.isEmpty) return rect;
    final width = math.min(rect.width, bounds.width), height = math.min(rect.height, bounds.height);
    return FloatRect(
      x: rect.x.clamp(0, bounds.width - width).toDouble(),
      y: rect.y.clamp(0, bounds.height - height).toDouble(),
      width: width,
      height: height,
    );
  }

  void _commit() {
    final rect = _live;
    setState(() => _live = null);
    if (rect != null && rect != widget.rect) widget.onRectChanged(rect);
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final rect = _fit(_live ?? widget.rect);
    final radius = BorderRadius.circular(theme.cornerRadius);
    final editable = widget.editable;

    Widget moveHandle({required Widget child}) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: editable
          ? (details) =>
                _update((rect) => rect.copyWith(x: math.max(0, rect.x + details.delta.dx), y: math.max(0, rect.y + details.delta.dy)))
          : null,
      onPanEnd: editable ? (_) => _commit() : null,
      onPanCancel: editable ? _commit : null,
      child: child,
    );
    Widget sizeHandle({required Widget child}) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: editable
          ? (details) => _update(
              (rect) => rect.copyWith(
                width: math.max(_minWidth, rect.width + details.delta.dx),
                height: math.max(_minHeight, rect.height + details.delta.dy),
              ),
            )
          : null,
      onPanEnd: editable ? (_) => _commit() : null,
      onPanCancel: editable ? _commit : null,
      child: child,
    );

    final chromeBuilder = widget.chromeBuilder;
    if (chromeBuilder != null) {
      return Positioned(
        left: rect.x,
        top: rect.y,
        width: rect.width,
        height: rect.height,
        child: Listener(
          onPointerDown: editable ? (_) => widget.onRaise() : null,
          child: chromeBuilder(
            context,
            FloatWindowControls(dragHandle: moveHandle, resizeHandle: sizeHandle, close: widget.onClose, raise: widget.onRaise),
            widget.child,
          ),
        ),
      );
    }

    return Positioned(
      left: rect.x,
      top: rect.y,
      width: rect.width,
      height: rect.height,
      child: Listener(
        // Any press on the window brings it to the front.
        onPointerDown: editable ? (_) => widget.onRaise() : null,
        child: Container(
          decoration: BoxDecoration(
            color: c.surfaceBase,
            borderRadius: radius,
            border: Border.all(color: c.iconSecondary),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MouseRegion(
                      cursor: editable ? SystemMouseCursors.move : MouseCursor.defer,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: editable
                            ? (details) => _update(
                                (rect) =>
                                    rect.copyWith(x: math.max(0, rect.x + details.delta.dx), y: math.max(0, rect.y + details.delta.dy)),
                              )
                            : null,
                        onPanEnd: editable ? (_) => _commit() : null,
                        onPanCancel: editable ? _commit : null,
                        child: Container(
                          height: _headerHeight,
                          padding: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: c.surfaceOffset,
                            border: Border(bottom: BorderSide(color: c.borderSubtle)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall.copyWith(
                                    fontSize: 12,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                              if (editable)
                                Semantics(
                                  container: true,
                                  button: true,
                                  label: 'Close ${widget.title}',
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: widget.onClose,
                                      child: SizedBox(
                                        width: _headerHeight,
                                        height: _headerHeight,
                                        child: Icon(PrimeIcons.close, size: 14, color: c.iconSecondary),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
                if (editable)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    width: 16,
                    height: 16,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeDownRight,
                      child: Semantics(
                        label: 'Resize ${widget.title}',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (details) => _update(
                            (rect) => rect.copyWith(
                              width: math.max(_minWidth, rect.width + details.delta.dx),
                              height: math.max(_minHeight, rect.height + details.delta.dy),
                            ),
                          ),
                          onPanEnd: (_) => _commit(),
                          onPanCancel: _commit,
                          child: CustomPaint(painter: _GripPainter(c.iconSecondary)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GripPainter extends CustomPainter {
  final Color color;

  const _GripPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (final inset in const [5.0, 9.0]) {
      canvas.drawLine(Offset(size.width - 3, inset), Offset(inset, size.height - 3), paint);
    }
  }

  @override
  bool shouldRepaint(_GripPainter oldDelegate) => color != oldDelegate.color;
}
