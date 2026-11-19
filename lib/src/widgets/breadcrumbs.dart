import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';

/// A compact, non-interactive trail showing where an item sits in a hierarchy.
///
/// For tappable navigation, use [NavigationBreadcrumb].
///
/// ```dart
/// Breadcrumbs(crumbs: ['Dessert', 'Cookie'])
/// ```
class Breadcrumbs extends StatelessWidget {
  /// Each part of the trail, outermost first.
  final List<String> crumbs;

  final bool disabled;

  const Breadcrumbs({super.key, required this.crumbs, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final style = theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, color: disabled ? c.textPlaceholder : c.textPrimary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: c.surfaceOffset,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < crumbs.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(PrimeIcons.chevronRight, size: 14, color: c.iconDisabled),
              ),
            Flexible(child: Text(crumbs[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
          ],
        ],
      ),
    );
  }
}

/// Hierarchical navigation built from links, a current page, and separators.
///
/// ```dart
/// NavigationBreadcrumb(
///   children: [
///     NavigationBreadcrumbLink(onTap: goHome, child: const Text('Fleet')),
///     const NavigationBreadcrumbSeparator(),
///     const NavigationBreadcrumbEllipsis(),
///     const NavigationBreadcrumbSeparator(),
///     const NavigationBreadcrumbPage(child: Text('arm-1')),
///   ],
/// )
/// ```
class NavigationBreadcrumb extends StatelessWidget {
  final List<Widget> children;

  const NavigationBreadcrumb({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Semantics(
      container: true,
      label: 'breadcrumb',
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall.copyWith(height: 1.3, color: theme.colorScheme.textSecondary),
        child: Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: children),
      ),
    );
  }
}

/// A tappable ancestor in a [NavigationBreadcrumb].
class NavigationBreadcrumbLink extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const NavigationBreadcrumbLink({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      builder: (context, hovered, pressed) => AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: DefaultTextStyle.of(context).style.copyWith(color: hovered || pressed ? c.textPrimary : c.textTertiary),
        child: child,
      ),
    );
  }
}

/// The current, non-interactive page in a [NavigationBreadcrumb].
class NavigationBreadcrumbPage extends StatelessWidget {
  final Widget child;

  const NavigationBreadcrumbPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    return Semantics(
      selected: true,
      child: DefaultTextStyle.merge(style: TextStyle(color: c.textPrimary), child: child),
    );
  }
}

/// The divider between [NavigationBreadcrumb] items. Defaults to a chevron.
class NavigationBreadcrumbSeparator extends StatelessWidget {
  final Widget? child;

  const NavigationBreadcrumbSeparator({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    return ExcludeSemantics(
      child: IconTheme(
        data: IconThemeData(size: 14, color: c.iconSecondary),
        child: child ?? const Icon(PrimeIcons.chevronRight),
      ),
    );
  }
}

/// Stands in for collapsed [NavigationBreadcrumb] items.
class NavigationBreadcrumbEllipsis extends StatelessWidget {
  const NavigationBreadcrumbEllipsis({super.key});

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    return ExcludeSemantics(child: Icon(PrimeIcons.dotsHorizontal, size: 14, color: c.iconSecondary));
  }
}
