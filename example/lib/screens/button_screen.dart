import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(title: Text('Buttons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buttons', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Buttons allow users to take actions, and make choices, with a single tap.',
              style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
            ),
            const SizedBox(height: 32),

            // Variants
            _buildSection(
              title: 'Variants',
              description: 'Buttons come in different variants for different levels of emphasis.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Button(label: 'Primary', onPressed: () {}, variant: ButtonVariant.primary),
                  Button(label: 'Secondary', onPressed: () {}, variant: ButtonVariant.secondary),
                  Button(label: 'Ghost', onPressed: () {}, variant: ButtonVariant.ghost),
                  Button(label: 'Success', onPressed: () {}, variant: ButtonVariant.success),
                  Button(label: 'Danger', onPressed: () {}, variant: ButtonVariant.danger),
                  Button(label: 'Outline Danger', onPressed: () {}, variant: ButtonVariant.outlineDanger),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Full width
            _buildSection(
              title: 'Full Width',
              description: 'Buttons can be full width to span the width of the container. Set fullWidth to true.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Button(label: 'Full Width', onPressed: () {}, variant: ButtonVariant.primary, fullWidth: true),
                  Button(icon: const Icon(PrimeIcons.plus), label: 'Add Component', onPressed: () {}, fullWidth: true),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // With Icons
            _buildSection(
              title: 'With Icons',
              description: 'Buttons can include icons to provide more context.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  Button(label: 'Add Item', icon: const Icon(PrimeIcons.plus), onPressed: () {}, variant: ButtonVariant.primary),
                  Button(label: 'Settings', icon: const Icon(PrimeIcons.cog), onPressed: () {}, variant: ButtonVariant.secondary),
                  Button(
                    label: 'Delete Component',
                    icon: const Icon(PrimeIcons.trashCanOutline),
                    onPressed: () {},
                    variant: ButtonVariant.ghost,
                  ),
                  Button(label: 'Delete', icon: const Icon(PrimeIcons.trashCanOutline), onPressed: () {}, variant: ButtonVariant.danger),
                  Button(
                    label: 'Delete Component',
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
              title: 'Loading State',
              description: 'Buttons can be in a loading state to indicate progress.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [Button(label: 'Loading...', icon: const Progress(), onPressed: null)],
              ),
            ),

            const SizedBox(height: 40),

            // Disabled State
            _buildSection(
              title: 'Disabled State',
              description: 'Buttons can be disabled to prevent interaction.',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  const Button(label: 'Disabled Primary', disabled: true, variant: ButtonVariant.primary),
                  const Button(label: 'Disabled Secondary', disabled: true, variant: ButtonVariant.secondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String description, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF757575))),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
