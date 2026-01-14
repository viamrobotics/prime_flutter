import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class FilterPillScreen extends StatefulWidget {
  const FilterPillScreen({super.key});

  @override
  State<FilterPillScreen> createState() => _FilterPillScreenState();
}

class _FilterPillScreenState extends State<FilterPillScreen> {
  final Set<String> _selectedTags = {'Error', 'Warning'};
  Set<String> _selectedGroup = {'Red', 'Green'};
  Set<String> _selectedSearch = {'Search'};

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Filter Pills')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Group - default colors', style: theme.textTheme.title),
            const SizedBox(height: 16),
            FilterGroup<String>(
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
            ),
            const SizedBox(height: 32),
            Text('Filter Group - custom colors', style: theme.textTheme.title),
            const SizedBox(height: 16),
            FilterGroup<String>(
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
            ),
            const SizedBox(height: 32),
            Text('Filter Group - prepend with custom Filter Pill', style: theme.textTheme.title),
            const SizedBox(height: 16),
            Row(
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
          ],
        ),
      ),
    );
  }
}
