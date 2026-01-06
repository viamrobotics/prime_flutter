import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

/// A tab bar widget. Used to display a tab bar. Scrolls horizontally if there are too many tabs.
///
/// Typically used in the [PrimeScaffold] in the [PrimeAppBar.bottom] property.
class TabBar extends StatelessWidget {
  /// The list of tabs to display in the tab bar.
  final List<Widget> items;

  /// The currently selected tab index.
  final int selectedIndex;

  /// The callback to be called when a tab is selected.
  final ValueChanged<int> onDestinationSelected;

  const TabBar({super.key, required this.items, required this.selectedIndex, required this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = index == selectedIndex;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDestinationSelected(index),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        margin: EdgeInsets.only(right: index == items.length - 1 ? 0 : 24),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: isSelected ? theme.colorScheme.textPrimary : const Color(0x00000000), width: 2),
                          ),
                        ),
                        child: DefaultTextStyle(
                          style: theme.textTheme.label.copyWith(
                            fontWeight: FontWeight.w400,
                            color: isSelected ? theme.colorScheme.textPrimary : theme.colorScheme.textTertiary,
                            letterSpacing: 1.0,
                          ),
                          child: item,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // left fade edge
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 22,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [theme.colorScheme.surfaceOffset, theme.colorScheme.surfaceOffset.withAlpha(0)],
                      ),
                    ),
                  ),
                ),
              ),
              // right fade edge
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 24,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [theme.colorScheme.surfaceOffset, theme.colorScheme.surfaceOffset.withAlpha(0)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
