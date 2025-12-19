import 'prime_color_scheme.dart';
import 'prime_text_theme.dart';

class PrimeThemeData {
  final PrimeColorScheme colorScheme;
  final PrimeTextTheme textTheme;
  final double cornerRadius;

  const PrimeThemeData({required this.colorScheme, required this.textTheme, required this.cornerRadius});

  factory PrimeThemeData.light() {
    final scheme = PrimeColorScheme.light();
    return PrimeThemeData(colorScheme: scheme, textTheme: PrimeTextTheme.withColorScheme(scheme), cornerRadius: 8.0);
  }
}
