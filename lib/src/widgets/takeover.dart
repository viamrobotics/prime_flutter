import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'icon_button.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';

/// A full-screen takeover surface, for flows that need the whole screen such
/// as a setup wizard.
///
/// Show one with [Takeover.show]:
///
/// ```dart
/// Takeover.show<void>(
///   context: context,
///   builder: (context) => const Takeover(
///     header: TakeoverHeader(children: [
///       Expanded(child: TakeoverTitle(child: Text('Setup wizard'))),
///       TakeoverClose(),
///     ]),
///     child: Center(child: Text('Your content here')),
///   ),
/// );
/// ```
class Takeover extends StatelessWidget {
  /// Usually a [TakeoverHeader].
  final Widget? header;

  final Widget child;

  const Takeover({super.key, this.header, required this.child});

  /// Pushes a full-screen route that fades in over the current screen.
  ///
  /// The returned future completes with the value passed to `Navigator.pop`.
  static Future<T?> show<T>({required BuildContext context, required WidgetBuilder builder, bool useRootNavigator = true}) {
    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    final themes = InheritedTheme.capture(from: context, to: navigator.context);
    return navigator.push<T>(
      PageRouteBuilder<T>(
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 150),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, animation, secondaryAnimation) => themes.wrap(EscapeToPop(child: Builder(builder: builder))),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: ColoredBox(
        color: theme.colorScheme.surfaceBase,
        child: SafeArea(
          child: DefaultTextStyle(
            style: theme.textTheme.bodyDefault,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ?header,
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The bar across the top of a [Takeover].
class TakeoverHeader extends StatelessWidget {
  final List<Widget> children;

  const TakeoverHeader({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = PrimeTheme.of(context).colorScheme;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      child: Row(children: children),
    );
  }
}

/// The title inside a [TakeoverHeader].
class TakeoverTitle extends StatelessWidget {
  final Widget child;

  const TakeoverTitle({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Semantics(
      header: true,
      child: DefaultTextStyle(
        style: theme.textTheme.bodyDefault.copyWith(fontWeight: FontWeight.w600, height: 1.2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: child,
      ),
    );
  }
}

/// A close button for a [TakeoverHeader]. Pops the takeover route unless
/// [onClose] is given.
class TakeoverClose extends StatelessWidget {
  final VoidCallback? onClose;

  const TakeoverClose({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(PrimeIcons.close),
      label: 'Close',
      showTooltip: false,
      variant: IconButtonVariant.ghost,
      onPressed: onClose ?? () => Navigator.of(context).maybePop(),
    );
  }
}
