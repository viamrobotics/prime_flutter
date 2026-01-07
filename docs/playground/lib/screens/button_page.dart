import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum PlaygroundButtonStyle {
  primary,
  secondary,
  destructive,
  outlineDestructive, // Maps to outlineDanger
  ghost,
  disabled, // We can treat disabled as a style for demo purposes or handle separate logic
  success,
  fullWidth,
  withIcon,
  loading,
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
          PlaygroundButtonStyle.success => Button(label: const Text('Success'), onPressed: () {}, variant: ButtonVariant.success),
          PlaygroundButtonStyle.fullWidth => Button(
            label: const Text('Full Width'),
            onPressed: () {},
            variant: ButtonVariant.primary,
            fullWidth: true,
          ),
          PlaygroundButtonStyle.withIcon => Button(
            label: const Text('With Icon'),
            icon: const Icon(PrimeIcons.plus),
            onPressed: () {},
            variant: ButtonVariant.primary,
          ),
          PlaygroundButtonStyle.loading => Button(label: const Text('Loading...'), icon: const Progress(), onPressed: null),
        },
      ),
    );
  }
}
