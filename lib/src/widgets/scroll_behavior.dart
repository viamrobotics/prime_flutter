import 'package:flutter/widgets.dart';

import '../theme/prime_colors.dart';
import '../theme/prime_theme.dart';

/// How scrollables look and feel in a Prime app. `PrimeApp` installs it.
///
/// Each platform keeps its native physics. On top of that:
///
///  * Desktop gets a flat Prime scrollbar.
///  * Android stretches on overscroll, as Android 12 and later do, instead of
///    showing the older glow.
///
/// To change it for the whole app, pass a subclass or a `copyWith` to
/// `PrimeApp.scrollBehavior`. To also let a mouse drag scrollables, as a
/// touchscreen would:
///
/// ```dart
/// class DragScrollBehavior extends PrimeScrollBehavior {
///   @override
///   Set<PointerDeviceKind> get dragDevices => {...super.dragDevices, PointerDeviceKind.mouse};
/// }
/// ```
class PrimeScrollBehavior extends ScrollBehavior {
  const PrimeScrollBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // Only the vertical axis gets one by default, as on the web and in native toolkits.
    if (axisDirectionToAxis(details.direction) == Axis.horizontal) return child;
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        assert(details.controller != null);
        final Color thumb = PrimeTheme.maybeOf(context)?.colorScheme.iconDisabled ?? PrimeColors.gray5;
        return RawScrollbar(
          controller: details.controller,
          thumbColor: thumb.withValues(alpha: 0.7),
          radius: const Radius.circular(4),
          thickness: 8,
          crossAxisMargin: 2,
          mainAxisMargin: 2,
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
    }
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return StretchingOverscrollIndicator(
          axisDirection: details.direction,
          clipBehavior: details.decorationClipBehavior ?? Clip.hardEdge,
          child: child,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
    }
  }
}
