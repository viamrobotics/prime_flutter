import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';
import 'prime_icons.dart';

/// A simple app bar widget that can be used to display a title, leading, actions, and bottom widgets.
class PrimeAppBar extends StatelessWidget {
  /// The title widget to display in the app bar.
  final Widget? title;

  /// The leading widget to display in the app bar. Will be automatically replaced with a back button if the route can be dismissed.
  final Widget? leading;

  /// The actions widget to display in the app bar. Will be automatically aligned to the right.
  final List<Widget>? actions;

  /// The bottom widget to display in the app bar. Will be automatically aligned to the bottom.
  ///
  /// Typically used to display a [PrimeTabBar].
  final Widget? bottom;

  const PrimeAppBar({super.key, this.title, this.leading, this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.impliesAppBarDismissal ?? false;

    return PrimeTheme.consumer(
      builder: (context, theme) {
        Widget? effectiveLeading = leading;

        // Automatically add back button if no leading widget and route can be dismissed
        if (effectiveLeading == null && canPop) {
          effectiveLeading = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: SizedBox.square(dimension: 24, child: Icon(PrimeIcons.chevronLeft, size: 24, color: theme.colorScheme.textDisabled)),
            ),
          );
        } else if (effectiveLeading == null && !canPop) {
          effectiveLeading = SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.bgExtraLight,
            border: Border(bottom: BorderSide(color: theme.colorScheme.borderLight)),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (effectiveLeading != null) Align(alignment: Alignment.centerLeft, child: effectiveLeading),
                      if (title != null) DefaultTextStyle(style: theme.textTheme.title, child: title!),
                      if (actions != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
                        ),
                    ],
                  ),
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        );
      },
    );
  }
}
