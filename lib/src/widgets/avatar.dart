import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

/// An avatar widget that can be used to display an icon or text in a circular shape.
///
/// Pass [onPressed] to make the avatar interactive — it will darken on hover and
/// press, and show a click cursor on web/desktop.
class Avatar extends StatefulWidget {
  /// The child widget to display in the avatar.
  final Widget child;

  /// The size of the avatar. Defaults to 32.0.
  final double size;

  /// The background color of the avatar. Defaults to [PrimeColorScheme.surfaceHighlight].
  final Color? backgroundColor;

  /// The foreground color of the avatar. Defaults to [PrimeColorScheme.textTertiary].
  final Color? foregroundColor;

  /// Optional tap callback. When non-null, the avatar becomes interactive with
  /// hover and press animations.
  final VoidCallback? onPressed;

  const Avatar({
    super.key,
    required this.child,
    this.size = 32.0,
    this.backgroundColor,
    this.foregroundColor,
    this.onPressed,
  });

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final effectiveBackgroundColor = widget.backgroundColor ?? theme.colorScheme.surfaceHighlight;
        final effectiveForegroundColor = widget.foregroundColor ?? theme.colorScheme.textTertiary;
        final isInteractive = widget.onPressed != null;

        Color resolveBackground() {
          if (!isInteractive) return effectiveBackgroundColor;
          if (_isPressed) {
            return Color.alphaBlend(const Color(0xFF000000).withValues(alpha: 0.2), effectiveBackgroundColor);
          }
          if (_isHovered) {
            return Color.alphaBlend(const Color(0xFF000000).withValues(alpha: 0.1), effectiveBackgroundColor);
          }
          return effectiveBackgroundColor;
        }

        final avatar = AnimatedContainer(
          width: widget.size,
          height: widget.size,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: resolveBackground(), shape: BoxShape.circle),
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: 'RobotoMono',
              package: 'prime_flutter',
              fontWeight: FontWeight.w400,
              fontSize: widget.size * 0.45,
              color: effectiveForegroundColor,
            ),
            child: widget.child,
          ),
        );

        if (!isInteractive) return avatar;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onPressed,
            child: avatar,
          ),
        );
      },
    );
  }
}
