import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ButtonScreen extends StatelessWidget {
  const ButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PrimeIcons.chevronLeft, size: 20),
                      SizedBox(width: 4),
                      Text('Back', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const Text('Buttons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
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
                  Button(label: 'Add Item', icon: PrimeIcons.plus, onPressed: () {}, variant: ButtonVariant.primary),
                  Button(label: 'Settings', icon: PrimeIcons.cog, onPressed: () {}, variant: ButtonVariant.secondary),
                  Button(label: 'Delete', icon: PrimeIcons.trashCanOutline, onPressed: () {}, variant: ButtonVariant.danger),
                ],
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
          child: child,
        ),
      ],
    );
  }
}
