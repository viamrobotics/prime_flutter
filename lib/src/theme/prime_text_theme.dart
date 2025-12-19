import 'package:flutter/widgets.dart';

import 'prime_color_scheme.dart';
import 'prime_typography.dart';

class PrimeTextTheme {
  final TextStyle heading;
  final TextStyle title;
  final TextStyle bodyDefault;
  final TextStyle bodySmall;
  final TextStyle label;
  final TextStyle link;

  const PrimeTextTheme({
    required this.heading,
    required this.title,
    required this.bodyDefault,
    required this.bodySmall,
    required this.label,
    required this.link,
  });

  factory PrimeTextTheme.base() {
    return const PrimeTextTheme(
      heading: PrimeTypography.heading,
      title: PrimeTypography.title,
      bodyDefault: PrimeTypography.bodyDefault,
      bodySmall: PrimeTypography.bodySmall,
      label: PrimeTypography.label,
      link: PrimeTypography.link,
    );
  }

  factory PrimeTextTheme.withColorScheme(PrimeColorScheme c) {
    return PrimeTextTheme(
      heading: PrimeTypography.heading.copyWith(color: c.textPrimary),
      title: PrimeTypography.title.copyWith(color: c.textPrimary),
      bodyDefault: PrimeTypography.bodyDefault.copyWith(color: c.textPrimary),
      bodySmall: PrimeTypography.bodySmall.copyWith(color: c.textPrimary),
      label: PrimeTypography.label.copyWith(color: c.textTertiary),
      link: PrimeTypography.link.copyWith(color: c.inputFocus),
    );
  }
}
