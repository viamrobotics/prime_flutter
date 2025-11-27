import 'package:flutter/widgets.dart';
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
}
