import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

class PrimeTabBar extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const PrimeTabBar({super.key, required this.items, required this.selectedIndex, required this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == selectedIndex;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onDestinationSelected(index),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    margin: const EdgeInsets.only(right: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isSelected ? theme.colorScheme.gray9 : const Color(0x00000000), width: 2)),
                    ),
                    child: Text(
                      item.toUpperCase(),
                      style: theme.textTheme.label.copyWith(
                        fontWeight: FontWeight.w400,
                        color: isSelected ? theme.colorScheme.gray9 : theme.colorScheme.gray5,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
