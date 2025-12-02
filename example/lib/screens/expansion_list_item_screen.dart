import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ExpansionListItemScreen extends StatelessWidget {
  const ExpansionListItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(title: Text('Expansion List Item')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                ExpansionListItem(
                  title: Text('Standard Expansion Item'),
                  children: [Text('This is a standard expansion item with no background.')],
                ),
                Divider(),
                ExpansionListItem(
                  title: Text('With Leading Icon'),
                  leading: Icon(PrimeIcons.packageVariantClosed, size: 20),
                  children: [Text('Content with leading icon in header.')],
                ),
                Divider(),
                ExpansionListItem(
                  title: Text('With Trailing Badge'),
                  trailing: Badge(text: 'NEW', variant: BadgeVariant.success),
                  children: [
                    Text('Content with trailing badge.'),
                    SizedBox(height: 8),
                    Button(label: 'Action', variant: ButtonVariant.primary, onPressed: () {}),
                  ],
                ),
                Divider(),
                ExpansionListItem(
                  title: Text('Initially Expanded'),
                  initiallyExpanded: true,
                  children: [Text('This card is expanded by default.')],
                ),
                Divider(),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                spacing: 8,
                children: [
                  Text('Card Variants'),
                  ExpansionListItem.card(title: Text('Card Expansion Item'), children: [Text('This item uses the card variant.')]),
                  ExpansionListItem.card(
                    title: Text('With Leading Icon'),
                    leading: Icon(PrimeIcons.packageVariantClosed, size: 20),
                    children: [Text('Content with leading icon in header.')],
                  ),
                  ExpansionListItem.card(
                    title: Text('With Trailing Badge'),
                    trailing: Badge(text: 'NEW', variant: BadgeVariant.success),
                    children: [
                      Text('Content with trailing badge.'),
                      SizedBox(height: 8),
                      Button(label: 'Action', onPressed: () {}),
                    ],
                  ),
                  ExpansionListItem.card(
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
