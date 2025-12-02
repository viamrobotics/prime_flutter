import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

class PrimeScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const PrimeScaffold({super.key, required this.body, this.appBar, this.bottomNavigationBar, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.white;

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
