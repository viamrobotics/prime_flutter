import 'package:flutter/widgets.dart';

import '../theme/prime_color_scheme.dart';
import '../theme/prime_theme.dart';

enum ButtonVariant { primary, secondary, ghost, danger, outlineDanger, success }

/// A button widget. With different variants for different use cases.
///
/// The [Button] widget provides a clickable element that can be configured with
/// different variants, icons, and states.
///
/// ## Variants
///
/// The [Button] comes in several variants:
/// - [ButtonVariant.primary]: For the main action on a screen.
/// - [ButtonVariant.secondary]: For alternative actions.
/// - [ButtonVariant.ghost]: For less prominent actions.
/// - [ButtonVariant.danger]: For destructive actions.
/// - [ButtonVariant.outlineDanger]: For less prominent destructive actions.
/// - [ButtonVariant.success]: For positive actions.
///
/// ## Examples
///
/// ### Basic Usage
///
/// ```dart
/// Button(
///   label: const Text('Click Me'),
///   onPressed: () {
///     print('Button clicked');
///   },
/// )
/// ```
///
/// ### With Icon
///
/// ```dart
/// Button(
///   label: const Text('Add Item'),
///   icon: const Icon(PrimeIcons.plus),
///   onPressed: () {},
///   variant: ButtonVariant.primary,
/// )
/// ```
///
/// ### Full Width
///
/// ```dart
/// Button(
///   label: const Text('Submit'),
///   fullWidth: true,
///   onPressed: () {},
///   variant: ButtonVariant.primary,
/// )
/// ```
///
/// ### Disabled State
///
/// ```dart
/// Button(
///   label: const Text('Disabled'),
///   disabled: true,
///   onPressed: () {},
/// )
/// ```
///
/// ### Loading State
///
/// ```dart
/// Button(
///   label: const Text('Loading...'),
///   icon: const Progress(),
///   onPressed: null,
/// )
/// ```
class Button extends StatefulWidget {
  final Widget? label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Widget? icon;
  final bool disabled;
  final bool fullWidth;

  const Button({
    super.key,
    this.label,
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
            child: SizedBox(
              height: 44.0,
              child: AnimatedContainer(
                width: widget.fullWidth ? double.infinity : null,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      if (widget.label != null) const SizedBox(width: 6),
                    ],
                    if (widget.label != null)
                      DefaultTextStyle(
                        style: theme.textTheme.bodyDefault.copyWith(
                          color: colors.foregroundColor,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                        child: widget.label!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ({Color backgroundColor, Color foregroundColor, Color? borderColor}) _getColors(PrimeColorScheme colorScheme) {
    final defaultDisabled = (
      backgroundColor: colorScheme.surfaceHighlight,
      foregroundColor: colorScheme.textPlaceholder,
      borderColor: null,
    );

    // Standard hover overlay: 10% black scrim
    Color withHover(Color base) {
      if (!_isHovered) return base;

      // Primary buttons should be fully black
      if (widget.variant == ButtonVariant.primary) {
        return const Color(0xFF000000);
      }

      // Outline danger buttons should be dark red
      if (widget.variant == ButtonVariant.outlineDanger) {
        return Color.alphaBlend(const Color.fromARGB(255, 132, 0, 0).withValues(alpha: 0.1), base);
      }
      return Color.alphaBlend(const Color(0xFF000000).withValues(alpha: 0.1), base);
    }

    // Standard press overlay: 20% black scrim (keeping consistent with darkening request, though original was lightening)
    // Actually, user only specified hover to be standard. I will assume they want press to be consistent or similar.
    // The original code Lightened on press. I should probably switch press to darken as well for consistency,
    // or keep it if they didn't ask.
    // "move to that direction for every button variant that makes sense" implies the "scrim" approach.
    // I'll stick to the "scrim" approach for press too, maybe 20%?
    Color withPress(Color base) {
      if (!_isPressed) return base;

      // Primary buttons should be fully black (same as withHover for primary)
      if (widget.variant == ButtonVariant.primary) {
        return const Color(0xFF000000);
      }

      // Outline danger buttons should be dark red
      if (widget.variant == ButtonVariant.outlineDanger) {
        return Color.alphaBlend(const Color.fromARGB(255, 132, 0, 0).withValues(alpha: 0.2), base);
      }

      return Color.alphaBlend(const Color(0xFF000000).withValues(alpha: 0.2), base);
    }

    Color resolve(Color base) {
      if (_isPressed) return withPress(base);
      if (_isHovered) return withHover(base);
      return base;
    }

    switch (widget.variant) {
      case ButtonVariant.primary:
        if (widget.disabled) return defaultDisabled;
        final base = colorScheme.actionPrimaryBg;
        return (backgroundColor: resolve(base), foregroundColor: colorScheme.actionPrimaryFg, borderColor: colorScheme.borderSubtle);
      case ButtonVariant.secondary:
        if (widget.disabled) return defaultDisabled;
        final base = colorScheme.actionNeutralBg;
        return (backgroundColor: resolve(base), foregroundColor: colorScheme.textPrimary, borderColor: colorScheme.borderSubtle);
      case ButtonVariant.ghost:
        if (widget.disabled) {
          return (backgroundColor: const Color(0x00000000), foregroundColor: colorScheme.textPlaceholder, borderColor: null);
        }
        // Ghost starts transparent.
        // Hover: transparent + 10% black = 10% black.
        // Press: transparent + 20% black = 20% black.
        return (
          backgroundColor: resolve(const Color(0x00000000)),
          foregroundColor: colorScheme.textPrimary, // Match secondary text color
          borderColor: null,
        );
      case ButtonVariant.danger:
        if (widget.disabled) return defaultDisabled;
        final base = colorScheme.statusDangerDark;
        return (backgroundColor: resolve(base), foregroundColor: colorScheme.actionPrimaryFg, borderColor: null);
      case ButtonVariant.outlineDanger:
        if (widget.disabled) return defaultDisabled;
        final base = colorScheme.statusDangerLight;
        return (backgroundColor: resolve(base), foregroundColor: colorScheme.statusDangerDark, borderColor: colorScheme.statusDangerDark);
      case ButtonVariant.success:
        if (widget.disabled) return defaultDisabled;
        final base = colorScheme.statusSuccessDark;
        return (backgroundColor: resolve(base), foregroundColor: const Color(0xFFFFFFFF), borderColor: null);
    }
  }
}
