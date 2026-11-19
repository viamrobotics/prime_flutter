import 'package:flutter/widgets.dart';

/// An unstyled disclosure: a trigger that shows or hides [content] with a
/// height animation.
///
/// For a styled list row, use [ExpansionListItem].
///
/// ```dart
/// Expandable(
///   triggerBuilder: (context, isOpen) => Text(isOpen ? 'Hide' : 'Show'),
///   content: const Text('More detail'),
/// )
/// ```
class Expandable extends StatefulWidget {
  /// Builds the tappable trigger.
  final Widget Function(BuildContext context, bool isOpen) triggerBuilder;

  final Widget content;

  /// Controls the open state. When null the widget manages its own state,
  /// starting from [initiallyOpen].
  final bool? open;

  final bool initiallyOpen;

  final ValueChanged<bool>? onOpenChanged;

  const Expandable({super.key, required this.triggerBuilder, required this.content, this.open, this.initiallyOpen = false, this.onOpenChanged});

  @override
  State<Expandable> createState() => _ExpandableState();
}

class _ExpandableState extends State<Expandable> with SingleTickerProviderStateMixin {
  late bool _open = widget.open ?? widget.initiallyOpen;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    value: _open ? 1 : 0,
  );
  late final Animation<double> _size = CurvedAnimation(parent: _controller, curve: const Cubic(0, 0, 0.38, 0.9));

  @override
  void didUpdateWidget(Expandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != null && widget.open != _open) _setOpen(widget.open!);
  }

  void _setOpen(bool open) {
    _open = open;
    if (open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _toggle() {
    final next = !_open;
    if (widget.open == null) setState(() => _setOpen(next));
    widget.onOpenChanged?.call(next);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: widget.triggerBuilder(context, _open),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _size,
          alignment: Alignment.topCenter,
          child: widget.content,
        ),
      ],
    );
  }
}
