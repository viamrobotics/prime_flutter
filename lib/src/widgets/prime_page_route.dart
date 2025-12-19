import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A page route that provides platform-adaptive transitions.
///
/// On iOS and macOS, it uses a slide transition from the right.
/// On other platforms, it uses a fade/zoom transition.
class PrimePageRoute<T> extends PageRoute<T> {
  PrimePageRoute({
    required this.builder,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
  });

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (kIsWeb) {
      return _buildMaterialTransition(context, animation, secondaryAnimation, child);
    }

    if (Platform.isMacOS || Platform.isIOS) {
      return _buildCupertinoTransition(context, animation, secondaryAnimation, child);
    }

    return _buildMaterialTransition(context, animation, secondaryAnimation, child);
  }

  Widget _buildCupertinoTransition(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
      },
    );
    return theme.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }

  Widget _buildMaterialTransition(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: const ZoomPageTransitionsBuilder(),
        TargetPlatform.fuchsia: const ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: const ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: const ZoomPageTransitionsBuilder(),
      },
    );
    return theme.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}

/// A page that creates a [PrimePageRoute].
///
/// Useful for using Prime transitions with declarative routers like `go_router`.
class PrimePage<T> extends Page<T> {
  const PrimePage({required this.child, super.key, super.name, super.arguments, super.restorationId});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PrimePageRoute<T>(settings: this, builder: (BuildContext context) => child);
  }
}
