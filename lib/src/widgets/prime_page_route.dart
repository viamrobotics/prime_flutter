import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent;
import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';

/// The page transition each platform uses for a [PrimePageRoute].
///
/// Set on `PrimeThemeData.pageTransitionsTheme`. A platform missing from
/// [builders] falls back to the Prime default for it: a slide with an edge
/// back-swipe on iOS, a slide on macOS, and a fade-through everywhere else.
///
/// Any [PageTransitionsBuilder] works here, including the ones that ship in
/// `package:flutter/widgets.dart`:
///
/// ```dart
/// PrimeThemeData.light().copyWith(
///   pageTransitionsTheme: const PrimePageTransitionsTheme(
///     builders: {TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()},
///   ),
/// )
/// ```
@immutable
class PrimePageTransitionsTheme {
  const PrimePageTransitionsTheme({this.builders = const <TargetPlatform, PageTransitionsBuilder>{}});

  /// Overrides for individual platforms.
  final Map<TargetPlatform, PageTransitionsBuilder> builders;

  static const PageTransitionsBuilder _slideWithBackSwipe = PrimeSlidePageTransitionsBuilder();
  static const PageTransitionsBuilder _slide = PrimeSlidePageTransitionsBuilder(backSwipe: false);
  static const PageTransitionsBuilder _fadeThrough = PrimeFadeThroughPageTransitionsBuilder();

  /// The builder for [platform]: the override in [builders] or the Prime default.
  PageTransitionsBuilder builderFor(TargetPlatform platform) {
    return builders[platform] ??
        switch (platform) {
          TargetPlatform.iOS => _slideWithBackSwipe,
          TargetPlatform.macOS => _slide,
          TargetPlatform.android || TargetPlatform.fuchsia || TargetPlatform.linux || TargetPlatform.windows => _fadeThrough,
        };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PrimePageTransitionsTheme && mapEquals(other.builders, builders));
  }

  @override
  int get hashCode => Object.hashAllUnordered(builders.entries.map((e) => Object.hash(e.key, e.value)));
}

/// A page route with platform-adaptive transitions.
///
/// The transition comes from the `pageTransitionsTheme` of the surrounding
/// [PrimeTheme], unless [transitionsBuilder] is given. `PrimeApp` builds its
/// `home` and named `routes` with this route.
class PrimePageRoute<T> extends PageRoute<T> {
  PrimePageRoute({
    required this.builder,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible,
    this.transitionsBuilder,
  });

  final WidgetBuilder builder;

  /// Overrides the transition the theme would pick for this route.
  final PageTransitionsBuilder? transitionsBuilder;

  @override
  final bool maintainState;

  PageTransitionsBuilder get _builder {
    if (transitionsBuilder != null) return transitionsBuilder!;
    final BuildContext? context = navigator?.context;
    final PrimePageTransitionsTheme theme =
        (context != null && context.mounted ? PrimeTheme.maybeOf(context)?.pageTransitionsTheme : null) ??
        const PrimePageTransitionsTheme();
    return theme.builderFor(defaultTargetPlatform);
  }

  @override
  Duration get transitionDuration => _builder.transitionDuration;

  @override
  Duration get reverseTransitionDuration => _builder.reverseTransitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition => _builder.delegatedTransition;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // A page stays put while a fullscreen dialog rises over it.
    return nextRoute is PageRoute && !nextRoute.fullscreenDialog;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Semantics(scopesRoute: true, explicitChildNodes: true, child: builder(context));
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return _builder.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}

