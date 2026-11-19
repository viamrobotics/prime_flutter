import 'package:flutter/widgets.dart';

import '../theme/prime_color_scheme.dart';
import '../theme/prime_colors.dart';
import '../theme/prime_theme.dart';
import 'internal/pressable.dart';
import 'progress.dart';
import 'tooltip.dart';

enum IconButtonVariant { primary, secondary, ghost, ghostOutline, danger, dangerFilled, dark }

enum IconButtonSize { medium, large }

/// An icon-only button for user triggered actions.
///
/// ```dart
/// IconButton(
///   icon: const Icon(PrimeIcons.trashCanOutline),
///   label: 'Delete',
///   variant: IconButtonVariant.danger,
///   onPressed: () {},
/// )
/// ```
class IconButton extends StatelessWidget {
  /// The icon shown in the button.
  final Widget icon;

  /// Accessible label. Also shown as a tooltip unless [showTooltip] is false.
  final String? label;

  final VoidCallback? onPressed;

  /// Whether the button rejects taps and renders dimmed.
  final bool disabled;

  final IconButtonVariant variant;

  /// [IconButtonSize.medium] is 36x36, [IconButtonSize.large] is 44x44.
  final IconButtonSize size;

  /// Replaces the icon with a [Progress] spinner.
  final bool loading;

  /// Whether [label] is surfaced as a tooltip.
  final bool showTooltip;

  const IconButton({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.disabled = false,
    this.variant = IconButtonVariant.primary,
    this.size = IconButtonSize.medium,
    this.loading = false,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final dimension = size == IconButtonSize.large ? 44.0 : 36.0;

    Widget button = Pressable(
      disabled: disabled,
      onTap: onPressed,
      semanticLabel: label,
      builder: (context, hovered, pressed) {
        final colors = _colors(theme.colorScheme, hovered, pressed);
        return AnimatedContainer(
          duration: pressed ? Duration.zero : const Duration(milliseconds: 100),
          width: dimension,
          height: dimension,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(theme.cornerRadius),
            border: Border.all(color: colors.border ?? const Color(0x00000000)),
          ),
          child: IconTheme(
            data: IconThemeData(size: 20, color: colors.foreground),
            child: loading ? Progress(color: colors.foreground) : icon,
          ),
        );
      },
    );

    if (label != null && showTooltip && !disabled) {
      button = Tooltip(message: label, hoverDelay: const Duration(milliseconds: 500), child: button);
    }
    return button;
  }

  ({Color background, Color foreground, Color? border}) _colors(PrimeColorScheme c, bool hovered, bool pressed) {
    const transparent = Color(0x00000000);
    Color scrim(Color base, [Color tint = const Color(0xFF000000)]) {
      if (pressed) return Color.alphaBlend(tint.withValues(alpha: 0.16), base);
      if (hovered) return Color.alphaBlend(tint.withValues(alpha: 0.08), base);
      return base;
    }

    if (disabled) {
      final filled = variant == IconButtonVariant.secondary || variant == IconButtonVariant.dangerFilled || variant == IconButtonVariant.dark;
      return (background: filled ? c.surfaceHighlight : transparent, foreground: c.iconDisabled, border: null);
    }

    switch (variant) {
      case IconButtonVariant.primary:
        return (
          background: pressed ? c.surfaceHighlight : (hovered ? c.surfaceHover : transparent),
          foreground: hovered || pressed ? c.textTertiary : c.iconSecondary,
          border: null,
        );
      case IconButtonVariant.ghost:
        return (background: scrim(transparent), foreground: c.textPrimary, border: null);
      case IconButtonVariant.secondary:
        return (
          background: pressed ? c.surfaceHighlight : (hovered ? c.surfaceHover : c.actionNeutralBg),
          foreground: c.textTertiary,
          border: c.borderSubtle,
        );
      case IconButtonVariant.ghostOutline:
        return (background: scrim(transparent), foreground: hovered || pressed ? c.textSecondary : c.iconSecondary, border: c.borderSubtle);
      case IconButtonVariant.danger:
        return (
          background: scrim(transparent, c.statusDangerDark),
          foreground: hovered || pressed ? c.statusDangerDark : c.iconSecondary,
          border: null,
        );
      case IconButtonVariant.dangerFilled:
        return (
          background: scrim(c.statusDangerLight, c.statusDangerDark),
          foreground: c.statusDangerDark,
          border: PrimeColors.dangerMedium,
        );
      case IconButtonVariant.dark:
        return (
          background: pressed ? PrimeColors.black : (hovered ? PrimeColors.gray9_5 : c.actionPrimaryBg),
          foreground: c.actionPrimaryFg,
          border: null,
        );
    }
  }
}
