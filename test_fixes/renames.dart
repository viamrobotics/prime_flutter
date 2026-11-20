import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

void main() {
  runApp(
    PrimeApp(
      home: PrimeScaffold(
        appBar: const PrimeAppBar(title: Text('Renames')),
        body: Column(
          children: [
            SwitchToggle(value: true, onChanged: (_) {}),
            PrimeDropdown<String>(items: const ['a'], onChanged: (_) {}),
            PrimeMultiDropdown<String>(items: const ['a'], onChanged: (_) {}),
            const PanelTextField(label: 'Name'),
            const PrimeTextField(placeholder: 'Raw'),
          ],
        ),
      ),
    ),
  );
}

Future<void> ask(BuildContext context) async {
  const PrimeDialogAction<bool> ok = PrimeDialogAction<bool>(label: Text('OK'), value: true);
  await PrimeDialog.show<bool>(context: context, title: const Text('Sure?'), actions: [ok], child: const Text('Body'));
}

PrimeTextFieldState? stateOf(GlobalKey<PrimeTextFieldState> key) => key.currentState;
