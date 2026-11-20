import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class DialogScreen extends StatelessWidget {
  const DialogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar(title: Text('Dialog')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm dialog', style: PrimeTheme.of(context).textTheme.title),
            const SizedBox(height: 8),
            Button(
              label: const Text('Show dialog'),
              onPressed: () async {
                await Dialog.show<bool>(
                  context: context,
                  title: const Text('Confirm'),
                  child: const Text('Are you sure you want to continue?'),
                  actions: [
                    DialogAction<bool>(label: const Text('Cancel'), value: false),
                    DialogAction<bool>(
                      label: const Text('OK'),
                      value: true,
                      variant: ButtonVariant.primary,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Alert (no actions)', style: PrimeTheme.of(context).textTheme.title),
            const SizedBox(height: 8),
            Button(
              variant: ButtonVariant.secondary,
              label: const Text('Show alert'),
              onPressed: () {
                Dialog.show<void>(
                  context: context,
                  title: const Text('Notice'),
                  child: const Text('Tap outside or the close icon to dismiss.'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
