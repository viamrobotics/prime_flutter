import 'package:flutter/widgets.dart';
import 'prime_colors.dart';

class PrimeTypography {
  PrimeTypography._();

  /// The family of the Public Sans typeface this package bundles. Use it with `package: fontPackage`.
  static const String fontFamily = 'Public Sans';

  /// The package [fontFamily] is loaded from.
  static const String fontPackage = 'prime_flutter';

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: PrimeColors.gray9,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: PrimeColors.gray9,
    height: .8,
  );

  static const TextStyle bodyDefault = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PrimeColors.gray9,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: PrimeColors.gray9,
    height: 1.5,
  );

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
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PrimeColors.focusBlue,
    decoration: TextDecoration.underline,
  );
}
