import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

/// A navigation bar widget. Used to navigate between different destinations.
class NavigationBar extends StatelessWidget {
  /// The index of the currently selected destination.
  final int selectedIndex;

  /// The callback function to be called when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// The list of navigation bar items, used to render the navigation bar.
  final List<NavigationBarItemData> items;

  const NavigationBar({super.key, required this.selectedIndex, required this.onDestinationSelected, required this.items});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.bgExtraLight,
            border: Border(top: BorderSide(color: theme.colorScheme.gray3, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDestinationSelected(index),
                  child: _NavBarItemRenderer(item: item, isSelected: isSelected),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class NavigationBarItemData {
  final IconData icon;
  final String label;
  final IconData? selectedIcon;

  const NavigationBarItemData({required this.icon, required this.label, this.selectedIcon});
}

class _NavBarItemRenderer extends StatefulWidget {
  final NavigationBarItemData item;
  final bool isSelected;

  const _NavBarItemRenderer({required this.item, required this.isSelected});

  @override
  State<_NavBarItemRenderer> createState() => _NavBarItemRendererState();
}

class _NavBarItemRendererState extends State<_NavBarItemRenderer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = PrimeTheme.of(context).colorScheme;
    final typography = PrimeTheme.of(context).textTheme;

    final iconColor = widget.isSelected ? colors.gray9 : colors.gray6;
    final textColor = widget.isSelected ? colors.gray9 : colors.gray6;
    final iconData = (widget.isSelected && widget.item.selectedIcon != null) ? widget.item.selectedIcon! : widget.item.icon;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Container(
        color: _isHovered ? colors.opacityLight : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: iconColor, size: 24),
            const SizedBox(height: 2),
            Text(
              widget.item.label,
              style: typography.bodySmall.copyWith(
                fontSize: 12,
                color: textColor,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
