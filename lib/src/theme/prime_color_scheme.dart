import 'package:flutter/widgets.dart';
import 'prime_colors.dart';

class PrimeColorScheme {
  final Color textHeading;
  final Color textDefault;
  final Color textSubtle1;
  final Color textSubtle2;
  final Color textDisabled;
  final Color textLink;

  final Color bgExtraLight;
  final Color bgLight;
  final Color bgMedium;

  final Color disabledDark;
  final Color disabledLight;

  final Color borderLight;
  final Color borderMedium;

  final Color opacityLight;
  final Color opacityMedium;

  final Color dangerDark;
  final Color dangerLight;
  final Color dangerMedium;

  final Color warningDark;
  final Color warningLight;
  final Color warningMedium;
  final Color warningBright;

  final Color successDark;
  final Color successLight;
  final Color successMedium;

  final Color infoDark;
  final Color infoLight;
  final Color infoMedium;

  final Color black;
  final Color gray9;
  final Color gray8;
  final Color gray7;
  final Color gray6;
  final Color gray5;
  final Color gray4;
  final Color gray3;
  final Color gray2;
  final Color gray1;
  final Color white;

  final Color primary;
  final Color danger;
  final Color success;
  final Color warning;

  const PrimeColorScheme({
    required this.primary,
    required this.danger,
    required this.success,
    required this.warning,
    required this.textHeading,
    required this.textDefault,
    required this.textSubtle1,
    required this.textSubtle2,
    required this.textDisabled,
    required this.textLink,
    required this.bgExtraLight,
    required this.bgLight,
    required this.bgMedium,
    required this.disabledDark,
    required this.disabledLight,
    required this.borderLight,
    required this.borderMedium,
    required this.opacityLight,
    required this.opacityMedium,
    required this.dangerDark,
    required this.dangerLight,
    required this.dangerMedium,
    required this.warningDark,
    required this.warningLight,
    required this.warningMedium,
    required this.warningBright,
    required this.successDark,
    required this.successLight,
    required this.successMedium,
    required this.infoDark,
    required this.infoLight,
    required this.infoMedium,
    required this.black,
    required this.gray9,
    required this.gray8,
    required this.gray7,
    required this.gray6,
    required this.gray5,
    required this.gray4,
    required this.gray3,
    required this.gray2,
    required this.gray1,
    required this.white,
  });

  factory PrimeColorScheme.light() {
    return const PrimeColorScheme(
      primary: PrimeColors.black,
      danger: PrimeColors.dangerDark,
      success: PrimeColors.successDark,
      warning: PrimeColors.warningDark,
      textHeading: PrimeColors.textHeading,
      textDefault: PrimeColors.textDefault,
      textSubtle1: PrimeColors.textSubtle1,
      textSubtle2: PrimeColors.textSubtle2,
      textDisabled: PrimeColors.textDisabled,
      textLink: PrimeColors.textLink,
      bgExtraLight: PrimeColors.bgExtraLight,
      bgLight: PrimeColors.bgLight,
      bgMedium: PrimeColors.bgMedium,
      disabledDark: PrimeColors.disabledDark,
      disabledLight: PrimeColors.disabledLight,
      borderLight: PrimeColors.borderLight,
      borderMedium: PrimeColors.borderMedium,
      opacityLight: PrimeColors.opacityLight,
      opacityMedium: PrimeColors.opacityMedium,
      dangerDark: PrimeColors.dangerDark,
      dangerLight: PrimeColors.dangerLight,
      dangerMedium: PrimeColors.dangerMedium,
      warningDark: PrimeColors.warningDark,
      warningLight: PrimeColors.warningLight,
      warningMedium: PrimeColors.warningMedium,
      warningBright: PrimeColors.warningBright,
      successDark: PrimeColors.successDark,
      successLight: PrimeColors.successLight,
      successMedium: PrimeColors.successMedium,
      infoDark: PrimeColors.infoDark,
      infoLight: PrimeColors.infoLight,
      infoMedium: PrimeColors.infoMedium,
      black: PrimeColors.black,
      gray9: PrimeColors.gray9,
      gray8: PrimeColors.gray8,
      gray7: PrimeColors.gray7,
      gray6: PrimeColors.gray6,
      gray5: PrimeColors.gray5,
      gray4: PrimeColors.gray4,
      gray3: PrimeColors.gray3,
      gray2: PrimeColors.gray2,
      gray1: PrimeColors.gray1,
      white: PrimeColors.white,
    );
  }
}
