import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';
import '../theme/prime_theme_data.dart';
import 'prime_icons.dart';

/// A simple app bar widget that can be used to display a title, leading, actions, and bottom widgets.
class AppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title widget to display in the app bar.
  final Widget? title;

  /// The leading widget to display in the app bar. Will be automatically replaced with a back button if the route can be dismissed.
  final Widget? leading;

  /// The actions widget to display in the app bar. Will be automatically aligned to the right.
  final List<Widget>? actions;

  /// The bottom widget to display in the app bar. Will be automatically aligned to the bottom.
  ///
  /// Typically used to display a [PrimeTabBar].
  final PreferredSizeWidget? bottom;

  /// Whether the [title] should be centered.
  ///
  /// When true (default), [leading], [title] and [actions] are stacked, so the
  /// title sits in the horizontal center of the bar regardless of the size of
  /// the leading or action slots. Best for short, fixed titles — long titles
  /// will overlap the leading/action slots.
  ///
  /// When false, [leading], [title] and [actions] lay out horizontally, with
  /// the title taking the remaining space between them. Long titles fade or
  /// ellipsis cleanly against the actions, and the leading slot is no longer
  /// constrained to icon width — pass anything (e.g. an org switcher).
  final bool centerTitle;

  /// Whether to show a back button when [leading] is null and the route can be popped.
  ///
  /// Set to false for screens that handle going back themselves, such as a multi-step flow that steps back through its
  /// own pages before leaving the route.
  final bool automaticallyImplyLeading;

  const AppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  @override
  // +1 accounts for the 1px bottom border, which insets the Container's layout size.
  Size get preferredSize => Size.fromHeight(48 + (bottom?.preferredSize.height ?? 0) + 1);

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.impliesAppBarDismissal ?? false;

    return PrimeTheme.consumer(
      builder: (context, theme) {
        // Automatically add back button if no leading widget and route can be dismissed
        final Widget effectiveLeading =
            leading ??
            (canPop && automaticallyImplyLeading
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox.square(dimension: 24, child: Icon(PrimeIcons.chevronLeft, size: 24)),
                    ),
                  )
                : const SizedBox.shrink());

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceOffset,
            border: Border(bottom: BorderSide(color: theme.colorScheme.borderSubtle)),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: centerTitle ? _buildStackLayout(theme, effectiveLeading) : _buildRowLayout(theme, effectiveLeading),
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStackLayout(PrimeThemeData theme, Widget? effectiveLeading) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (effectiveLeading != null)
          Align(
            alignment: Alignment.centerLeft,
            child: IconTheme(
              data: IconThemeData(color: theme.colorScheme.iconSecondary, size: 24),
              child: DefaultTextStyle(
                style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textPrimary, fontWeight: FontWeight.w600),
                child: effectiveLeading,
              ),
            ),
          ),
        if (title != null)
          DefaultTextStyle(
            style: theme.textTheme.title.copyWith(color: theme.colorScheme.textPrimary),
            child: title!,
          ),
        if (actions != null)
          Align(
            alignment: Alignment.centerRight,
            child: IconTheme(
              data: IconThemeData(color: theme.colorScheme.iconSecondary, size: 24),
              child: Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: actions!),
            ),
          ),
      ],
    );
  }

  Widget _buildRowLayout(PrimeThemeData theme, Widget? effectiveLeading) {
    return Row(
      children: [
        if (effectiveLeading != null) ...[
          IconTheme(
            data: IconThemeData(color: theme.colorScheme.iconSecondary, size: 24),
            child: DefaultTextStyle(
              style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textPrimary, fontWeight: FontWeight.w600),
              child: effectiveLeading,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (title != null)
          Expanded(
            child: DefaultTextStyle(
              style: theme.textTheme.title.copyWith(color: theme.colorScheme.textPrimary),
              child: title!,
            ),
          )
        else
          const Spacer(),
        if (actions != null)
          IconTheme(
            data: IconThemeData(color: theme.colorScheme.iconSecondary, size: 24),
            child: Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: actions!),
          ),
      ],
    );
  }
}

/// The former name of [AppBar].
@Deprecated('Use AppBar instead. Run `dart fix --apply` to migrate.')
typedef PrimeAppBar = AppBar;
