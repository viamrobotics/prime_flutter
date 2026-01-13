import 'package:flutter/material.dart' hide Slider;
import 'package:prime_flutter/prime_flutter.dart';

class SliderPage extends StatefulWidget {
  final String? variant;
  const SliderPage({super.key, this.variant});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  double _value = 0.5;
  double _rangeValue = 50.0;
  double _discreteValue = 0.2;
  double _customColorValue = 0.6;

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (widget.variant) {
      case 'range':
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Value: ${_rangeValue.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Slider(value: _rangeValue, min: 0, max: 100, onChanged: (v) => setState(() => _rangeValue = v)),
          ],
        );
        break;
      case 'discrete':
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Value: ${_discreteValue.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Slider(value: _discreteValue, divisions: 5, onChanged: (v) => setState(() => _discreteValue = v)),
          ],
        );
        break;
      case 'custom':
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Value: ${_customColorValue.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Slider(
              value: _customColorValue,
              divisions: 5,
              activeTrackColor: Colors.purple,
              inactiveTrackColor: Colors.purple.withValues(alpha: 0.2),
              thumbColor: Colors.purple,
              activeTickColor: Colors.white,
              inactiveTickColor: Colors.purple.withValues(alpha: 0.5),
              onChanged: (v) => setState(() => _customColorValue = v),
            ),
          ],
        );
        break;
      case 'default':
      default:
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Value: ${_value.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Slider(value: _value, onChanged: (v) => setState(() => _value = v), onChangeEnd: (v) => print('Slider ended at: $v')),
          ],
        );
        break;
    }

    return PrimeScaffold(
      body: Center(
        child: Padding(padding: const EdgeInsets.all(24.0), child: content),
      ),
    );
  }
}
