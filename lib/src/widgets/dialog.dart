import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'button.dart';
import 'prime_icons.dart';

/// A single action button for [PrimeDialog]. When pressed, the dialog closes
/// and [PrimeDialog.show] returns [value].
class PrimeDialogAction<T> {
  /// The button label.
  final Widget label;

  /// The value returned when this action is pressed.
  final T? value;

  /// Button variant. Defaults to [ButtonVariant.secondary].
  final ButtonVariant variant;

  const PrimeDialogAction({
    required this.label,
    this.value,
    this.variant = ButtonVariant.secondary,
  });
}

/// A dialog popup that can show a title, content, and optional actions.
///
/// Use [PrimeDialog.show] to display the dialog. It returns a [Future] that
/// completes with the result when the dialog is dismissed (e.g. by tapping
/// an action or the barrier).
///
/// Example:
///
/// ```dart
/// final result = await PrimeDialog.show<bool>(
///   context: context,
///   title: const Text('Confirm'),
///   child: const Text('Are you sure?'),
///   actions: [
///     PrimeDialogAction<bool>(label: const Text('Cancel'), value: false),
///     PrimeDialogAction<bool>(label: const Text('OK'), value: true, variant: ButtonVariant.primary),
///   ],
/// );
/// ```
class PrimeDialog {
  PrimeDialog._();

  /// Shows a dialog with the given [title], [child] content, and optional [actions].
  ///
  /// [showCloseButton] defaults to false when [actions] is provided (e.g. Cancel/OK),
  /// and true when there are no actions, so users can dismiss via the X.
  /// Set explicitly to override.
  ///
  /// [barrierDismissible] controls whether tapping the barrier closes the dialog (returns null).
  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    required Widget child,
    List<PrimeDialogAction<T>>? actions,
    bool? showCloseButton,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return Future<T?>.value(null);

    final hasActions = actions != null && actions.isNotEmpty;
    final showX = showCloseButton ?? !hasActions;

    final completer = Completer<T?>();
    late OverlayEntry entry;

    void dismiss([T? result]) {
      if (!completer.isCompleted) {
        entry.remove();
        completer.complete(result);
      }
    }

    entry = OverlayEntry(
      builder: (overlayContext) => _PrimeDialogOverlay<T>(
        title: title,
        child: child,
        actions: actions,
        showCloseButton: showX,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        onDismiss: dismiss,
      ),
    );
    overlay.insert(entry);
    return completer.future;
  }
}

class _PrimeDialogOverlay<T> extends StatelessWidget {
  final Widget? title;
  final Widget child;
  final List<PrimeDialogAction<T>>? actions;
  final bool showCloseButton;
  final bool barrierDismissible;
  final Color? barrierColor;
  final void Function([T? result]) onDismiss;

  const _PrimeDialogOverlay({
    this.title,
    required this.child,
    this.actions,
    required this.showCloseButton,
    required this.barrierDismissible,
    this.barrierColor,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final colors = theme.colorScheme;
        final barrier = barrierColor ?? ui.Color.fromARGB(128, 0, 0, 0);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: barrierDismissible ? () => onDismiss() : null,
                behavior: HitTestBehavior.opaque,
                child: Container(color: barrier),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {}, // block tap from closing when tapping dialog
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
                  decoration: BoxDecoration(
                    color: colors.surfaceBase,
                    borderRadius: BorderRadius.circular(theme.cornerRadius),
                    border: Border.all(color: colors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: ui.Color.fromARGB(38, 0, 0, 0),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: title + optional close
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, showCloseButton ? 12 : 20, 0),
                        child: Row(
                          children: [
                            if (title != null) ...[
                              Expanded(
                                child: DefaultTextStyle(
                                  style: theme.textTheme.bodyDefault.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    color: colors.textPrimary,
                                  ),
                                  child: title!,
                                ),
                              ),
                              if (showCloseButton) const SizedBox(width: 8),
                            ],
                            if (showCloseButton)
                              GestureDetector(
                                onTap: () => onDismiss(),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(PrimeIcons.close, size: 20, color: colors.textTertiary),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: DefaultTextStyle(
                            style: theme.textTheme.bodyDefault.copyWith(color: colors.textPrimary, height: 1.4),
                            child: child,
                          ),
                        ),
                      ),
                      // Actions
                      if (actions != null && actions!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              for (int i = 0; i < actions!.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                Button(
                                  label: actions![i].label,
                                  variant: actions![i].variant,
                                  onPressed: () => onDismiss(actions![i].value),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else
                        const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
