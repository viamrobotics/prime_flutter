import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool _value1 = false;
  bool _value2 = true;
  bool _value3 = false;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Switch Toggle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Switch', style: theme.textTheme.title),
            const SizedBox(height: 8),
            Row(
              children: [
                SwitchToggle(
                  value: _value1,
                  onChanged: (v) => setState(() => _value1 = v),
                ),
                const SizedBox(width: 16),
                Text(_value1 ? 'On' : 'Off', style: theme.textTheme.bodyDefault),
              ],
            ),
            const SizedBox(height: 24),
            Text('Pre-selected', style: theme.textTheme.title),
            const SizedBox(height: 8),
            SwitchToggle(
              value: _value2,
              onChanged: (v) => setState(() => _value2 = v),
            ),
            const SizedBox(height: 24),
            Text('Disabled', style: theme.textTheme.title),
            const SizedBox(height: 8),
            Row(
              children: [
                SwitchToggle(
                  value: false,
                  disabled: true,
                  onChanged: (v) {},
                ),
                const SizedBox(width: 16),
                SwitchToggle(
                  value: true,
                  disabled: true,
                  onChanged: (v) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('In List Item', style: theme.textTheme.title),
            const SizedBox(height: 8),
            ListItem(
              title: const Text('Notifications'),
              subtitle: const Text('Enable push notifications'),
              trailing: SwitchToggle(
                value: _value3,
                onChanged: (v) => setState(() => _value3 = v),
              ),
              onPressed: () => setState(() => _value3 = !_value3),
            ),
          ],
        ),
      ),
    );
  }
}
