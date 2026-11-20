import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../widgets/prime_page_route.dart';
import 'prime_color_scheme.dart';
import 'prime_text_theme.dart';

@immutable
class PrimeThemeData {
  final PrimeColorScheme colorScheme;
  final PrimeTextTheme textTheme;
  final double cornerRadius;

  /// The page transition each platform uses for a [PrimePageRoute].
  final PrimePageTransitionsTheme pageTransitionsTheme;

  const PrimeThemeData({
    required this.colorScheme,
    required this.textTheme,
    required this.cornerRadius,
    this.pageTransitionsTheme = const PrimePageTransitionsTheme(),
  });

  factory PrimeThemeData.light() {
    final scheme = PrimeColorScheme.light();
    return PrimeThemeData(colorScheme: scheme, textTheme: PrimeTextTheme.withColorScheme(scheme), cornerRadius: 8.0);
  }

  factory PrimeThemeData.dark() {
    final scheme = PrimeColorScheme.dark();
    return PrimeThemeData(colorScheme: scheme, textTheme: PrimeTextTheme.withColorScheme(scheme), cornerRadius: 8.0);
  }

  /// Whether this is a light or a dark theme, judged by its base surface.
  ///
  /// Drives what the platform draws around the app: the status bar icons and
  /// the keyboard appearance.
  Brightness get brightness => colorScheme.surfaceBase.computeLuminance() < 0.5 ? Brightness.dark : Brightness.light;

  PrimeThemeData copyWith({
    PrimeColorScheme? colorScheme,
    PrimeTextTheme? textTheme,
    double? cornerRadius,
    PrimePageTransitionsTheme? pageTransitionsTheme,
  }) {
    return PrimeThemeData(
      colorScheme: colorScheme ?? this.colorScheme,
      textTheme: textTheme ?? this.textTheme,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      pageTransitionsTheme: pageTransitionsTheme ?? this.pageTransitionsTheme,
    );
  }
}
