import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum FilterPillPageStyle { basic, selected, withLeading, iconLabel, singleSelection, multiSelection }

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
          FilterPillPageStyle.iconLabel => FilterPill(label: const Icon(PrimeIcons.magnify, size: 20), onTap: () {}),
          FilterPillPageStyle.singleSelection => const _SingleSelectionExample(),
          FilterPillPageStyle.multiSelection => const _MultiSelectionExample(),
        },
      ),
    );
  }
}

class _SingleSelectionExample extends StatefulWidget {
  const _SingleSelectionExample();

  @override
  State<_SingleSelectionExample> createState() => _SingleSelectionExampleState();
}

class _SingleSelectionExampleState extends State<_SingleSelectionExample> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterPill(label: const Text('All'), isSelected: _selectedFilter == 'All', onTap: () => setState(() => _selectedFilter = 'All')),
        FilterPill(
          label: const Text('Error'),
          color: theme.colorScheme.statusDangerDark,
          isSelected: _selectedFilter == 'Error',
          onTap: () => setState(() => _selectedFilter = 'Error'),
        ),
        FilterPill(
          label: const Text('Warning'),
          color: theme.colorScheme.statusWarningDark,
          isSelected: _selectedFilter == 'Warning',
          onTap: () => setState(() => _selectedFilter = 'Warning'),
        ),
        FilterPill(
          label: const Text('Info'),
          color: theme.colorScheme.statusInfoDark,
          isSelected: _selectedFilter == 'Info',
          onTap: () => setState(() => _selectedFilter = 'Info'),
        ),
        FilterPill(
          label: const Icon(PrimeIcons.magnify),
          color: theme.colorScheme.statusInfoDark,
          isSelected: _selectedFilter == 'Search',
          onTap: () => setState(() => _selectedFilter = 'Search'),
        ),
      ],
    );
  }
}

class _MultiSelectionExample extends StatefulWidget {
  const _MultiSelectionExample();

  @override
  State<_MultiSelectionExample> createState() => _MultiSelectionExampleState();
}

class _MultiSelectionExampleState extends State<_MultiSelectionExample> {
  final Set<String> _selectedTags = {'Error', 'Warning'};

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterPill(
          label: const Text('Error'),
          color: theme.colorScheme.statusDangerDark,
          isSelected: _selectedTags.contains('Error'),
          onTap: () => setState(() => _selectedTags.contains('Error') ? _selectedTags.remove('Error') : _selectedTags.add('Error')),
        ),
        FilterPill(
          label: const Text('Warning'),
          color: theme.colorScheme.statusWarningDark,
          isSelected: _selectedTags.contains('Warning'),
          onTap: () => setState(() => _selectedTags.contains('Warning') ? _selectedTags.remove('Warning') : _selectedTags.add('Warning')),
        ),
        FilterPill(
          label: const Text('Info'),
          color: theme.colorScheme.statusInfoDark,
          isSelected: _selectedTags.contains('Info'),
          onTap: () => setState(() => _selectedTags.contains('Info') ? _selectedTags.remove('Info') : _selectedTags.add('Info')),
        ),
        FilterPill(
          label: const Text('Debug'),
          color: theme.colorScheme.statusSuccessDark,
          isSelected: _selectedTags.contains('Debug'),
          onTap: () => setState(() => _selectedTags.contains('Debug') ? _selectedTags.remove('Debug') : _selectedTags.add('Debug')),
        ),
      ],
    );
  }
}
