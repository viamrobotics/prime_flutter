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

  const PrimeScaffold({super.key, required this.body, this.appBar, this.bottomNavigationBar, this.backgroundColor});

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

        return PrimeLayoutData(
          bottomOffset: bottomOffset,
          child: Container(
            color: effectiveBackgroundColor,
            child: Column(
              children: [
                if (appBar != null) appBar!,
                Expanded(child: SafeArea(top: false, bottom: false, child: body)),
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
