// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum FilterPillPageStyle { basicToggle, iconToggle, filterGroupDefault, filterGroupCustom, filterGroupComposite }

class FilterPillPage extends StatelessWidget {
  final FilterPillPageStyle style;

  const FilterPillPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: switch (style) {
          FilterPillPageStyle.basicToggle => const _BasicToggleExample(),
          FilterPillPageStyle.iconToggle => const _IconToggleExample(),
          FilterPillPageStyle.filterGroupDefault => const _FilterGroupDefaultExample(),
          FilterPillPageStyle.filterGroupCustom => const _FilterGroupCustomExample(),
          FilterPillPageStyle.filterGroupComposite => const _FilterGroupCompositeExample(),
        },
      ),
    );
  }
}

class _BasicToggleExample extends StatefulWidget {
  const _BasicToggleExample();

  @override
  State<_BasicToggleExample> createState() => _BasicToggleExampleState();
}

class _BasicToggleExampleState extends State<_BasicToggleExample> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return FilterPill(label: Text('Example'), isSelected: _isSelected, onTap: () => setState(() => _isSelected = !_isSelected));
  }
}

class _IconToggleExample extends StatefulWidget {
  const _IconToggleExample();

  @override
  State<_IconToggleExample> createState() => _IconToggleExampleState();
}

class _IconToggleExampleState extends State<_IconToggleExample> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        FilterPill(
          label: const Text('With Icon'),
          leading: const Icon(PrimeIcons.viamFlutter, size: 16),
          isSelected: _isSelected,
          onTap: () => setState(() => _isSelected = !_isSelected),
        ),
        FilterPill(
          label: const Icon(PrimeIcons.magnify, size: 20),
          isSelected: _isSelected,
          onTap: () => setState(() => _isSelected = !_isSelected),
        ),
      ],
    );
  }
}

class _FilterGroupDefaultExample extends StatefulWidget {
  const _FilterGroupDefaultExample();

  @override
  State<_FilterGroupDefaultExample> createState() => _FilterGroupDefaultExampleState();
}

class _FilterGroupDefaultExampleState extends State<_FilterGroupDefaultExample> {
  Set<String> _selectedGroup = {'Red', 'Green'};

  @override
  Widget build(BuildContext context) {
    return FilterGroup<String>(
      items: [
        FilterItem(value: 'Arm', label: const Text('Arm')),
        FilterItem(value: 'Base', label: const Text('Base')),
        FilterItem(value: 'Board', label: const Text('Board')),
        FilterItem(value: 'Sensor', label: const Text('Sensor')),
        const FilterItem(value: 'Servo', label: Text('Servo')),
      ],
      selected: _selectedGroup,
      onSelectionChanged: (newSelection) {
        setState(() {
          _selectedGroup = newSelection;
        });
      },
    );
  }
}

class _FilterGroupCustomExample extends StatefulWidget {
  const _FilterGroupCustomExample();

  @override
  State<_FilterGroupCustomExample> createState() => _FilterGroupCustomExampleState();
}

class _FilterGroupCustomExampleState extends State<_FilterGroupCustomExample> {
  Set<String> _selectedGroup = {'Red', 'Green'};

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return FilterGroup<String>(
      items: [
        FilterItem(value: 'Red', label: const Text('Red'), activeColor: theme.colorScheme.statusDangerDark),
        FilterItem(value: 'Orange', label: const Text('Orange'), activeColor: theme.colorScheme.statusWarningDark),
        FilterItem(value: 'Green', label: const Text('Green'), activeColor: theme.colorScheme.statusSuccessDark),
        FilterItem(value: 'Blue', label: const Text('Blue'), activeColor: theme.colorScheme.statusInfoDark),
        const FilterItem(value: 'Purple', label: Text('Purple'), activeColor: Color(0xFF9C27B0)),
      ],
      selected: _selectedGroup,
      onSelectionChanged: (newSelection) {
        setState(() {
          _selectedGroup = newSelection;
        });
      },
    );
  }
}

class _FilterGroupCompositeExample extends StatefulWidget {
  const _FilterGroupCompositeExample();

  @override
  State<_FilterGroupCompositeExample> createState() => _FilterGroupCompositeExampleState();
}

class _FilterGroupCompositeExampleState extends State<_FilterGroupCompositeExample> {
  Set<String> _selectedSearch = {'Search'};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterPill(
            label: const Icon(PrimeIcons.magnify),
            isSelected: _selectedSearch.contains('Search'),
            // give this pill custom funcitonality, such as search or making a bottom sheet appear.
            onTap: () =>
                setState(() => _selectedSearch.contains('Search') ? _selectedSearch.remove('Search') : _selectedSearch.add('Search')),
          ),
          const SizedBox(width: 8),
          FilterGroup<String>(
            items: [
              FilterItem(value: 'Arm', label: const Text('Arm')),
              FilterItem(value: 'Base', label: const Text('Base')),
              FilterItem(value: 'Board', label: const Text('Board')),
              FilterItem(value: 'Sensor', label: const Text('Sensor')),
              FilterItem(value: 'Servo', label: Text('Servo')),
            ],
            selected: _selectedSearch,
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedSearch = newSelection;
              });
            },
          ),
        ],
      ),
    );
  }
}