/// A page that creates a [PrimePageRoute].
///
/// Use it with declarative routers. With `go_router`, which otherwise shows
/// pages with no transition under a `PrimeApp`:
///
/// ```dart
/// GoRoute(path: '/settings', pageBuilder: (context, state) => PrimePage(key: state.pageKey, child: const SettingsScreen()))
/// ```
class PrimePage<T> extends Page<T> {
  const PrimePage({
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    this.transitionsBuilder,
    super.key,
    super.canPop,
    super.onPopInvoked,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final bool maintainState;
  final bool fullscreenDialog;
  final bool allowSnapshotting;

  /// Overrides the transition the theme would pick for this page.
  final PageTransitionsBuilder? transitionsBuilder;

  @override
  Route<T> createRoute(BuildContext context) => _PrimePageBasedRoute<T>(page: this);
}

// Reads its configuration from the page each time, so that a rebuilt page
// with the same key updates the route in place.
class _PrimePageBasedRoute<T> extends PrimePageRoute<T> {
  _PrimePageBasedRoute({required PrimePage<T> page})
    : super(settings: page, builder: (context) => page.child, allowSnapshotting: page.allowSnapshotting);

  PrimePage<T> get _page => settings as PrimePage<T>;

  @override
  WidgetBuilder get builder =>
      (context) => _page.child;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  PageTransitionsBuilder? get transitionsBuilder => _page.transitionsBuilder;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';
}

/// Slides the new page in from the trailing edge while the page below drifts
/// a third of the way off the leading edge. The default on iOS and macOS.
///
/// With [backSwipe], a drag from the leading edge of the screen pulls the page
/// back off, as on iOS. A fullscreen dialog rises from the bottom instead and
/// has no back-swipe.
class PrimeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const PrimeSlidePageTransitionsBuilder({this.backSwipe = true});

  /// Whether a drag from the leading screen edge pops the page.
  final bool backSwipe;

  static final Animatable<Offset> _inFromTrailing = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero);
  static final Animatable<Offset> _outToLeading = Tween<Offset>(begin: Offset.zero, end: const Offset(-1 / 3, 0));
  static final Animatable<Offset> _inFromBottom = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // The page has to track the finger exactly while a back-swipe drags it.
    final bool linear = route.popGestureInProgress;
    Animation<double> curved(Animation<double> parent) {
      return linear
          ? parent
          : CurvedAnimation(parent: parent, curve: Curves.fastEaseInToSlowEaseOut, reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped);
    }

    final TextDirection textDirection = Directionality.of(context);
    final Widget page = SlideTransition(
      position: curved(secondaryAnimation).drive(_outToLeading),
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: curved(animation).drive(route.fullscreenDialog ? _inFromBottom : _inFromTrailing),
        textDirection: route.fullscreenDialog ? null : textDirection,
        child: child,
      ),
    );
    if (!backSwipe || route.fullscreenDialog) return page;
    return _BackSwipeDetector<T>(route: route, child: page);
  }
}

/// Fades the new page in with a slight rise while the page below fades out.
/// The default on Android, Linux, Windows and the web.
///
/// On Android the system back gesture drives the transition, so the page
/// follows the swipe (predictive back).
class PrimeFadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const PrimeFadeThroughPageTransitionsBuilder();

  static final Animatable<Offset> _rise = Tween<Offset>(
    begin: const Offset(0, 0.04),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));
  static final Animatable<double> _fadeIn = CurveTween(curve: const Interval(0, 0.6, curve: Curves.easeOut));
  static final Animatable<double> _fadeOut = Tween<double>(
    begin: 1,
    end: 0,
  ).chain(CurveTween(curve: const Interval(0, 0.4, curve: Curves.easeIn)));

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _PredictiveBackDetector(
      route: route,
      child: FadeTransition(
        opacity: secondaryAnimation.drive(_fadeOut),
        child: FadeTransition(
          opacity: animation.drive(_fadeIn),
          child: SlideTransition(position: animation.drive(_rise), child: child),
        ),
      ),
    );
  }
}

// Hands the Android system back gesture to the route, which then scrubs its
// own transition as the gesture progresses.
class _PredictiveBackDetector extends StatefulWidget {
  const _PredictiveBackDetector({required this.route, required this.child});

  final PageRoute<dynamic> route;
  final Widget child;

  @override
  State<_PredictiveBackDetector> createState() => _PredictiveBackDetectorState();
}

