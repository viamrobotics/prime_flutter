import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum PlaygroundButtonStyle {
  primary,
  secondary,
  destructive,
  outlineDestructive, // Maps to outlineDanger
  ghost,
  disabled, // We can treat disabled as a style for demo purposes or handle separate logic
  small,
  large,
}

class ButtonPage extends StatelessWidget {
  const ButtonPage({super.key, required this.style});

  final PlaygroundButtonStyle style;

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: switch (style) {
          PlaygroundButtonStyle.primary => Button(label: const Text('Primary'), onPressed: () {}, variant: ButtonVariant.primary),
          PlaygroundButtonStyle.secondary => Button(label: const Text('Secondary'), onPressed: () {}, variant: ButtonVariant.secondary),
          PlaygroundButtonStyle.destructive => Button(label: const Text('Destructive'), onPressed: () {}, variant: ButtonVariant.danger),
          PlaygroundButtonStyle.outlineDestructive => Button(
            label: const Text('Outline Destructive'),
            onPressed: () {},
            variant: ButtonVariant.outlineDanger,
          ),
          PlaygroundButtonStyle.ghost => Button(label: const Text('Ghost'), onPressed: () {}, variant: ButtonVariant.ghost),
          PlaygroundButtonStyle.disabled => const Button(label: Text('Disabled'), onPressed: null, disabled: true),
          // Assuming Button doesn't support explicit sizes yet based on previous steps,
          // but if it did, this is where we'd put it.
          // For now, I'll just render default.
          PlaygroundButtonStyle.small => Button(label: const Text('Small (Default)'), onPressed: () {}),
          PlaygroundButtonStyle.large => Button(label: const Text('Large (Default)'), onPressed: () {}),
        },
      ),
    );
  }
}
