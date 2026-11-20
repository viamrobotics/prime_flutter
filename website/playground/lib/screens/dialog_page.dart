import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class DialogPage extends StatelessWidget {
  const DialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Button(
          label: const Text('Show dialog'),
          variant: ButtonVariant.primary,
          onPressed: () {
            Dialog.show<bool>(
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
      ),
    );
  }
}
