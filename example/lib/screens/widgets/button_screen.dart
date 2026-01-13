import 'package:flutter/widgets.dart';

import 'package:prime_flutter/prime_flutter.dart';

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);

    return PrimeScaffold(
      appBar: PrimeAppBar(title: Text('Buttons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buttons', style: theme.textTheme.heading.copyWith(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'Buttons allow users to take actions, and make choices, with a single tap.',
              style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textSecondary),
            ),
            const SizedBox(height: 32),

            // Variants
            _buildSection(
              context,
              title: 'Variants',
              description: 'Buttons come in different variants for different levels of emphasis.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Button(label: const Text('Primary'), onPressed: () {}, variant: ButtonVariant.primary),
                  Button(label: const Text('Secondary'), onPressed: () {}, variant: ButtonVariant.secondary),
                  Button(label: const Text('Ghost'), onPressed: () {}, variant: ButtonVariant.ghost),
                  Button(label: const Text('Success'), onPressed: () {}, variant: ButtonVariant.success),
                  Button(label: const Text('Danger'), onPressed: () {}, variant: ButtonVariant.danger),
                  Button(label: const Text('Outline Danger'), onPressed: () {}, variant: ButtonVariant.outlineDanger),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Full width
            _buildSection(
              context,
              title: 'Full Width',
              description: 'Buttons can be full width to span the width of the container. Set fullWidth to true.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Button(label: const Text('Full Width'), onPressed: () {}, variant: ButtonVariant.primary, fullWidth: true),
                  Button(icon: const Icon(PrimeIcons.plus), label: const Text('Add Component'), onPressed: () {}, fullWidth: true),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // With Icons
            _buildSection(
              context,
              title: 'With Icons',
              description: 'Buttons can include icons to provide more context.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Button(
                    label: const Text('Add Item'),
                    icon: const Icon(PrimeIcons.plus),
                    onPressed: () {},
                    variant: ButtonVariant.primary,
                  ),
                  Button(
                    label: const Text('Settings'),
                    icon: const Icon(PrimeIcons.cog),
                    onPressed: () {},
                    variant: ButtonVariant.secondary,
                  ),
                  Button(
                    label: const Text('Delete Component'),
                    icon: const Icon(PrimeIcons.trashCanOutline),
                    onPressed: () {},
                    variant: ButtonVariant.ghost,
                  ),
                  Button(
                    label: const Text('Delete'),
                    icon: const Icon(PrimeIcons.trashCanOutline),
                    onPressed: () {},
                    variant: ButtonVariant.danger,
                  ),
                  Button(
                    label: const Text('Delete Component'),
                    icon: const Icon(PrimeIcons.trashCanOutline),
                    onPressed: () {},
                    variant: ButtonVariant.outlineDanger,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Loading State
            _buildSection(
              context,
              title: 'Loading State',
              description: 'Buttons can be in a loading state to indicate progress.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [Button(label: const Text('Loading...'), icon: const Progress(), onPressed: null)],
              ),
            ),

            const SizedBox(height: 40),

            // Disabled State
            _buildSection(
              context,
              title: 'Disabled State',
              description: 'Buttons can be disabled to prevent interaction.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  const Button(label: Text('Disabled Primary'), disabled: true, variant: ButtonVariant.primary),
                  const Button(label: Text('Disabled Secondary'), disabled: true, variant: ButtonVariant.secondary),
                  const Button(label: Text('Disabled Ghost'), disabled: true, variant: ButtonVariant.ghost),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String description, required Widget child}) {
    final theme = PrimeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.heading),
        const SizedBox(height: 8),
        Text(description, style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textSecondary)),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
