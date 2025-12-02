import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

class Avatar extends StatelessWidget {
  final Widget child;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const Avatar({super.key, required this.child, this.size = 32.0, this.backgroundColor, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.bgMedium;
        final effectiveForegroundColor = foregroundColor ?? theme.colorScheme.textDefault;

        return Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: effectiveBackgroundColor, shape: BoxShape.circle),
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: 'RobotoMono',
              package: 'prime_flutter',
              fontWeight: FontWeight.w400,
              fontSize: size * 0.45, // Approximate font size relative to avatar size
              color: effectiveForegroundColor,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
