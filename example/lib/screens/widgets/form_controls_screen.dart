import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'showcase.dart';

class FormControlsScreen extends StatefulWidget {
  const FormControlsScreen({super.key});

  @override
  State<FormControlsScreen> createState() => _FormControlsScreenState();
}

class _FormControlsScreenState extends State<FormControlsScreen> {
  num? _count = 3;
  num? _speed = 0.5;
  num _volume = 40;
  Map<String, num> _position = {'x': 0, 'y': 1.5, 'z': -2};
  String? _frequency = 'daily';
  String _component = '';
  List<String> _tags = ['arm'];
  String? _start = 'now-15m';
  DateTime? _date = DateTime(2026, 3, 10);
  DateRange? _period = DateRange(start: DateTime(2026, 3, 10), end: DateTime(2026, 3, 16));
  String? _resource = 'motor';
  bool _terms = false;
  bool _updates = true;

  static final _components = SelectOption.fromStrings(['Arm', 'Base', 'Board', 'Camera', 'Gantry', 'Gripper', 'Motor', 'Sensor']);

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Form controls',
      description: 'Labels, numeric inputs, radios, searchable selects and the relative time picker.',
      sections: [
        const ShowcaseSection(
          title: 'Label and input states',
          child: Column(
            spacing: 12,
            children: [
              Label(label: Text('Name'), required: true, child: Input(placeholder: 'Machine name')),
              Label(label: Text('Notes'), detail: '(optional)', child: Input(state: InputState.info)),
              Label(label: Text('Warning'), child: Input(state: InputState.warn)),
              Label(label: Text('Error'), child: Input(state: InputState.error)),
              Label(label: Text('Disabled'), disabled: true, child: Input(disabled: true, placeholder: 'Disabled')),
              Label(label: Text('Left'), position: LabelPosition.left, child: Input(readOnly: true, placeholder: 'Read only')),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Field, hint, checkbox, textarea',
          description: 'A Field shares required, disabled and state with the parts inside it.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const Field(
                required: true,
                state: InputState.error,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Label(label: Text('Email')),
                    Input(placeholder: 'you@example.com'),
                    Hint(child: Text('Enter a valid address.')),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Label(label: Text('Notes')),
                  Textarea(placeholder: 'Anything else we should know?'),
                  Hint(child: Text('Grows as you type.')),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(checked: _terms, onChanged: (v) => setState(() => _terms = v), label: const Text('Accept the terms')),
                  Checkbox(checked: _updates, onChanged: (v) => setState(() => _updates = v), label: const Text('Send me updates')),
                  Checkbox(checked: false, indeterminate: true, onChanged: (_) {}, label: const Text('Indeterminate')),
                  const Checkbox(checked: true, disabled: true, label: Text('Disabled')),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Numeric inputs',
          description: 'Drag the handle on the slider input to scrub its value.',
          child: Column(
            spacing: 12,
            children: [
              Label(
                label: const Text('Integer'),
                child: NumericInput(type: NumericInputType.integer, value: _count, min: 0, max: 10, onChanged: (v) => setState(() => _count = v)),
              ),
              Label(
                label: const Text('Slider input'),
                child: SliderInput(value: _speed, step: 0.1, min: 0, max: 1, onChanged: (v) => setState(() => _speed = v)),
              ),
              Label(
                label: const Text('Range input'),
                child: RangeInput(value: _volume, step: 10, suffix: '%', onChanged: (v) => setState(() => _volume = v)),
              ),
              VectorInput(values: _position, step: 0.5, onChanged: (v) => setState(() => _position = v)),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Radio',
          child: Radio<String>(
            legend: const Text('Sync frequency'),
            required: true,
            selected: _frequency,
            onChanged: (v) => setState(() => _frequency = v),
            options: const [
              RadioOption(label: 'Daily', value: 'daily', description: 'Every day at midnight'),
              RadioOption(label: 'Weekly', value: 'weekly', icon: PrimeIcons.clockOutline),
              RadioOption(label: 'Custom', value: 'custom', content: Input(placeholder: 'Cron expression')),
              RadioOption(label: 'Never', value: 'never', disabled: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Searchable select',
          child: Column(
            spacing: 12,
            children: [
              Label(
                label: const Text('Component'),
                child: SearchableSelect(
                  options: _components,
                  value: _component,
                  exclusive: true,
                  placeholder: 'Search components',
                  onChanged: (v) => setState(() => _component = v),
                ),
              ),
              Label(
                label: const Text('Tags'),
                child: Multiselect(
                  options: SelectOption.fromStrings(['arm', 'camera', 'lab', 'prod', 'staging']),
                  selected: _tags,
                  clearable: true,
                  placeholder: 'Add tags',
                  onChanged: (v) => setState(() => _tags = v),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Combobox',
          child: Combobox<String>(
            items: const [
              ComboboxItem(value: 'camera', label: 'Camera'),
              ComboboxItem(value: 'motor', label: 'Motor'),
              ComboboxItem(value: 'base', label: 'Base'),
            ],
            value: _resource,
            allowDeselect: true,
            placeholder: 'Search resource types',
            emptyText: 'No matching resource type',
            onChanged: (v) => setState(() => _resource = v),
          ),
        ),
        ShowcaseSection(
          title: 'Date range picker',
          child: DateRangePicker(value: _period, onChanged: (v) => setState(() => _period = v)),
        ),
        ShowcaseSection(
          title: 'Date picker',
          child: DatePicker(value: _date, max: DateTime(2026, 12, 31), onChanged: (v) => setState(() => _date = v)),
        ),
        ShowcaseSection(
          title: 'Relative time picker',
          description: 'Accepts now-15m style expressions or MM/DD/YYYY HH:mm:ss.',
          child: RelativeTimePicker(
            value: _start,
            onChanged: (time) => setState(() => _start = time.value),
            isDateUnavailable: (day) => day.isAfter(DateTime.now()),
          ),
        ),
      ],
    );
  }
}
