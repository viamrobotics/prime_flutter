import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Internal: tracks hover and press for a tappable region.
class Pressable extends StatefulWidget {
  final Widget Function(BuildContext context, bool hovered, bool pressed) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool disabled;
  final String? semanticLabel;

  const Pressable({super.key, required this.builder, this.onTap, this.onLongPress, this.disabled = false, this.semanticLabel});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.disabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.disabled;
    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: disabled ? null : widget.onTap,
          onLongPress: disabled ? null : widget.onLongPress,
          child: widget.builder(context, _hovered && !disabled, _pressed && !disabled),
        ),
      ),
    );
  }
}

/// Internal: reports a tap on [child] without entering the gesture arena, so
/// it still fires when [child] is itself tappable (a `Button` used as a menu
/// trigger, for example).
class TapListener extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TapListener({super.key, required this.child, this.onTap});

  @override
  State<TapListener> createState() => _TapListenerState();
}

class _TapListenerState extends State<TapListener> {
  Offset? _down;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => _down = event.buttons == kPrimaryButton ? event.position : null,
      onPointerCancel: (_) => _down = null,
      onPointerUp: (event) {
        final down = _down;
        _down = null;
        // A press that travelled was a scroll or a drag, not a tap.
        if (down != null && (event.position - down).distance <= kTouchSlop) widget.onTap?.call();
      },
      child: widget.child,
    );
  }
}

/// Internal: pops the enclosing route when Escape is pressed, while that
/// route is the one on top.
class EscapeToPop extends StatefulWidget {
  final Widget child;

  const EscapeToPop({super.key, required this.child});

  @override
  State<EscapeToPop> createState() => _EscapeToPopState();
}

class _EscapeToPopState extends State<EscapeToPop> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKey);
    super.dispose();
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.escape || !mounted) return false;
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return false;
    Navigator.of(context).maybePop();
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
