import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

/// An avatar widget that can be used to display an icon or text in a circular shape.
class Avatar extends StatelessWidget {
  /// The child widget to display in the avatar.
  final Widget child;

  /// The size of the avatar. Defaults to 32.0.
  final double size;

  /// The background color of the avatar. Defaults to [PrimeColorScheme.bgMedium].
  final Color? backgroundColor;

  /// The foreground color of the avatar. Defaults to [PrimeColorScheme.textDefault].
  final Color? foregroundColor;

  const Avatar({super.key, required this.child, this.size = 32.0, this.backgroundColor, this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.surfaceHighlight;
        final effectiveForegroundColor = foregroundColor ?? theme.colorScheme.textTertiary;

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
