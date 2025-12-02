import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ExpansionCardScreen extends StatelessWidget {
  const ExpansionCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Expansion Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 16,
          children: [
            const ExpansionCard(
              title: Text('Basic Expansion Card'),
              children: [Text('This is the expanded content. It can contain any widget.')],
            ),
            const ExpansionCard(
              title: Text('With Leading Icon'),
              leading: Icon(PrimeIcons.packageVariantClosed, size: 20),
              children: [Text('Content with leading icon in header.')],
            ),
            ExpansionCard(
              title: const Text('With Trailing Badge'),
              trailing: const Badge(text: 'NEW', variant: BadgeVariant.success),
              children: [
                const Text('Content with trailing badge.'),
                const SizedBox(height: 8),
                Button(label: 'Action', onPressed: () {}),
              ],
            ),
            const ExpansionCard(
              title: Text('Initially Expanded'),
              initiallyExpanded: true,
              children: [Text('This card is expanded by default.')],
            ),
          ],
        ),
      ),
    );
  }
}