class _PredictiveBackDetectorState extends State<_PredictiveBackDetector> with WidgetsBindingObserver {
  bool _active = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    _active = !backEvent.isButtonEvent && widget.route.isCurrent && widget.route.popGestureEnabled;
    if (_active) widget.route.handleStartBackGesture(progress: 1 - backEvent.progress);
    return _active;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (_active) widget.route.handleUpdateBackGestureProgress(progress: 1 - backEvent.progress);
  }

  @override
  void handleCancelBackGesture() {
    if (_active) widget.route.handleCancelBackGesture();
    _active = false;
  }

  @override
  void handleCommitBackGesture() {
    if (_active) widget.route.handleCommitBackGesture();
    _active = false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// A page dragged past this fraction of the screen pops when released.
const double _kPopThreshold = 0.5;
// A release faster than this, in screen widths per second, decides by direction instead.
const double _kMinFlingVelocity = 1.0;
const int _kMaxSettleMilliseconds = 400;
const double _kBackSwipeEdgeWidth = 20.0;

// Pops the route when the user drags in from the leading edge of the screen.
class _BackSwipeDetector<T> extends StatefulWidget {
  const _BackSwipeDetector({super.key, required this.route, required this.child});

  final PageRoute<T> route;
  final Widget child;

  @override
  State<_BackSwipeDetector<T>> createState() => _BackSwipeDetectorState<T>();
}

class _BackSwipeDetectorState<T> extends State<_BackSwipeDetector<T>> {
  late final HorizontalDragGestureRecognizer _recognizer;
  bool _dragging = false;

  // The navigator and controller are captured at drag start: the route can be
  // gone by the time the settle animation ends.
  NavigatorState? _navigator;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    // Unmounted mid-drag: release the navigator on the next frame, once the
    // tree is no longer locked.
    if (_dragging) {
      final NavigatorState? navigator = _navigator;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator?.mounted ?? false) navigator!.didStopUserGesture();
      });
    }
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.route.popGestureEnabled) _recognizer.addPointer(event);
  }

  double _signed(double value) => Directionality.of(context) == TextDirection.rtl ? -value : value;

  void _handleDragStart(DragStartDetails details) {
    final PageRoute<T> route = widget.route;
    if (!mounted || route.navigator == null || !route.popGestureEnabled) return;
    _dragging = true;
    _navigator = route.navigator;
    // ignore: invalid_use_of_protected_member
    _controller = route.controller;
    _navigator!.didStartUserGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_dragging) return;
    _controller!.value -= _signed(details.primaryDelta! / context.size!.width);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _settle(_signed(details.velocity.pixelsPerSecond.dx / context.size!.width));
  }

  void _handleDragCancel() {
    if (!_dragging) return;
    _settle(0);
  }

  void _settle(double velocity) {
    _dragging = false;
    final AnimationController controller = _controller!;
    final NavigatorState navigator = _navigator!;
    const Curve curve = Curves.fastEaseInToSlowEaseOut;

    // A fling decides by its direction; a slow release by how far the page got.
    final bool stay = velocity.abs() >= _kMinFlingVelocity ? velocity <= 0 : controller.value > _kPopThreshold;
    if (stay) {
      final int ms = math.min(lerpDouble(800, 0, controller.value)!.floor(), _kMaxSettleMilliseconds);
      controller.animateTo(
        1.0,
        duration: Duration(milliseconds: ms),
        curve: curve,
      );
    } else {
      if (widget.route.isCurrent) navigator.pop();
      // The pop may already have finished the animation inline.
      if (controller.isAnimating) {
        final int ms = lerpDouble(0, 800, controller.value)!.floor();
        controller.animateBack(
          0.0,
          duration: Duration(milliseconds: math.min(ms, _kMaxSettleMilliseconds)),
          curve: curve,
        );
      }
    }

    if (controller.isAnimating) {
      // Keep the gesture "in progress" until the page settles, so the
      // transition stays linear and hero flights wait for it.
      late AnimationStatusListener listener;
      listener = (AnimationStatus status) {
        controller.removeStatusListener(listener);
        navigator.didStopUserGesture();
      };
      controller.addStatusListener(listener);
    } else {
      navigator.didStopUserGesture();
    }
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    final double startInset = Directionality.of(context) == TextDirection.ltr ? padding.left : padding.right;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: math.max(startInset, _kBackSwipeEdgeWidth),
          child: Listener(onPointerDown: _handlePointerDown, behavior: HitTestBehavior.translucent),
        ),
      ],
    );
  }
}
