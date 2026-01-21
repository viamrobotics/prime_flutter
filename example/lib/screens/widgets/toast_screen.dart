import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ToastScreen extends StatelessWidget {
  const ToastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Toast')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              label: const Text('Show Neutral Toast'),
              onPressed: () {
                Toast.show(context, message: 'Settings saved');
              },
            ),
            const SizedBox(height: 16),
            Button(
              variant: ButtonVariant.secondary,
              label: const Text('Show Success Toast'),
              onPressed: () {
                Toast.show(context, message: 'Item created successfully', variant: ToastVariant.success);
              },
            ),
            const SizedBox(height: 16),
            Button(
              variant: ButtonVariant.secondary,
              label: const Text('Show Info Toast'),
              onPressed: () {
                Toast.show(context, message: 'Update available', variant: ToastVariant.info);
              },
            ),
            const SizedBox(height: 16),
            Button(
              variant: ButtonVariant.secondary,
              label: const Text('Show Warning Toast'),
              onPressed: () {
                Toast.show(context, message: 'Connection unstable', variant: ToastVariant.warning);
              },
            ),
            const SizedBox(height: 16),
            Button(
              variant: ButtonVariant.secondary,
              label: const Text('Show Danger Toast'),
              onPressed: () {
                Toast.show(
                  context,
                  message: 'Failed to delete item',
                  variant: ToastVariant.danger,
                  action: Button(variant: ButtonVariant.ghost, label: const Text('RETRY'), onPressed: () => print('Retry clicked')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
