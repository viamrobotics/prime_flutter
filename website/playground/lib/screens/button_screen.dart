import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(title: const Text('Buttons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Variants'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Button(onPressed: () {}, variant: ButtonVariant.primary, label: const Text('Primary')),
                Button(onPressed: () {}, variant: ButtonVariant.secondary, label: const Text('Secondary')),
                Button(onPressed: () {}, variant: ButtonVariant.ghost, label: const Text('Ghost')),
                Button(onPressed: () {}, variant: ButtonVariant.danger, label: const Text('Destructive')),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Disabled'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const Button(disabled: true, onPressed: null, label: Text('Primary')),
                const Button(disabled: true, variant: ButtonVariant.secondary, onPressed: null, label: Text('Secondary')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
