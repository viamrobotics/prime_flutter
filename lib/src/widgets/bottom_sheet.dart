import 'package:flutter/widgets.dart';

import '../../prime_flutter.dart';

/// A simple bottom sheet widget that can be used to display a title, background color, and child widget.
///
/// Show one with [BottomSheet.show], which slides it up over a dimmed page.
/// Dragging the sheet down, tapping the dimmed page, or the system back
/// gesture dismisses it.
class BottomSheet extends StatelessWidget {
  /// The child widget to display in the bottom sheet.
  final Widget child;

  /// The title widget to display in the bottom sheet. A helper widget for commonly styled bottom sheet titles.
  final Widget? title;

  /// The background color of the bottom sheet. Defaults to [PrimeColorScheme.surfaceBase].
  final Color? backgroundColor;

  /// Whether the bottom sheet should be scrollable. Defaults to true.
  final bool isScrollable;

  const BottomSheet({super.key, required this.child, this.title, this.backgroundColor, this.isScrollable = true});

  /// Shows a modal bottom sheet. The future completes with the value passed
  /// to `Navigator.pop`, or null when the sheet is dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    Widget? title,
    Color? backgroundColor,
    bool isScrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
  }) {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    return navigator.push<T>(
      PrimeModalSheetRoute<T>(
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        settings: routeSettings,
        // Inherited themes do not reach a route from where it was pushed, so carry them over.
        capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
        builder: (context) => BottomSheet(title: title, backgroundColor: backgroundColor, isScrollable: isScrollable, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        const radius = BorderRadius.vertical(top: Radius.circular(20));
        return Padding(
          padding: MediaQuery.viewInsetsOf(context),
          child: Container(
            decoration: BoxDecoration(color: backgroundColor ?? theme.colorScheme.surfaceBase, borderRadius: radius),
            // Flat-shaded: an outline lifts the sheet off the page, not a shadow.
            foregroundDecoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: theme.colorScheme.borderSubtle),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(color: theme.colorScheme.borderSubtle, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: DefaultTextStyle(
                          style: theme.textTheme.bodyDefault.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: theme.colorScheme.textPrimary,
                          ),
                          child: title!,
                        ),
                      ),
                    Flexible(child: isScrollable ? SingleChildScrollView(child: child) : child),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A modal route that slides its content up from the bottom of the screen
/// over a dimmed barrier. [BottomSheet.show] pushes one.
///
/// Push it yourself to show a sheet with chrome of your own:
///
/// ```dart
/// Navigator.of(context).push(PrimeModalSheetRoute<void>(builder: (context) => const MySheet()));
/// ```
class PrimeModalSheetRoute<T> extends PopupRoute<T> {
  PrimeModalSheetRoute({
    required this.builder,
    this.isDismissible = true,
    this.enableDrag = true,
    this.maxWidth = 640,
    this.capturedThemes,
    Color? barrierColor,
    super.settings,
  }) : _barrierColor = barrierColor ?? const Color(0x66000000);

  /// Builds the sheet. It is bottom-aligned and may be as tall as the screen
  /// below the top safe area.
  final WidgetBuilder builder;

  /// Whether tapping the barrier dismisses the sheet.
  final bool isDismissible;

  /// Whether dragging the sheet down dismisses it.
  final bool enableDrag;

  /// The widest the sheet gets on large screens.
  final double maxWidth;

  /// Themes captured where the sheet was requested, re-applied around it.
  final CapturedThemes? capturedThemes;

  final Color _barrierColor;

  // Once the user has dragged the sheet it follows the controller linearly,
  // so it stays under the finger and settles without a jump.
  bool _linear = false;

  @override
  Color get barrierColor => _barrierColor;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final Widget sheet = Builder(builder: builder);
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: _SheetDragger<T>(route: this, child: capturedThemes?.wrap(sheet) ?? sheet),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double t = _linear ? animation.value : Curves.easeOutCubic.transform(animation.value);
        return FractionalTranslation(translation: Offset(0, 1 - t), child: child);
      },
      child: child,
    );
  }
}

class _SheetDragger<T> extends StatefulWidget {
  const _SheetDragger({required this.route, required this.child});

  final PrimeModalSheetRoute<T> route;
  final Widget child;

  @override
  State<_SheetDragger<T>> createState() => _SheetDraggerState<T>();
}

class _SheetDraggerState<T> extends State<_SheetDragger<T>> {
  // A release faster than this many pixels per second dismisses the sheet.
  static const double _minFlingVelocity = 700;

  // ignore: invalid_use_of_protected_member
  AnimationController? get _controller => widget.route.controller;

  bool get _canDrag => widget.route.isCurrent && widget.route.popDisposition == RoutePopDisposition.pop;

  void _handleDragStart(DragStartDetails details) {
    if (!_canDrag) return;
    final AnimationController controller = _controller!;
    // Re-base onto the linear track at the sheet's current visual position.
    final double visual = widget.route._linear ? controller.value : Curves.easeOutCubic.transform(controller.value);
    widget.route._linear = true;
    controller.value = visual;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_canDrag || !widget.route._linear) return;
    final double height = context.size!.height;
    if (height <= 0) return;
    _controller!.value -= details.primaryDelta! / height;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_canDrag || !widget.route._linear) return;
    final AnimationController controller = _controller!;
    final double velocity = details.primaryVelocity ?? 0;
    final bool dismiss = velocity > _minFlingVelocity || (velocity >= 0 && controller.value < 0.5);
    if (dismiss) {
      Navigator.of(context).pop();
    } else {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.route.enableDrag) return widget.child;
    return GestureDetector(
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      onVerticalDragCancel: () {
        if (widget.route.isCurrent && widget.route._linear) _controller?.forward();
      },
      child: widget.child,
    );
  }
}
