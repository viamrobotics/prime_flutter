import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum InputPageStyle { basic, withIcons, password, formField }

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
            InputPageStyle.formField => const _FormFieldExample(),
          },
        ),
      ),
    );
  }
}

/// An [InputFormField] in a [Form]: Save validates, and an empty name shows the error under the field.
class _FormFieldExample extends StatefulWidget {
  const _FormFieldExample();

  @override
  State<_FormFieldExample> createState() => _FormFieldExampleState();
}

class _FormFieldExampleState extends State<_FormFieldExample> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          InputFormField(
            label: const Text('Machine name'),
            hint: const Text('Letters, numbers and dashes.'),
            required: true,
            placeholder: 'my-rover',
            validator: (value) => (value ?? '').trim().isEmpty ? 'Enter a machine name.' : null,
          ),
          Button(variant: ButtonVariant.primary, label: const Text('Save'), onPressed: () => _formKey.currentState!.validate()),
        ],
      ),
    );
  }
}
