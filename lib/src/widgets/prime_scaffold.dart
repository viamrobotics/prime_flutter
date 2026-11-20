import 'package:flutter/services.dart';
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

  /// A button floating over the bottom end corner of the [body], e.g. an
  /// [IconButton] or a `Button`.
  final Widget? floatingActionButton;

  /// Whether the [body] shrinks to stay clear of the on-screen keyboard, so
  /// that a focused input can scroll into view. Defaults to true.
  ///
  /// The body then sees no keyboard inset in its [MediaQuery]. The
  /// [bottomNavigationBar] stays where it is, under the keyboard.
  final bool resizeToAvoidBottomInset;

  const PrimeScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.floatingActionButton,
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

        final double keyboardInset = resizeToAvoidBottomInset ? MediaQuery.viewInsetsOf(context).bottom : 0;
        final bool keyboardOpen = keyboardInset > 0;

        Widget content = body;
        if (floatingActionButton != null) {
          content = Stack(
            fit: StackFit.expand,
            children: [
              content,
              PositionedDirectional(
                end: 16,
                bottom: 16,
                // With no navigation bar below, the button clears the home indicator itself.
                child: SafeArea(top: false, bottom: bottomNavigationBar == null && !keyboardOpen, child: floatingActionButton!),
              ),
            ],
          );
        }
        if (resizeToAvoidBottomInset) {
          content = Padding(
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: MediaQuery.removeViewInsets(context: context, removeBottom: true, child: content),
          );
        }

        // Tell the platform which way the status and navigation bar icons should contrast.
        final bool dark = effectiveBackgroundColor.computeLuminance() < 0.5;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: const Color(0x00000000),
            statusBarBrightness: dark ? Brightness.dark : Brightness.light,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: effectiveBackgroundColor,
            systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          ),
          child: PrimeLayoutData(
            bottomOffset: bottomOffset,
            child: ColoredBox(
              color: effectiveBackgroundColor,
              child: Column(
                children: [
                  if (appBar != null) appBar!,
                  Expanded(child: SafeArea(top: false, bottom: false, child: content)),
                  // Kept in the tree, so the bar holds its state while the keyboard covers it.
                  if (bottomNavigationBar != null)
                    Offstage(
                      offstage: keyboardOpen,
                      child: SafeArea(top: false, child: bottomNavigationBar!),
                    ),
                ],
              ),
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
