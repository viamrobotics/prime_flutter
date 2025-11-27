import 'prime_color_scheme.dart';
import 'prime_text_theme.dart';

class PrimeThemeData {
  final PrimeColorScheme colorScheme;
  final PrimeTextTheme textTheme;
  final double cornerRadius;

  const PrimeThemeData({required this.colorScheme, required this.textTheme, required this.cornerRadius});

  factory PrimeThemeData.light() {
    return PrimeThemeData(colorScheme: PrimeColorScheme.light(), textTheme: PrimeTextTheme.base(), cornerRadius: 8.0);
  }
}
