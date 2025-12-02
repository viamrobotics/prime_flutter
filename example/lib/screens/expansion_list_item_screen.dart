import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ExpansionListItemScreen extends StatelessWidget {
  const ExpansionListItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Expansion List Item')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                const ExpansionListItem(
                  title: Text('Standard Expansion Item'),
                  children: [Text('This is a standard expansion item with no background.')],
                ),
                const ExpansionListItem(title: Text('Card Expansion Item'), children: [Text('This item uses the card variant.')]),
                const ExpansionListItem(
                  title: Text('With Leading Icon'),
                  leading: Icon(PrimeIcons.packageVariantClosed, size: 20),
                  children: [Text('Content with leading icon in header.')],
                ),
                ExpansionListItem(
                  title: const Text('With Trailing Badge'),
                  trailing: const Badge(text: 'NEW', variant: BadgeVariant.success),
                  children: [
                    const Text('Content with trailing badge.'),
                    const SizedBox(height: 8),
                    Button(label: 'Action', variant: ButtonVariant.primary, onPressed: () {}),
                  ],
                ),
                const ExpansionListItem(
                  title: Text('Initially Expanded'),
                  initiallyExpanded: true,
                  children: [Text('This card is expanded by default.')],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 8,
                children: [
                  const ExpansionListItem.card(title: Text('Card Expansion Item'), children: [Text('This item uses the card variant.')]),
                  const ExpansionListItem.card(
                    title: Text('With Leading Icon'),
                    leading: Icon(PrimeIcons.packageVariantClosed, size: 20),
                    children: [Text('Content with leading icon in header.')],
                  ),
                  ExpansionListItem.card(
                    title: const Text('With Trailing Badge'),
                    trailing: const Badge(text: 'NEW', variant: BadgeVariant.success),
                    children: [
                      const Text('Content with trailing badge.'),
                      const SizedBox(height: 8),
                      Button(label: 'Action', onPressed: () {}),
                    ],
                  ),
                  const ExpansionListItem.card(
                    title: Text('Initially Expanded'),
                    initiallyExpanded: true,
                    children: [Text('This card is expanded by default.')],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
