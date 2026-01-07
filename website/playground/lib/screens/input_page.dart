import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum InputPageStyle { basic, withIcons, password }

class InputPage extends StatelessWidget {
  final InputPageStyle style;

  const InputPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: switch (style) {
            InputPageStyle.basic => const Input(placeholder: 'Enter text...'),
            InputPageStyle.withIcons => const Input(
              placeholder: 'Search...',
              leading: Icon(PrimeIcons.magnify),
              trailing: Icon(PrimeIcons.close),
            ),
            InputPageStyle.password => const Input(
              placeholder: 'Password',
              obscureText: true,
              leading: Icon(PrimeIcons.lock),
              trailing: Icon(PrimeIcons.viamFlutter), // Placeholder for visibility toggle
            ),
          },
        ),
      ),
    );
  }
}
