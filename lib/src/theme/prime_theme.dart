import 'package:flutter/widgets.dart';
import 'prime_theme_data.dart';

class PrimeTheme extends InheritedWidget {
  final PrimeThemeData data;

  const PrimeTheme({super.key, required this.data, required super.child});

  static PrimeThemeData of(BuildContext context) {
    final PrimeTheme? result = context
        .dependOnInheritedWidgetOfExactType<PrimeTheme>();
    assert(result != null, 'No PrimeTheme found in context');
    return result!.data;
  }

  static Widget consumer({
    required Widget Function(BuildContext context, PrimeThemeData theme)
    builder,
  }) {
    return Builder(
      builder: (context) {
        final theme = PrimeTheme.of(context);
        return builder(context, theme);
      },
    );
  }

  @override
  bool updateShouldNotify(PrimeTheme oldWidget) {
    return data != oldWidget.data;
  }
}
