import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ListItemScreen extends StatelessWidget {
  const ListItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('List Items')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Standard List Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListItem(title: Text('Simple Item')),
            const ListItem(leading: Icon(PrimeIcons.accountGroupOutline), title: Text('With Leading')),
            const ListItem(title: Text('With Trailing'), trailing: Icon(PrimeIcons.chevronRight)),
            const ListItem(
              leading: Icon(PrimeIcons.send),
              title: Text('Two Line Item'),
              subtitle: Text('This is a subtitle text'),
              trailing: Icon(PrimeIcons.chevronRight),
            ),
            ListItem(
              leading: const Icon(PrimeIcons.cog),
              title: const Text('Interactive Item'),
              subtitle: const Text('Click me!'),
              onPressed: () {
                print('Item clicked');
              },
              trailing: const Icon(PrimeIcons.chevronRight),
            ),

            const SizedBox(height: 32),
            const Text('Card List Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const ListItem.card(title: Text('Card Item')),
            const SizedBox(height: 8),
            const ListItem.card(
              leading: Icon(PrimeIcons.packageVariantClosed),
              title: Text('With Leading'),
              subtitle: Text('And subtitle'),
            ),
            const SizedBox(height: 8),
            ListItem.card(
              leading: const Icon(PrimeIcons.alert),
              title: const Text('Interactive Card'),
              subtitle: const Text('Hover and click me'),
              trailing: const Icon(PrimeIcons.chevronRight),
              onPressed: () {
                print('Card clicked');
              },
            ),
          ],
        ),
      ),
    );
  }
}
