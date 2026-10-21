import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

/// A scaffold widget. Used to build a Prime styled screens.
class PrimeScaffold extends StatelessWidget {
  /// The body of the scaffold.
  final Widget body;

  /// The app bar of the scaffold.
  final PreferredSizeWidget? appBar;

  /// The bottom navigation bar of the scaffold.
  final Widget? bottomNavigationBar;

  /// The background color of the scaffold.
  final Color? backgroundColor;

  /// Whether the [body] should shrink to stay above the on-screen keyboard. Defaults to true, like Material's
  /// `Scaffold.resizeToAvoidBottomInset`.
  ///
  /// When true, the body ends at the keyboard's top edge, so a focused text field inside a scrollable body is
  /// scrolled into view above the keyboard instead of staying hidden behind it. The [bottomNavigationBar] is not
  /// lifted; the keyboard covers it. The keyboard inset is removed from the body's [MediaQuery], so a nested
  /// scaffold or keyboard-aware child doesn't account for it twice.
  final bool resizeToAvoidBottomInset;

  const PrimeScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.surfaceBase;
        double bottomOffset = 0;
        if (bottomNavigationBar != null) {
          if (bottomNavigationBar is PreferredSizeWidget) {
            bottomOffset = (bottomNavigationBar as PreferredSizeWidget).preferredSize.height;
          } else {
            bottomOffset = 60; // Fallback for standard height
          }
        }

        var bodyBottomInset = 0.0;
        if (resizeToAvoidBottomInset) {
          final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
          // The keyboard covers the bottom navigation bar (and its safe area), so only shrink the body by the part
          // of the keyboard that reaches above it.
          final navigationBarHeight = bottomNavigationBar == null ? 0.0 : bottomOffset + MediaQuery.paddingOf(context).bottom;
          bodyBottomInset = math.max(0.0, keyboardHeight - navigationBarHeight);
        }

        return PrimeLayoutData(
          bottomOffset: bottomOffset,
          child: Container(
            color: effectiveBackgroundColor,
            child: Column(
              children: [
                if (appBar != null) appBar!,
                Expanded(
                  child: MediaQuery.removeViewInsets(
                    context: context,
                    removeBottom: resizeToAvoidBottomInset,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bodyBottomInset),
                      child: SafeArea(top: false, bottom: false, child: body),
                    ),
                  ),
                ),
                if (bottomNavigationBar != null) SafeArea(top: false, child: bottomNavigationBar!),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PrimeLayoutData extends InheritedWidget {
  final double bottomOffset;

  const PrimeLayoutData({super.key, required this.bottomOffset, required super.child});

  static PrimeLayoutData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrimeLayoutData>();
  }

  @override
  bool updateShouldNotify(PrimeLayoutData oldWidget) => bottomOffset != oldWidget.bottomOffset;
}
