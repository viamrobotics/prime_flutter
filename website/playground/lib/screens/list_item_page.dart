import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum ListItemPageStyle { standard, threeLine, card, interactive }

class ListItemPage extends StatelessWidget {
  final ListItemPageStyle style;

  const ListItemPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: Container(
            decoration: BoxDecoration(
              color: PrimeTheme.of(context).colorScheme.surfaceBase,
              border: Border.all(color: PrimeTheme.of(context).colorScheme.borderSubtle),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                switch (style) {
                  ListItemPageStyle.standard => const ListItem(
                    title: Text('List Item'),
                    subtitle: Text('Supporting text goes here'),
                    leading: Icon(PrimeIcons.viamFlutter),
                    trailing: Icon(PrimeIcons.chevronRight),
                  ),
                  ListItemPageStyle.threeLine => const ListItem(
                    title: Text('Three-line Item'),
                    subtitle: Text('Secondary text\nTertiary text'),
                    isThreeLine: true,
                    leading: Icon(PrimeIcons.viamFlutter),
                  ),
                  ListItemPageStyle.card => ListItem.card(
                    title: const Text('Card List Item'),
                    subtitle: const Text('This item looks like a card'),
                    leading: const Icon(PrimeIcons.viamFlutter),
                    onPressed: () {},
                  ),
                  ListItemPageStyle.interactive => ListItem(
                    title: const Text('Interactive Item'),
                    subtitle: const Text('Tap, hover, or focus me'),
                    onPressed: () {},
                    trailing: const Icon(PrimeIcons.chevronRight),
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
