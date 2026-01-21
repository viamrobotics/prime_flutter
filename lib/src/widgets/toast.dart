import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../prime_flutter.dart';

enum ToastVariant { neutral, success, info, warning, danger }

/// A toast widget used to show temporary messages.
class Toast extends StatelessWidget {
  /// The message to display.
  final String message;

  /// The variant of the toast. Defaults to [ToastVariant.neutral].
  final ToastVariant variant;

  /// An optional action widget (e.g., a button).
  final Widget? action;

  /// Callback for the close button.
  final VoidCallback? onClose;

  const Toast({super.key, required this.message, this.variant = ToastVariant.neutral, this.action, this.onClose});

  /// Shows a toast message.
  static void show(
    BuildContext context, {
    required String message,
    ToastVariant variant = ToastVariant.neutral,
    Duration duration = const Duration(seconds: 4),
    Widget? action,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    // Calculate bottom offset based on PrimeScaffold and SafeArea
    final layoutData = PrimeLayoutData.of(context);
    final safePadding = MediaQuery.of(context).padding.bottom;
    final bottomOffset = (layoutData?.bottomOffset ?? 0) + safePadding + 24;

    entry = OverlayEntry(
      builder: (context) {
        return _ToastOverlay(
          message: message,
          variant: variant,
          duration: duration,
          action: action,
          bottomOffset: bottomOffset,
          onDismiss: () {
            entry.remove();
          },
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        Color iconColor;
        IconData iconData;

        switch (variant) {
          case ToastVariant.success:
            iconColor = theme.colorScheme.statusSuccessDark;
            iconData = PrimeIcons.checkCircle;
            break;
          case ToastVariant.info:
            iconColor = theme.colorScheme.statusInfoDark;
            iconData = PrimeIcons.information;
            break;
          case ToastVariant.warning:
            iconColor = theme.colorScheme.statusWarningDark;
            iconData = PrimeIcons.alert;
            break;
          case ToastVariant.danger:
            iconColor = theme.colorScheme.statusDangerDark;
            iconData = PrimeIcons.alertCircle;
            break;
          case ToastVariant.neutral:
            iconColor = theme.colorScheme.iconPrimary;
            iconData = PrimeIcons.domain;
            break;
        }

        return Container(
          constraints: const BoxConstraints(minHeight: 48, maxWidth: 400),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceOffset,
            borderRadius: BorderRadius.circular(theme.cornerRadius),
            border: Border.all(color: theme.colorScheme.borderSubtle),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: action != null ? 4 : 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(iconData, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(message, style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textPrimary)),
                ),
                if (action != null) ...[const SizedBox(width: 16), action!],
                const SizedBox(width: 12),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Icon(PrimeIcons.close, color: theme.colorScheme.iconSecondary, size: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final ToastVariant variant;
  final Duration duration;
  final Widget? action;
  final VoidCallback onDismiss;
  final double bottomOffset;

  const _ToastOverlay({
    required this.message,
    required this.variant,
    required this.duration,
    required this.onDismiss,
    required this.bottomOffset,
    this.action,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _timer = Timer(widget.duration, () {
      _dismiss();
    });
  }

  void _dismiss() {
    _timer?.cancel();
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottomOffset,
      left: 24,
      right: 24,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _opacity,
              child: SlideTransition(position: _offset, child: child),
            );
          },
          child: Toast(message: widget.message, variant: widget.variant, action: widget.action, onClose: _dismiss),
        ),
      ),
    );
  }
}
