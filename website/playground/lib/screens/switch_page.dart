import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum SwitchPageStyle { basic, disabled }

class SwitchPage extends StatefulWidget {
  final SwitchPageStyle style;

  const SwitchPage({super.key, required this.style});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: switch (widget.style) {
          SwitchPageStyle.basic => SwitchToggle(
              value: _value,
              onChanged: (v) => setState(() => _value = v),
            ),
          SwitchPageStyle.disabled => SwitchToggle(
              value: _value,
              disabled: true,
              onChanged: (v) => setState(() => _value = v),
            ),
        },
      ),
    );
  }
}
