import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Input')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Input', style: theme.textTheme.title),
              const SizedBox(height: 8),
              const Input(placeholder: 'Enter text...'),
              const SizedBox(height: 24),
              Text('With Leading Icon', style: theme.textTheme.title),
              const SizedBox(height: 8),
              const Input(placeholder: 'Search...', leading: Icon(PrimeIcons.magnify)),
              const SizedBox(height: 24),
              Text('With Trailing Icon', style: theme.textTheme.title),
              const SizedBox(height: 8),
              Input(placeholder: 'Enter password', obscureText: true, trailing: Icon(PrimeIcons.pencilOutline)),
              const SizedBox(height: 24),
              Text('Keyboard Type (Number)', style: theme.textTheme.title),
              const SizedBox(height: 8),
              const Input(placeholder: '12345', keyboardType: TextInputType.number),
            ],
          ),
        ),
      ),
    );
  }
}
