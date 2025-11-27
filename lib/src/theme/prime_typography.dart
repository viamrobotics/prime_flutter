import 'package:flutter/widgets.dart';
import 'prime_colors.dart';

class PrimeTypography {
  PrimeTypography._();

  static const TextStyle heading = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: PrimeColors.textHeading, height: 1.2);

  static const TextStyle title = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: PrimeColors.textHeading, height: 1.3);

  static const TextStyle bodyDefault = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: PrimeColors.textDefault, height: 1.5);

  static const TextStyle bodySmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: PrimeColors.textDefault, height: 1.5);

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontFamily: 'RobotoMono',
    package: 'prime_flutter',
    fontWeight: FontWeight.w700,
    color: PrimeColors.textSubtle1,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle link = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PrimeColors.textLink,
    decoration: TextDecoration.underline,
  );
}
