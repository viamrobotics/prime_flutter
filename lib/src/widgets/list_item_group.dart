import 'package:flutter/widgets.dart';
import '../../prime_flutter.dart';
import '../theme/prime_theme.dart';

/// A bordered card that groups multiple rows (typically [ListItem]s) with
/// hairline dividers between them.
///
/// Use the standard [ListItem] variant for children — the group provides the
/// card chrome (background, border, rounded corners). Passing a `ListItem.card`
/// child will produce double chrome.
class ListItemGroup extends StatelessWidget {
  /// The rows displayed inside the grouped card.
  final List<Widget> children;

  const ListItemGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final radius = BorderRadius.circular(theme.cornerRadius);
        final divider = Divider();

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i++) {
          rows.add(children[i]);
          if (i < children.length - 1) rows.add(divider);
        }

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceOffset,
            border: Border.all(color: theme.colorScheme.borderSubtle),
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: rows,
            ),
          ),
        );
      },
    );
  }
}
