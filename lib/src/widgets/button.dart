import 'package:flutter/widgets.dart';

import '../theme/prime_color_scheme.dart';
import '../theme/prime_theme.dart';

enum ButtonVariant { primary, secondary, ghost, danger, outlineDanger, success }

/// A button widget. With different variants for different use cases.
class Button extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Widget? icon;
  final bool disabled;
  final bool fullWidth;

  const Button({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.secondary,
    this.icon,
    this.disabled = false,
    this.fullWidth = false,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final colors = _getColors(theme.colorScheme);
        final cornerRadius = theme.cornerRadius;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              if (!widget.disabled) setState(() => _isPressed = true);
            },
            onTapUp: (_) {
              if (!widget.disabled) setState(() => _isPressed = false);
            },
            onTapCancel: () {
              if (!widget.disabled) setState(() => _isPressed = false);
            },
            onTap: widget.disabled ? null : widget.onPressed,
            child: AnimatedContainer(
              width: widget.fullWidth ? double.infinity : null,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colors.backgroundColor,
                borderRadius: BorderRadius.circular(cornerRadius),
                border: colors.borderColor != null ? Border.all(color: colors.borderColor!, width: 1) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    IconTheme(
                      data: IconThemeData(size: 18, color: colors.foregroundColor),
                      child: widget.icon!,
                    ),
                    if (widget.label.isNotEmpty) const SizedBox(width: 6),
                  ],
                  if (widget.label.isNotEmpty)
                    Text(
                      widget.label,
                      style: theme.textTheme.bodyDefault.copyWith(color: colors.foregroundColor, fontWeight: FontWeight.w600, height: 1.0),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // TODO cp - 12/19/2025 - this feels very messy and there are magic colors. investigate how to clean up.
  ({Color backgroundColor, Color foregroundColor, Color? borderColor}) _getColors(PrimeColorScheme colorScheme) {
    if (widget.disabled) {
      return (backgroundColor: colorScheme.surfaceHighlight, foregroundColor: colorScheme.textPlaceholder, borderColor: null);
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        final base = colorScheme.actionPrimaryBg;
        return (
          backgroundColor: _isPressed
              ? Color.lerp(base, const Color(0xFFFFFFFF), 0.4)! // Lighten by 40% on press
              : _isHovered
              ? Color.lerp(base, const Color(0xFFFFFFFF), 0.2)! // Lighten by 20% on hover
              : base,
          foregroundColor: colorScheme.actionPrimaryFg,
          borderColor: colorScheme.borderSubtle,
        );
      case ButtonVariant.secondary:
        return (
          backgroundColor: _isPressed
              ? colorScheme.surfaceHighlight
              : _isHovered
              ? colorScheme.surfaceOffset
              : colorScheme.actionNeutralBg,
          foregroundColor: colorScheme.textPrimary,
          borderColor: colorScheme.borderSubtle,
        );
      case ButtonVariant.ghost:
        return (
          backgroundColor: _isPressed
              ? colorScheme.surfaceHighlight
              : _isHovered
              ? colorScheme.surfaceOffset
              : const Color(0x00000000),
          foregroundColor: colorScheme.textPrimary, // Match secondary text color
          borderColor: null,
        );
      case ButtonVariant.danger:
        final base = colorScheme.statusDangerBg;
        return (
          backgroundColor: _isPressed
              ? Color.lerp(base, const Color(0xFF000000), 0.2)!
              : _isHovered
              ? Color.lerp(base, const Color(0xFFFFFFFF), 0.2)!
              : base,
          foregroundColor: colorScheme.statusDangerFg,
          borderColor: null,
        );
      case ButtonVariant.outlineDanger:
        final base = const Color(0x00000000);
        return (
          backgroundColor: _isPressed
              ? colorScheme.statusDangerBg
              : _isHovered
              ? colorScheme.statusDangerBg.withValues(alpha: 0.5)
              : base,
          foregroundColor: colorScheme.statusDangerFg,
          borderColor: colorScheme.statusDangerFg,
        );
      case ButtonVariant.success:
        final base = colorScheme.statusSuccessFg;
        return (
          backgroundColor: _isPressed
              ? Color.lerp(base, const Color(0xFF000000), 0.2)!
              : _isHovered
              ? Color.lerp(base, const Color(0xFFFFFFFF), 0.2)!
              : base,
          foregroundColor: const Color(0xFFFFFFFF),
          borderColor: null,
        );
    }
  }
}
