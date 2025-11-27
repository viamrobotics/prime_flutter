import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

class AppBar extends StatelessWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? bottom;

  const AppBar({super.key, required this.title, this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.colorScheme.bgExtraLight,
              child: Row(
                children: [
                  DefaultTextStyle(style: theme.textTheme.title, child: title),
                  if (actions != null) ...[const Spacer(), ...actions!],
                ],
              ),
            ),
            if (bottom != null) bottom!,
          ],
        );
      },
    );
  }
}
