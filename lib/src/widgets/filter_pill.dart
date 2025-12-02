import 'package:flutter/widgets.dart';
import '../../prime_flutter.dart';

class FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? color;
  final Widget? leading;

  const FilterPill({super.key, required this.label, this.isSelected = false, this.onTap, this.color, this.leading});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final selectedColor = color ?? theme.colorScheme.primary;
        final backgroundColor = isSelected ? selectedColor : theme.colorScheme.bgExtraLight;
        final borderColor = isSelected ? selectedColor : theme.colorScheme.borderLight;
        final textColor = isSelected ? theme.colorScheme.white : theme.colorScheme.textDefault;

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(100), // Stadium shape
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: theme.textTheme.bodyDefault.copyWith(color: textColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
