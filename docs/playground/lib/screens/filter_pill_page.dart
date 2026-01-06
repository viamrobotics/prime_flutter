import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum FilterPillPageStyle { basic, selected, withLeading }

class FilterPillPage extends StatelessWidget {
  final FilterPillPageStyle style;

  const FilterPillPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: switch (style) {
          FilterPillPageStyle.basic => FilterPill(label: const Text('Filter'), onTap: () {}),
          FilterPillPageStyle.selected => FilterPill(label: const Text('Selected'), isSelected: true, onTap: () {}),
          FilterPillPageStyle.withLeading => FilterPill(
            label: const Text('With Icon'),
            leading: const Icon(PrimeIcons.viamFlutter, size: 16),
            onTap: () {},
          ),
        },
      ),
    );
  }
}
