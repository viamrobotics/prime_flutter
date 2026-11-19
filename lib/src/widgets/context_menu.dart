import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'floating.dart';
import 'internal/pressable.dart';

enum ContextMenuItemVariant { primary, danger }

/// A simple list menu, usually shown from a [FloatingMenu].
///
/// ```dart
/// ContextMenu(
///   children: [
///     ContextMenuItem(icon: PrimeIcons.pencilOutline, onTap: rename, child: const Text('Rename')),
///     const ContextMenuSeparator(),
///     ContextMenuItem(
///       icon: PrimeIcons.trashCanOutline,
///       variant: ContextMenuItemVariant.danger,
///       onTap: delete,
///       child: const Text('Delete'),
///     ),
///   ],
/// )
/// ```
class ContextMenu extends StatelessWidget {
  final List<Widget> children;

  /// Accessible label of the menu.
  final String? label;

  const ContextMenu({super.key, required this.children, this.label});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final radius = BorderRadius.circular(theme.cornerRadius);
    return Semantics(
      container: true,
      label: label,
      child: Container(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 320),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceBase,
          borderRadius: radius,
          border: Border.all(color: theme.colorScheme.iconDisabled),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: IntrinsicWidth(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable item within a [ContextMenu].
class ContextMenuItem extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  final ContextMenuItemVariant variant;
  final VoidCallback? onTap;
  final bool disabled;

  const ContextMenuItem({
    super.key,
    required this.child,
    this.icon,
    this.variant = ContextMenuItemVariant.primary,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final isDanger = variant == ContextMenuItemVariant.danger;
    final textColor = disabled ? c.textPlaceholder : (isDanger ? c.statusDangerDark : c.textPrimary);
    final iconColor = disabled ? c.iconDisabled : (isDanger ? c.statusDangerDark : c.iconSecondary);

    return Pressable(
      disabled: disabled,
      onTap: onTap,
      builder: (context, hovered, pressed) => Container(
        color: pressed ? c.surfaceHighlight : (hovered ? c.surfaceHover : null),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 18, color: iconColor), const SizedBox(width: 8)],
            Flexible(
              child: DefaultTextStyle(
                style: theme.textTheme.bodySmall.copyWith(height: 1.3, color: textColor),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontal divider within a [ContextMenu].
class ContextMenuSeparator extends StatelessWidget {
  const ContextMenuSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.symmetric(vertical: 4), height: 1, color: PrimeTheme.of(context).colorScheme.borderSubtle);
  }
}

/// A control that toggles a [ContextMenu] anchored to it.
///
/// The open state is controlled by the parent, so an item can close the menu:
///
/// ```dart
/// FloatingMenu(
///   isOpen: isOpen,
///   onChange: (open) => setState(() => isOpen = open),
///   control: const Icon(PrimeIcons.dotsHorizontal),
///   items: [
///     ContextMenuItem(
///       onTap: () {
///         setState(() => isOpen = false);
///         rename();
///       },
///       child: const Text('Rename'),
///     ),
///   ],
/// )
/// ```
class FloatingMenu extends StatelessWidget {
  final bool isOpen;
  final ValueChanged<bool> onChange;

  /// The widget that toggles the menu when tapped.
  final Widget control;

  /// The menu contents, typically [ContextMenuItem]s.
  final List<Widget> items;

  /// Accessible label for the control.
  final String? label;

  final FloatingPlacement placement;

  /// Gap between the control and the menu.
  final double offset;

  const FloatingMenu({
    super.key,
    required this.isOpen,
    required this.onChange,
    required this.control,
    required this.items,
    this.label,
    this.placement = FloatingPlacement.bottomStart,
    this.offset = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Floating(
      visible: isOpen,
      placement: placement,
      offset: offset,
      onTapOutside: () => onChange(false),
      onEscape: () => onChange(false),
      floatingBuilder: (context) => ContextMenu(children: items),
      child: Semantics(
        button: true,
        expanded: isOpen,
        label: label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TapListener(onTap: () => onChange(!isOpen), child: control),
        ),
      ),
    );
  }
}
