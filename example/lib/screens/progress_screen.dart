import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(
        leading: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(PrimeIcons.chevronLeft, size: 24)),
        title: const Text('Progress'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(context, title: 'Default', children: [const Progress()]),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: 'Sizes',
                children: [
                  const Progress(size: 24),
                  const SizedBox(width: 24),
                  const Progress(size: 48),
                  const SizedBox(width: 24),
                  const Progress(size: 64),
                ],
              ),
              const SizedBox(height: 32),
              _buildSection(
                context,
                title: 'Variants',
                children: [
                  const Progress(variant: ProgressVariant.dark),
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: PrimeColors.black, borderRadius: BorderRadius.circular(8)),
                    child: const Progress(variant: ProgressVariant.light),
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
            color: PrimeColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PrimeColors.gray2),
          ),
          child: Row(children: children),
        ),
      ],
    );
  }
}
