import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'icon_button.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';

/// The size of a [Modal].
enum ModalVariant {
  /// Up to 400 x 320.
  small,

  /// Up to 480 x 400. The default.
  base,

  /// Up to 800 x 600.
  medium,

  /// Sized by its content.
  fit,

  /// Fills the screen.
  full,
}

/// A modal overlay with a title, message, body and up to three actions.
///
/// Kept for parity with Prime for the web, where it is deprecated in favor
/// of the dialog. Prefer [Dialog] for new code; use this when you need
/// custom action widgets or the size variants.
///
/// ```dart
/// Modal.show<void>(
///   context: context,
///   title: const Text('Print a statement?'),
///   message: const Text('This writes to the console.'),
///   actionsBuilder: (context) => [
///     Button(label: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
///     Button(label: const Text('Print'), variant: ButtonVariant.primary, onPressed: print),
///   ],
/// );
/// ```
class Modal extends StatelessWidget {
  final Widget? title;
  final Widget? message;

  /// Free-form content under the message.
  final Widget? child;

  /// Action widgets, laid out at the trailing edge in the order given
  /// (tertiary, secondary, primary).
  final List<Widget> actions;

  final ModalVariant variant;

  /// Called by the close button. Defaults to popping the route.
  final VoidCallback? onClose;

  const Modal({super.key, this.title, this.message, this.child, this.actions = const [], this.variant = ModalVariant.base, this.onClose});

  /// Shows a [Modal] over the current screen. The future completes with the
  /// value passed to `Navigator.pop`, or null when dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    Widget? message,
    Widget? child,
    List<Widget> Function(BuildContext context)? actionsBuilder,
    ModalVariant variant = ModalVariant.base,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
  }) {
    return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierDismissible: barrierDismissible,
        barrierColor: const Color(0x66000000),
        barrierLabel: 'Dismiss',
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 120),
        reverseTransitionDuration: const Duration(milliseconds: 120),
        pageBuilder: (routeContext, _, _) => EscapeToPop(
          child: Modal(
            title: title,
            message: message,
            variant: variant,
            actions: actionsBuilder?.call(routeContext) ?? const [],
            child: child,
          ),
        ),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final isFull = variant == ModalVariant.full;
    final constraints = switch (variant) {
      ModalVariant.small => const BoxConstraints(maxWidth: 400, maxHeight: 320),
      ModalVariant.base => const BoxConstraints(maxWidth: 480, maxHeight: 400),
      ModalVariant.medium => const BoxConstraints(maxWidth: 800, maxHeight: 600),
      ModalVariant.fit => const BoxConstraints(),
      ModalVariant.full => const BoxConstraints.expand(),
    };

    final content = Column(
      mainAxisSize: isFull ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Semantics(
              header: true,
              child: DefaultTextStyle(
                style: theme.textTheme.bodyDefault.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: c.textPrimary),
                child: title!,
              ),
            ),
          ),
        if (message != null) ...[
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: theme.textTheme.bodySmall.copyWith(color: c.textSecondary),
            child: message!,
          ),
        ],
        if (child != null) ...[const SizedBox(height: 8), isFull ? Expanded(child: child!) : child!] else if (isFull) const Spacer(),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: actions),
        ],
      ],
    );

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isFull ? 0 : 16),
          child: ConstrainedBox(
            constraints: constraints,
            child: Semantics(
              scopesRoute: true,
              explicitChildNodes: true,
              child: Container(
                decoration: BoxDecoration(
                  color: c.surfaceBase,
                  borderRadius: isFull ? null : BorderRadius.circular(theme.cornerRadius),
                  border: Border.all(color: c.iconDisabled),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: isFull ? content : SingleChildScrollView(child: content),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        icon: const Icon(PrimeIcons.close),
                        label: 'Close modal',
                        showTooltip: false,
                        onPressed: onClose ?? () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
