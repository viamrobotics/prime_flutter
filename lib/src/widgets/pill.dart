import 'package:flutter/widgets.dart';

import '../theme/prime_colors.dart';
import '../theme/prime_theme.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';
import 'progress.dart';
import 'tooltip.dart';

enum PillVariant { base, dark, info, warning }

/// A compact token for displaying one item of a list, optionally removable.
///
/// For a selectable filter chip, use [FilterPill] instead.
///
/// ```dart
/// Pill(value: 'Chocolate chip', onRemove: (value) => remove(value))
/// ```
class Pill extends StatelessWidget {
  /// The text in the pill.
  final String value;

  final PillVariant variant;

  /// When set, the text behaves as a link.
  final VoidCallback? onTap;

  /// A readonly pill has no remove button.
  final bool readOnly;

  final bool disabled;

  /// Whether to show a remove button (when not [readOnly]).
  final bool removable;

  /// Optional leading icon. Gives the pill an outlined look.
  final IconData? icon;

  /// Tooltip for [icon].
  final String? iconTooltip;

  final Color? iconColor;

  final ValueChanged<String>? onRemove;

  const Pill({
    super.key,
    required this.value,
    this.variant = PillVariant.base,
    this.onTap,
    this.readOnly = false,
    this.disabled = false,
    this.removable = true,
    this.icon,
    this.iconTooltip,
    this.iconColor,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final hasIcon = icon != null;

    Color background = hasIcon ? c.surfaceOffset : c.surfaceHover;
    Color? border = hasIcon ? c.borderSubtle : null;
    Color foreground = c.textPrimary;
    Color removeColor = c.iconSecondary;
    Color removeHover = c.textPrimary;

    switch (variant) {
      case PillVariant.base:
        break;
      case PillVariant.dark:
        if (hasIcon) {
          background = PrimeColors.gray7;
          border = PrimeColors.gray8;
          foreground = PrimeColors.gray0;
        }
        removeColor = hasIcon ? PrimeColors.gray2 : removeColor;
        removeHover = hasIcon ? PrimeColors.gray0 : removeHover;
      case PillVariant.info:
        background = c.statusInfoLight;
        border = PrimeColors.infoMedium;
        foreground = c.statusInfoDark;
        removeColor = c.statusInfoDark;
        removeHover = PrimeColors.infoMedium;
      case PillVariant.warning:
        background = c.statusWarningLight;
        border = PrimeColors.warningMedium;
        foreground = c.statusWarningDark;
        removeColor = c.statusWarningDark;
        removeHover = PrimeColors.warningMedium;
    }
    if (disabled || readOnly) {
      background = c.surfaceHighlight;
      foreground = c.textPlaceholder;
    }

    final textStyle = theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, color: foreground);
    Widget? leading;
    if (hasIcon) {
      leading = Icon(icon, size: 14, color: iconColor ?? (variant == PillVariant.dark ? PrimeColors.gray0 : c.iconSecondary));
      if (iconTooltip != null) leading = Tooltip(message: iconTooltip, child: leading);
    }

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : MouseCursor.defer,
      child: Container(
        constraints: BoxConstraints(minHeight: hasIcon ? 24 : 0),
        padding: EdgeInsets.fromLTRB(hasIcon ? 6 : 8, 2, 8, 2),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(4),
          border: border != null ? Border.all(color: border) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 6)],
            Flexible(
              child: GestureDetector(
                onTap: disabled ? null : onTap,
                child: MouseRegion(
                  cursor: onTap != null && !disabled ? SystemMouseCursors.click : MouseCursor.defer,
                  child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: textStyle),
                ),
              ),
            ),
            if (!readOnly && removable) ...[
              const SizedBox(width: 4),
              Pressable(
                disabled: disabled,
                semanticLabel: 'Remove $value',
                onTap: onRemove == null ? null : () => onRemove!(value),
                builder: (context, hovered, pressed) => Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(PrimeIcons.close, size: 12, color: hovered ? removeHover : removeColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum StatusPillVariant { success, warning, danger, inactive }

/// A small uppercase status indicator with a colored dot.
///
/// ```dart
/// StatusPill(label: 'Live', variant: StatusPillVariant.success)
/// ```
class StatusPill extends StatelessWidget {
  final String label;
  final StatusPillVariant variant;

  /// Optional tooltip shown on hover or long press.
  final String? tooltip;

  /// Replaces the dot with a spinner, for in-flight states.
  final bool loading;

  const StatusPill({super.key, required this.label, required this.variant, this.tooltip, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;

    final Color background, border, foreground, dot;
    switch (variant) {
      case StatusPillVariant.success:
        (background, border, foreground, dot) = (c.statusSuccessLight, PrimeColors.successMedium, c.statusSuccessDark, c.statusSuccessDark);
      case StatusPillVariant.warning:
        (background, border, foreground, dot) = (c.statusWarningLight, PrimeColors.warningMedium, c.statusWarningDark, PrimeColors.warningBright);
      case StatusPillVariant.danger:
        (background, border, foreground, dot) = (c.statusDangerLight, PrimeColors.dangerMedium, c.statusDangerDark, c.statusDangerDark);
      case StatusPillVariant.inactive:
        (background, border, foreground, dot) = (c.surfaceOffset, c.borderSubtle, c.textSecondary, c.iconSecondary);
    }

    final pill = Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            Progress(size: 10, color: foreground)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.label.copyWith(fontSize: 11, fontWeight: FontWeight.w400, height: 1, letterSpacing: 0.6, color: foreground),
          ),
        ],
      ),
    );

    if (tooltip == null) return pill;
    return Tooltip(message: tooltip, hoverDelay: const Duration(milliseconds: 500), child: pill);
  }
}
