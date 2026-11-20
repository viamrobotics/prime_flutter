import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum DropdownPageStyle { basic, basicAtBottom, customLabels, multiselect, disabled }

const List<String> _options = ['Apple', 'Banana', 'Orange', 'Mango', 'Grape'];

class DropdownPage extends StatefulWidget {
  final DropdownPageStyle style;

  const DropdownPage({super.key, required this.style});

  @override
  State<DropdownPage> createState() => _DropdownPageState();
}

class _DropdownPageState extends State<DropdownPage> {
  String? _value;
  List<String> _multiValue = [];

  bool get _isAtBottom =>
      widget.style == DropdownPageStyle.basicAtBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: _isAtBottom ? Alignment.bottomCenter : Alignment.topCenter,
        child: Padding(
          padding: _isAtBottom
              ? const EdgeInsets.only(bottom: 24)
              : const EdgeInsets.only(top: 24),
          child: SizedBox(
            width: 300,
            child: switch (widget.style) {
              DropdownPageStyle.basic => Dropdown<String>(
                  value: _value,
                  placeholder: 'Select a fruit',
                  items: _options,
                  onChanged: (v) => setState(() => _value = v),
                ),
              DropdownPageStyle.basicAtBottom => Dropdown<String>(
                  value: _value,
                  placeholder: 'Select a fruit',
                  items: _options,
                  onChanged: (v) => setState(() => _value = v),
                ),
              DropdownPageStyle.customLabels => Dropdown<String>(
                value: _value,
                placeholder: 'Choose one',
                items: _options,
                itemBuilder: (s) => Text(s.toUpperCase()),
                onChanged: (v) => setState(() => _value = v),
              ),
            DropdownPageStyle.multiselect => MultiDropdown<String>(
                value: _multiValue,
                placeholder: 'Select fruits',
                items: _options,
                onChanged: (v) => setState(() => _multiValue = v),
              ),
              DropdownPageStyle.disabled => Dropdown<String>(
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
