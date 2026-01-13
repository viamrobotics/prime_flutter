import 'package:flutter/material.dart' hide Slider;
import 'package:prime_flutter/prime_flutter.dart';

class SliderScreen extends StatefulWidget {
  const SliderScreen({super.key});

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  double _value1 = 0.5;
  double _value2 = 0.2;
  double _value3 = 0.8;
  double _rangeValue1 = 50.0;
  double _rangeValue2 = 25.0;
  double _discreteValue = 0.2;
  double _customColorValue = 0.6;
  double _releaseValue = 0.4;

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Slider')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                title: 'Default',
                children: [
                  Slider(value: _value1, onChanged: (v) => setState(() => _value1 = v)),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: 'Varying Values',
                children: [
                  Text('Low Value: ${_value2.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Slider(value: _value2, onChanged: (v) => setState(() => _value2 = v)),
                  const SizedBox(height: 24),
                  Text('High Value: ${_value3.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Slider(value: _value3, onChanged: (v) => setState(() => _value3 = v)),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: 'Custom Range',
                children: [
                  Text('Range: 0 to 100: ${_rangeValue1.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  Slider(value: _rangeValue1, min: 0, max: 100, onChanged: (v) => setState(() => _rangeValue1 = v)),
                  const SizedBox(height: 24),
                  Text('Range: 10 to 50: ${_rangeValue2.toStringAsFixed(1)}'),
                  const SizedBox(height: 8),
                  Slider(value: _rangeValue2, min: 10, max: 50, onChanged: (v) => setState(() => _rangeValue2 = v)),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: 'Divisions / Discrete',
                children: [
                  Text('5 Divisions (0.0 to 1.0): ${_discreteValue.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Slider(value: _discreteValue, divisions: 5, onChanged: (v) => setState(() => _discreteValue = v)),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: 'Custom Colors',
                children: [
                  Text('Custom Theme (Divisions: 5): ${_customColorValue.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Slider(
                    value: _customColorValue,
                    divisions: 5,
                    activeTrackColor: Colors.purple,
                    inactiveTrackColor: Colors.purple.withOpacity(0.2),
                    thumbColor: Colors.purple,
                    activeTickColor: Colors.white,
                    inactiveTickColor: Colors.purple.withOpacity(0.5),
                    onChanged: (v) => setState(() => _customColorValue = v),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: 'Handle Release',
                children: [
                  Text('Value: ${_releaseValue.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Slider(
                    value: _releaseValue,
                    onChanged: (v) => setState(() => _releaseValue = v),
                    onChangeEnd: (_) => setState(() => _releaseValue = 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: PrimeTypography.heading.copyWith(fontSize: 20)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PrimeColors.gray0,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PrimeColors.gray2),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ],
    );
  }
}

class SliderPlayground extends StatefulWidget {
  final String? variant;
  const SliderPlayground({super.key, this.variant});

  @override
  State<SliderPlayground> createState() => _SliderPlaygroundState();
}

class _SliderPlaygroundState extends State<SliderPlayground> {
  double _value = 0.5;
  double _rangeValue = 50.0;
  double _discreteValue = 0.2;
  double _customColorValue = 0.6;

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (widget.variant) {
      case 'range':
        content = Slider(value: _rangeValue, min: 0, max: 100, onChanged: (v) => setState(() => _rangeValue = v));
        break;
      case 'discrete':
        content = Slider(value: _discreteValue, divisions: 5, onChanged: (v) => setState(() => _discreteValue = v));
        break;
      case 'custom':
        content = Slider(
          value: _customColorValue,
          divisions: 5,
          activeTrackColor: Colors.purple,
          inactiveTrackColor: Colors.purple.withOpacity(0.2),
          thumbColor: Colors.purple,
          activeTickColor: Colors.white,
          inactiveTickColor: Colors.purple.withOpacity(0.5),
          onChanged: (v) => setState(() => _customColorValue = v),
        );
        break;
      case 'default':
      default:
        content = Slider(value: _value, onChanged: (v) => setState(() => _value = v));
        break;
    }

    return PrimeScaffold(
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24.0), child: content),
      ),
    );
  }
}
