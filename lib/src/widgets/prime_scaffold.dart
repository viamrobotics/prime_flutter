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

        return Container(
          color: effectiveBackgroundColor,
          child: Column(
            children: [
              if (appBar != null) appBar!,
              Expanded(child: SafeArea(top: false, bottom: false, child: body)),
              if (bottomNavigationBar != null) SafeArea(top: false, child: bottomNavigationBar!),
            ],
          ),
        );
      },
    );
  }
}
