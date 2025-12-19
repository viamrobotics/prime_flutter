import 'package:flutter/widgets.dart';

import '../theme/prime_color_scheme.dart';
import '../theme/prime_theme.dart';

enum BadgeVariant { success, danger, warning, info, neutral }

/// A simple Badge widget. Used for labeling items with status or type.
class Badge extends StatelessWidget {
  /// The content to display in the badge.
  final Widget child;

  /// The variant of the badge. Defaults to [BadgeVariant.neutral].
  final BadgeVariant variant;

  /// Whether to show the background color of the badge. Defaults to true.
  final bool showBackground;

  /// The icon to display in the badge. Defaults to null.
  final Widget? icon;

  const Badge({super.key, required this.child, this.variant = BadgeVariant.neutral, this.icon, this.showBackground = true});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final colors = _getColors(variant, theme.colorScheme);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: showBackground ? BoxDecoration(color: colors.backgroundColor, borderRadius: BorderRadius.circular(4)) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                IconTheme(
                  data: IconThemeData(size: 18, color: colors.foregroundColor),
                  child: icon!,
                ),
              if (icon != null) const SizedBox(width: 8),
              DefaultTextStyle(
                style: theme.textTheme.label.copyWith(color: colors.foregroundColor),
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }

  ({Color backgroundColor, Color foregroundColor}) _getColors(BadgeVariant variant, PrimeColorScheme colorScheme) {
    switch (variant) {
      case BadgeVariant.success:
        return (backgroundColor: colorScheme.statusSuccessLight, foregroundColor: colorScheme.statusSuccessDark);
      case BadgeVariant.danger:
        return (backgroundColor: colorScheme.statusDangerLight, foregroundColor: colorScheme.statusDangerDark);
      case BadgeVariant.warning:
        return (backgroundColor: colorScheme.statusWarningLight, foregroundColor: colorScheme.statusWarningDark);
      case BadgeVariant.info:
        return (backgroundColor: colorScheme.statusInfoLight, foregroundColor: colorScheme.statusInfoDark);
      case BadgeVariant.neutral:
        return (backgroundColor: colorScheme.surfaceHighlight, foregroundColor: colorScheme.textSecondary);
    }
  }
}
