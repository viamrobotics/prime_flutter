import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class FilterPillScreen extends StatefulWidget {
  const FilterPillScreen({super.key});

  @override
  State<FilterPillScreen> createState() => _FilterPillScreenState();
}

class _FilterPillScreenState extends State<FilterPillScreen> {
  String _selectedFilter = 'All';
  final Set<String> _selectedTags = {'Error', 'Warning'};

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
            Text('Single Selection', style: theme.textTheme.title),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterPill(label: Text('All'), isSelected: _selectedFilter == 'All', onTap: () => setState(() => _selectedFilter = 'All')),
                FilterPill(
                  label: Text('Error'),
                  color: theme.colorScheme.statusDangerDark,
                  isSelected: _selectedFilter == 'Error',
                  onTap: () => setState(() => _selectedFilter = 'Error'),
                ),
                FilterPill(
                  label: Text('Warning'),
                  color: theme.colorScheme.statusWarningDark,
                  isSelected: _selectedFilter == 'Warning',
                  onTap: () => setState(() => _selectedFilter = 'Warning'),
                ),
                FilterPill(
                  label: Text('Info'),
                  color: theme.colorScheme.statusInfoDark,
                  isSelected: _selectedFilter == 'Info',
                  onTap: () => setState(() => _selectedFilter = 'Info'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Multiple Selection', style: theme.textTheme.title),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterPill(
                  label: Text('Error'),
                  color: theme.colorScheme.statusDangerDark,
                  isSelected: _selectedTags.contains('Error'),
                  onTap: () => setState(() => _selectedTags.contains('Error') ? _selectedTags.remove('Error') : _selectedTags.add('Error')),
                ),
                FilterPill(
                  label: Text('Warning'),
                  color: theme.colorScheme.statusWarningDark,
                  isSelected: _selectedTags.contains('Warning'),
                  onTap: () =>
                      setState(() => _selectedTags.contains('Warning') ? _selectedTags.remove('Warning') : _selectedTags.add('Warning')),
                ),
                FilterPill(
                  label: Text('Info'),
                  color: theme.colorScheme.statusInfoDark,
                  isSelected: _selectedTags.contains('Info'),
                  onTap: () => setState(() => _selectedTags.contains('Info') ? _selectedTags.remove('Info') : _selectedTags.add('Info')),
                ),
                FilterPill(
                  label: Text('Debug'),
                  color: theme.colorScheme.statusSuccessDark,
                  isSelected: _selectedTags.contains('Debug'),
                  onTap: () => setState(() => _selectedTags.contains('Debug') ? _selectedTags.remove('Debug') : _selectedTags.add('Debug')),
                ),
                FilterPill(
                  label: Text('Overflow'),
                  color: Color.fromARGB(255, 208, 53, 229),
                  isSelected: _selectedTags.contains('Overflow'),
                  onTap: () =>
                      setState(() => _selectedTags.contains('Overflow') ? _selectedTags.remove('Overflow') : _selectedTags.add('Overflow')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
