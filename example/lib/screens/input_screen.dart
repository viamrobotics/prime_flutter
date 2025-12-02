import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class InputScreen extends StatelessWidget {
  const InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Input')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Basic Input', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Input(placeholder: 'Enter text...'),
              const SizedBox(height: 24),
              const Text('With Leading Icon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Input(placeholder: 'Search...', leading: Icon(PrimeIcons.magnify)),
              const SizedBox(height: 24),
              const Text('With Trailing Icon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Input(placeholder: 'Enter password', obscureText: true, trailing: Icon(PrimeIcons.pencilOutline)),
              const SizedBox(height: 24),
              const Text('Keyboard Type (Number)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Input(placeholder: '12345', keyboardType: TextInputType.number),
            ],
          ),
        ),
      ),
    );
  }
}
