import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Progress')),
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
                  const Progress(), // Defaults to dark/iconPrimary
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: PrimeColors.gray9, borderRadius: BorderRadius.circular(8)),
                    child: const Progress(color: PrimeColors.gray0), // Explicit light color for dark background
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
            color: PrimeColors.gray0,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PrimeColors.gray2),
          ),
          child: Row(children: children),
        ),
      ],
    );
  }
}
