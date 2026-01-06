import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum ExpansionListItemPageStyle { standard, card }

class ExpansionListItemPage extends StatelessWidget {
  final ExpansionListItemPageStyle style;

  const ExpansionListItemPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: SizedBox(
          width: 350,
          child: switch (style) {
            ExpansionListItemPageStyle.standard => ExpansionListItem(
              initiallyExpanded: true,
              title: const Text('Expansion Item'),
              leading: const Icon(PrimeIcons.viamFlutter),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('This is the content hidden inside the expansion item.', style: PrimeTheme.of(context).textTheme.bodyDefault),
                ),
              ],
            ),
            ExpansionListItemPageStyle.card => ExpansionListItem.card(
              initiallyExpanded: true,
              title: const Text('Card Expansion'),
              leading: const Icon(PrimeIcons.viamFlutter),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Content inside a card style expansion item.', style: PrimeTheme.of(context).textTheme.bodyDefault),
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}
