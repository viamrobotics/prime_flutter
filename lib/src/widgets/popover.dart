import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'expandable.dart';
import 'floating.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';

/// A floating panel of arbitrary content anchored to a trigger.
///
/// It closes on a press outside and when the trigger is tapped again. The
/// content builder receives a `close` callback for its own dismiss control.
///
/// ```dart
/// Popover(
///   trigger: Button(label: const Text('Filters')),
///   contentBuilder: (context, close) => Column(
///     mainAxisSize: MainAxisSize.min,
///     children: [const Text('Filter options'), Button(label: const Text('Done'), onPressed: close)],
///   ),
/// )
/// ```
class Popover extends StatefulWidget {
  final Widget trigger;
  final Widget Function(BuildContext context, VoidCallback close) contentBuilder;
  final FloatingPlacement placement;
  final double offset;

  /// Padding inside the panel.
  final EdgeInsetsGeometry padding;

  /// Controls the open state. Null lets the popover manage it.
  final bool? open;
  final ValueChanged<bool>? onOpenChanged;

  /// Accessible label of the panel.
  final String? label;

  const Popover({
    super.key,
    required this.trigger,
    required this.contentBuilder,
    this.placement = FloatingPlacement.bottom,
    this.offset = 4,
    this.padding = const EdgeInsets.all(16),
    this.open,
    this.onOpenChanged,
    this.label,
  });

  @override
  State<Popover> createState() => _PopoverState();
}

class _PopoverState extends State<Popover> {
  bool _open = false;

  bool get _isOpen => widget.open ?? _open;

  void _setOpen(bool open) {
    if (open == _isOpen) return;
    if (widget.open == null) setState(() => _open = open);
    widget.onOpenChanged?.call(open);
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Floating(
      visible: _isOpen,
      placement: widget.placement,
      offset: widget.offset,
      onTapOutside: () => _setOpen(false),
      onEscape: () => _setOpen(false),
      floatingBuilder: (context) => Semantics(
        container: true,
        label: widget.label,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceBase,
            borderRadius: BorderRadius.circular(theme.cornerRadius),
            border: Border.all(color: theme.colorScheme.iconDisabled),
          ),
          child: DefaultTextStyle(style: theme.textTheme.bodySmall, child: widget.contentBuilder(context, () => _setOpen(false))),
        ),
      ),
      child: Semantics(
        button: true,
        expanded: _isOpen,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TapListener(onTap: () => _setOpen(!_isOpen), child: widget.trigger),
        ),
      ),
    );
  }
}

/// A styled disclosure: a titled row with a chevron that shows and hides its
/// content.
///
/// For a fully custom trigger use [Expandable]; for a list row use
/// [ExpansionListItem].
///
/// ```dart
/// Collapsible(
///   title: const Text('Advanced'),
///   child: const Text('More settings'),
/// )
/// ```
class Collapsible extends StatelessWidget {
  final Widget title;
  final Widget child;

  /// Controls the open state. Null lets the widget manage it.
  final bool? open;
  final bool initiallyOpen;
  final ValueChanged<bool>? onOpenChanged;
  final bool disabled;

  const Collapsible({
    super.key,
    required this.title,
    required this.child,
    this.open,
    this.initiallyOpen = false,
    this.onOpenChanged,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    return IgnorePointer(
      ignoring: disabled,
      child: Expandable(
        open: open,
        initiallyOpen: initiallyOpen,
        onOpenChanged: onOpenChanged,
        triggerBuilder: (context, isOpen) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedRotation(
                turns: isOpen ? 0.25 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(PrimeIcons.chevronRight, size: 18, color: disabled ? c.iconDisabled : c.iconSecondary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DefaultTextStyle(
                  style: theme.textTheme.bodySmall.copyWith(
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: disabled ? c.textPlaceholder : c.textPrimary,
                  ),
                  child: title,
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
          child: DefaultTextStyle(
            style: theme.textTheme.bodySmall.copyWith(color: c.textSecondary),
            child: child,
          ),
        ),
      ),
    );
  }
}
