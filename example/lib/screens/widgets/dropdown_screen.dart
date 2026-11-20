import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class DropdownScreen extends StatefulWidget {
  const DropdownScreen({super.key});

  @override
  State<DropdownScreen> createState() => _DropdownScreenState();
}

class _DropdownScreenState extends State<DropdownScreen> {
  String? _fruit;
  String? _customLabel;
  List<String> _multi = [];

  static const List<String> _fruits = ['Apple', 'Banana', 'Orange', 'Mango', 'Grape'];

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Scaffold(
      appBar: const AppBar(title: Text('Dropdown')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic', style: theme.textTheme.title),
            const SizedBox(height: 8),
            Dropdown<String>(
              value: _fruit,
              placeholder: 'Select a fruit',
              items: _fruits,
              onChanged: (v) => setState(() => _fruit = v),
            ),
            const SizedBox(height: 24),
            Text('With custom item labels', style: theme.textTheme.title),
            const SizedBox(height: 8),
            Dropdown<String>(
              value: _customLabel,
              placeholder: 'Choose one',
              items: _fruits,
              itemBuilder: (s) => Text('${s.toUpperCase()}'),
              onChanged: (v) => setState(() => _customLabel = v),
            ),
            const SizedBox(height: 24),
            Text('Multiselect', style: theme.textTheme.title),
            const SizedBox(height: 8),
            MultiDropdown<String>(
              value: _multi,
              placeholder: 'Select fruits',
              items: _fruits,
              onChanged: (v) => setState(() => _multi = v),
            ),
            const SizedBox(height: 24),
            Text('Disabled', style: theme.textTheme.title),
            const SizedBox(height: 8),
            Dropdown<String>(
              value: 'Apple',
              placeholder: 'Disabled',
              items: _fruits,
              onChanged: null,
              disabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
