import 'package:flutter/widgets.dart';
import 'prime_colors.dart';

class PrimeTypography {
  PrimeTypography._();

  static const TextStyle heading = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: PrimeColors.gray9, height: 1.2);

  static const TextStyle title = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: PrimeColors.gray9, height: .8);

  static const TextStyle bodyDefault = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: PrimeColors.gray9);

  static const TextStyle bodySmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: PrimeColors.gray9, height: 1.5);

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontFamily: 'RobotoMono',
    package: 'prime_flutter',
    fontWeight: FontWeight.w700,
    color: PrimeColors.gray7,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle link = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PrimeColors.focusBlue,
    decoration: TextDecoration.underline,
  );
}
