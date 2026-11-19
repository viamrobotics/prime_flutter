import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

/// Shared page chrome for the component showcase screens.
class ShowcasePage extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> sections;

  const ShowcasePage({super.key, required this.title, required this.description, required this.sections});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return PrimeScaffold(
      appBar: PrimeAppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.heading.copyWith(fontSize: 32)),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textSecondary)),
            for (final section in sections) ...[const SizedBox(height: 32), section],
          ],
        ),
      ),
    );
  }
}

class ShowcaseSection extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const ShowcaseSection({super.key, required this.title, this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.heading),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(description!, style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textSecondary)),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
