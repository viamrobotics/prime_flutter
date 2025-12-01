import 'package:flutter/widgets.dart';
import '../theme/prime_theme.dart';

class PrimeAppBar extends StatelessWidget {
  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottom;

  const PrimeAppBar({super.key, required this.title, this.leading, this.actions, this.bottom});

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

              decoration: BoxDecoration(
                color: theme.colorScheme.bgExtraLight,
                border: Border(bottom: BorderSide(color: theme.colorScheme.borderLight)),
              ),
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
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
