import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'floating.dart';

/// Forces a [Tooltip] to always or never show, regardless of hover.
enum TooltipVisibility { visible, invisible }

/// Provides contextual information for a specific element.
///
/// Shows on mouse hover, on keyboard focus, and on long press for touch.
///
/// ```dart
/// Tooltip(
///   message: 'Copy to clipboard',
///   child: Icon(PrimeIcons.contentCopy),
/// )
/// ```
class Tooltip extends StatefulWidget {
  /// The element the tooltip describes.
  final Widget child;

  /// Plain-text tooltip content. Ignored when [description] is given.
  final String? message;

  /// Rich tooltip content.
  final Widget? description;

  /// Preferred side of [child] to show the tooltip on.
  final FloatingPlacement placement;

  /// When set, overrides hover/focus behavior.
  final TooltipVisibility? visibility;

  /// Delay between mouse enter and the tooltip appearing.
  final Duration hoverDelay;

  /// How long a long-press tooltip stays up on touch devices.
  final Duration touchDuration;

  const Tooltip({
    super.key,
    required this.child,
    this.message,
    this.description,
    this.placement = FloatingPlacement.top,
    this.visibility,
    this.hoverDelay = Duration.zero,
    this.touchDuration = const Duration(seconds: 2),
  });

  @override
  State<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends State<Tooltip> {
  bool _active = false;
  Timer? _timer;

  bool get _hasContent => widget.description != null || (widget.message?.isNotEmpty ?? false);

  bool get _visible {
    if (!_hasContent) return false;
    switch (widget.visibility) {
      case TooltipVisibility.visible:
        return true;
      case TooltipVisibility.invisible:
        return false;
      case null:
        return _active;
    }
  }

  void _show({Duration delay = Duration.zero}) {
    _timer?.cancel();
    if (delay == Duration.zero) {
      if (!_active) setState(() => _active = true);
    } else {
      _timer = Timer(delay, () {
        if (mounted) setState(() => _active = true);
      });
    }
  }

  void _hide() {
    _timer?.cancel();
    if (_active) setState(() => _active = false);
  }

  void _showForTouch() {
    _show();
    _timer = Timer(widget.touchDuration, () {
      if (mounted) _hide();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Floating(
      visible: _visible,
      placement: widget.placement,
      offset: 7,
      ignorePointer: true,
      floatingBuilder: (context) => _TooltipBubble(description: widget.description ?? Text(widget.message ?? '')),
      child: Semantics(
        tooltip: widget.message,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (focused) => focused ? _show() : _hide(),
          child: MouseRegion(
            onEnter: (_) => _show(delay: widget.hoverDelay),
            onExit: (_) => _hide(),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: widget.visibility == null && _hasContent ? _showForTouch : null,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  final Widget description;

  const _TooltipBubble({required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final background = theme.colorScheme.actionPrimaryBg;
    final placement = Floating.placementOf(context) ?? FloatingPlacement.top;

    final Alignment arrowAlignment;
    final Offset arrowShift;
    switch (placement) {
      case FloatingPlacement.top:
        (arrowAlignment, arrowShift) = (Alignment.bottomCenter, const Offset(0, 0.5));
      case FloatingPlacement.topStart:
        (arrowAlignment, arrowShift) = (const Alignment(-0.8, 1), const Offset(0, 0.5));
      case FloatingPlacement.topEnd:
        (arrowAlignment, arrowShift) = (const Alignment(0.8, 1), const Offset(0, 0.5));
      case FloatingPlacement.bottom:
        (arrowAlignment, arrowShift) = (Alignment.topCenter, const Offset(0, -0.5));
      case FloatingPlacement.bottomStart:
        (arrowAlignment, arrowShift) = (const Alignment(-0.8, -1), const Offset(0, -0.5));
      case FloatingPlacement.bottomEnd:
        (arrowAlignment, arrowShift) = (const Alignment(0.8, -1), const Offset(0, -0.5));
      case FloatingPlacement.left:
        (arrowAlignment, arrowShift) = (Alignment.centerRight, const Offset(0.5, 0));
      case FloatingPlacement.right:
        (arrowAlignment, arrowShift) = (Alignment.centerLeft, const Offset(-0.5, 0));
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Align(
              alignment: arrowAlignment,
              child: FractionalTranslation(
                translation: arrowShift,
                child: Transform.rotate(angle: 0.785398, child: Container(width: 8.5, height: 8.5, color: background)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(theme.cornerRadius / 2)),
            child: DefaultTextStyle(
              style: theme.textTheme.bodySmall.copyWith(fontSize: 12, color: theme.colorScheme.actionPrimaryFg),
              child: description,
            ),
          ),
        ],
      ),
    );
  }
}
