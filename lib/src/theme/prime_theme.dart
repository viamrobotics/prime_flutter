import 'package:flutter/widgets.dart';
import 'prime_theme_data.dart';

/// Provides [PrimeThemeData] to the widgets below it.
///
/// It is an [InheritedTheme], so dialogs, modals, sheets, toasts and takeovers opened from below a [PrimeTheme] use
/// that theme even though their routes and overlay entries sit above it in the tree. A flow inside a non-Prime app can
/// wrap itself in a [PrimeTheme] and everything it opens follows.
class PrimeTheme extends InheritedTheme {
  final PrimeThemeData data;

  const PrimeTheme({super.key, required this.data, required super.child});

  /// The theme of the closest [PrimeTheme] ancestor, or null when there is none.
  ///
  /// Packages that may render outside a `PrimeApp` use this to fall back to a
  /// theme of their own, e.g. `PrimeTheme.maybeOf(context) ?? PrimeThemeData.light()`.
  static PrimeThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrimeTheme>()?.data;
  }

  static PrimeThemeData of(BuildContext context) {
    final PrimeTheme? result = context.dependOnInheritedWidgetOfExactType<PrimeTheme>();
    assert(result != null, 'No PrimeTheme found in context');
    return result!.data;
  }

  static Widget consumer({required Widget Function(BuildContext context, PrimeThemeData theme) builder}) {
    return Builder(
      builder: (context) {
        final theme = PrimeTheme.of(context);
        return builder(context, theme);
      },
    );
  }

  @override
  Widget wrap(BuildContext context, Widget child) => PrimeTheme(data: data, child: child);

  @override
  bool updateShouldNotify(PrimeTheme oldWidget) {
    return data != oldWidget.data;
  }
}
