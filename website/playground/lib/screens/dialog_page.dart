import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class DialogPage extends StatelessWidget {
  const DialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: Button(
          label: const Text('Show dialog'),
          variant: ButtonVariant.primary,
          onPressed: () {
            PrimeDialog.show<bool>(
              context: context,
              title: const Text('Confirm'),
              child: const Text('Are you sure you want to continue?'),
              actions: [
                PrimeDialogAction<bool>(label: const Text('Cancel'), value: false),
                PrimeDialogAction<bool>(
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
