import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Where a [Floating] popup sits relative to its anchor.
enum FloatingPlacement { top, topStart, topEnd, bottom, bottomStart, bottomEnd, left, right }

/// Anchors a popup to [child] and renders it in the nearest [Overlay].
///
/// This is the building block behind [Tooltip], [FloatingMenu], [NavDropdown],
/// [SearchableSelect] and [RelativeTimePicker]. Use it directly for custom
/// popups.
///
/// ```dart
/// Floating(
///   visible: isOpen,
///   onTapOutside: () => setState(() => isOpen = false),
///   floatingBuilder: (context) => const ContextMenu(children: [...]),
///   child: Button(label: const Text('Open'), onPressed: toggle),
/// )
/// ```
class Floating extends StatefulWidget {
  /// The anchor the popup is positioned against.
  final Widget child;

  /// Builds the popup.
  final WidgetBuilder floatingBuilder;

  /// Whether the popup is shown.
  final bool visible;

  /// Preferred placement. A vertical placement flips to the other side when
  /// the anchor is too close to that edge of the screen.
  final FloatingPlacement placement;

  /// Gap between the anchor and the popup.
  final double offset;

  /// Forces the popup to be exactly as wide as the anchor.
  final bool matchWidth;

  /// Called on a pointer down outside both the anchor and the popup.
  final VoidCallback? onTapOutside;

  /// When true the popup never receives pointer events (tooltips).
  final bool ignorePointer;

  /// Called when Escape is pressed while the popup is shown. With several
  /// popups open, only the one opened last hears it.
  final VoidCallback? onEscape;

  const Floating({
    super.key,
    required this.child,
    required this.floatingBuilder,
    required this.visible,
    this.placement = FloatingPlacement.bottomStart,
    this.offset = 4,
    this.matchWidth = false,
    this.onTapOutside,
    this.ignorePointer = false,
    this.onEscape,
  });

  /// The placement actually used for the popup enclosing [context], after any
  /// flip. Only meaningful inside [floatingBuilder].
  static FloatingPlacement? placementOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FloatingScope>()?.placement;
  }

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingScope extends InheritedWidget {
  final FloatingPlacement placement;

  const _FloatingScope({required this.placement, required super.child});

  @override
  bool updateShouldNotify(_FloatingScope oldWidget) => placement != oldWidget.placement;
}

class _FloatingState extends State<Floating> {
  /// The popups that listen for Escape, oldest first.
  static final List<_FloatingState> _escapeStack = [];
  static bool _listening = false;

  static bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape || _escapeStack.isEmpty) return false;
    _escapeStack.last.widget.onEscape?.call();
    return true;
  }

  void _syncEscape() {
    final wants = widget.visible && widget.onEscape != null;
    if (wants && !_escapeStack.contains(this)) {
      _escapeStack.add(this);
    } else if (!wants) {
      _escapeStack.remove(this);
    }
    if (_escapeStack.isNotEmpty && !_listening) {
      HardwareKeyboard.instance.addHandler(_handleKey);
      _listening = true;
    } else if (_escapeStack.isEmpty && _listening) {
      HardwareKeyboard.instance.removeHandler(_handleKey);
      _listening = false;
    }
  }

  @override
  void dispose() {
    _escapeStack.remove(this);
    if (_escapeStack.isEmpty && _listening) {
      HardwareKeyboard.instance.removeHandler(_handleKey);
      _listening = false;
    }
    super.dispose();
  }

  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _link = LayerLink();

  @override
  void initState() {
    super.initState();
    // The portal stays shown for the life of the widget and renders nothing
    // while hidden, because the controller cannot be toggled during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.show();
    });
  }

  /// Flips a vertical placement when the anchor sits too close to that edge.
  FloatingPlacement _resolvePlacement(RenderBox? anchor) {
    final placement = widget.placement;
    if (anchor == null || !anchor.hasSize || !anchor.attached) return placement;
    final screen = MediaQuery.sizeOf(context);
    final origin = anchor.localToGlobal(Offset.zero);
    final spaceAbove = origin.dy;
    final spaceBelow = screen.height - origin.dy - anchor.size.height;
    const needed = 200.0;

    switch (placement) {
      case FloatingPlacement.bottom:
        return spaceBelow < needed && spaceAbove > spaceBelow ? FloatingPlacement.top : placement;
      case FloatingPlacement.bottomStart:
        return spaceBelow < needed && spaceAbove > spaceBelow ? FloatingPlacement.topStart : placement;
      case FloatingPlacement.bottomEnd:
        return spaceBelow < needed && spaceAbove > spaceBelow ? FloatingPlacement.topEnd : placement;
      case FloatingPlacement.top:
        return spaceAbove < 60 && spaceBelow > spaceAbove ? FloatingPlacement.bottom : placement;
      case FloatingPlacement.topStart:
        return spaceAbove < 60 && spaceBelow > spaceAbove ? FloatingPlacement.bottomStart : placement;
      case FloatingPlacement.topEnd:
        return spaceAbove < 60 && spaceBelow > spaceAbove ? FloatingPlacement.bottomEnd : placement;
      case FloatingPlacement.left:
      case FloatingPlacement.right:
        return placement;
    }
  }

  ({Alignment target, Alignment follower, Offset offset}) _anchors(FloatingPlacement placement) {
    final gap = widget.offset;
    switch (placement) {
      case FloatingPlacement.top:
        return (target: Alignment.topCenter, follower: Alignment.bottomCenter, offset: Offset(0, -gap));
      case FloatingPlacement.topStart:
        return (target: Alignment.topLeft, follower: Alignment.bottomLeft, offset: Offset(0, -gap));
      case FloatingPlacement.topEnd:
        return (target: Alignment.topRight, follower: Alignment.bottomRight, offset: Offset(0, -gap));
      case FloatingPlacement.bottom:
        return (target: Alignment.bottomCenter, follower: Alignment.topCenter, offset: Offset(0, gap));
      case FloatingPlacement.bottomStart:
        return (target: Alignment.bottomLeft, follower: Alignment.topLeft, offset: Offset(0, gap));
      case FloatingPlacement.bottomEnd:
        return (target: Alignment.bottomRight, follower: Alignment.topRight, offset: Offset(0, gap));
      case FloatingPlacement.left:
        return (target: Alignment.centerLeft, follower: Alignment.centerRight, offset: Offset(-gap, 0));
      case FloatingPlacement.right:
        return (target: Alignment.centerRight, follower: Alignment.centerLeft, offset: Offset(gap, 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncEscape();
    return TapRegion(
      groupId: this,
      onTapOutside: widget.visible && widget.onTapOutside != null ? (_) => widget.onTapOutside!() : null,
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _controller,
          overlayChildBuilder: (overlayContext) {
            if (!widget.visible) return const SizedBox.shrink();
            final anchor = context.findRenderObject() as RenderBox?;
            final resolved = _resolvePlacement(anchor);
            Widget popup = _FloatingScope(
              placement: resolved,
              child: Builder(builder: widget.floatingBuilder),
            );
            final anchors = _anchors(resolved);
            if (widget.matchWidth && anchor != null && anchor.hasSize) {
              popup = SizedBox(width: anchor.size.width, child: popup);
            }

            return Align(
              alignment: Alignment.topLeft,
              child: CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: anchors.target,
                followerAnchor: anchors.follower,
                offset: anchors.offset,
                child: IgnorePointer(
                  ignoring: widget.ignorePointer,
                  child: TapRegion(groupId: this, child: popup),
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
