import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum InputPageStyle { basic, withIcons, password, validation }

class InputPage extends StatelessWidget {
  final InputPageStyle style;

  const InputPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            InputPageStyle.validation => const _ValidationExample(),
          },
        ),
      ),
    );
  }
}

/// Validation without a Form: Save checks the name and the field shows the error through [Field] and [Hint].
class _ValidationExample extends StatefulWidget {
  const _ValidationExample();

  @override
  State<_ValidationExample> createState() => _ValidationExampleState();
}

class _ValidationExampleState extends State<_ValidationExample> {
  final _name = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Field(
          required: true,
          state: _error != null ? InputState.error : InputState.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              const Label(label: Text('Machine name')),
              Input(controller: _name, placeholder: 'my-rover'),
              Hint(child: Text(_error ?? 'Letters, numbers and dashes.')),
            ],
          ),
        ),
        Button(
          variant: ButtonVariant.primary,
          label: const Text('Save'),
          onPressed: () => setState(() => _error = _name.text.trim().isEmpty ? 'Enter a machine name.' : null),
        ),
      ],
    );
  }
}
