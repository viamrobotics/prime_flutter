import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum DropdownPageStyle { basic, customLabels, disabled }

const List<String> _options = ['Apple', 'Banana', 'Orange', 'Mango', 'Grape'];

class DropdownPage extends StatefulWidget {
  final DropdownPageStyle style;

  const DropdownPage({super.key, required this.style});

  @override
  State<DropdownPage> createState() => _DropdownPageState();
}

class _DropdownPageState extends State<DropdownPage> {
  String? _value;

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: SizedBox(
            width: 300,
            child: switch (widget.style) {
            DropdownPageStyle.basic => PrimeDropdown<String>(
                value: _value,
                placeholder: 'Select a fruit',
                items: _options,
                onChanged: (v) => setState(() => _value = v),
              ),
            DropdownPageStyle.customLabels => PrimeDropdown<String>(
                value: _value,
                placeholder: 'Choose one',
                items: _options,
                itemBuilder: (s) => Text(s.toUpperCase()),
                onChanged: (v) => setState(() => _value = v),
              ),
            DropdownPageStyle.disabled => PrimeDropdown<String>(
                value: 'Apple',
                placeholder: 'Disabled',
                items: _options,
                onChanged: null,
                disabled: true,
              ),
          },
          ),
        ),
      ),
    );
  }
}
