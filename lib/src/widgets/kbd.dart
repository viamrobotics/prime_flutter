import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';

enum KbdVariant { light, dark }

/// A keyboard shortcut indicator.
///
/// ```dart
/// KbdGroup(children: [
///   Kbd(child: Icon(PrimeIcons.appleKeyboardCommand)),
///   Kbd(child: Text('S')),
/// ])
/// ```
class Kbd extends StatelessWidget {
  final Widget child;

  /// Use [KbdVariant.dark] when placed on a dark background.
  final KbdVariant variant;

  const Kbd({super.key, required this.child, this.variant = KbdVariant.light});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final isDark = variant == KbdVariant.dark;
    final foreground = isDark ? theme.colorScheme.textInversePrimary.withValues(alpha: 0.6) : theme.colorScheme.textTertiary;
    final border = isDark ? theme.colorScheme.textInversePrimary.withValues(alpha: 0.2) : theme.colorScheme.iconDisabled;

    return Container(
      height: 18,
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: border),
      ),
      child: IconTheme(
        data: IconThemeData(size: 11, color: foreground),
        child: DefaultTextStyle(
          style: theme.textTheme.bodySmall.copyWith(fontSize: 11, height: 1, color: foreground),
          child: child,
        ),
      ),
    );
  }
}

/// Groups multiple [Kbd] elements with consistent spacing.
class KbdGroup extends StatelessWidget {
  final List<Widget> children;

  const KbdGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, spacing: 2, children: children);
  }
}
