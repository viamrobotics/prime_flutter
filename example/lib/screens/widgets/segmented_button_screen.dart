import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class SegmentedButtonScreen extends StatefulWidget {
  const SegmentedButtonScreen({super.key});

  @override
  State<SegmentedButtonScreen> createState() => _SegmentedButtonScreenState();
}

class _SegmentedButtonScreenState extends State<SegmentedButtonScreen> {
  // Single select
  Set<String> _selectedView = {'List'};

  // Multi select
  Set<String> _selectedDays = {'Mon', 'Wed'};

  // Size select (Mapping enum to widget)
  Set<String> _selectedSize = {'M'};

  // Font select
  Set<String> _selectedFontOption = {'Code'};

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(title: const Text('Segmented Button')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            _buildSection(
              title: 'Single Select',
              child: SegmentedButton<String>(
                segments: const {'List': Text('List'), 'Grid': Text('Grid'), 'Map': Text('Map')},
                selected: _selectedView,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedView = newSelection;
                  });
                },
              ),
            ),

            _buildSection(
              title: 'Multi Select',
              child: SegmentedButton<String>(
                segments: const {'Mon': Text('Mon'), 'Tue': Text('Tue'), 'Wed': Text('Wed'), 'Thu': Text('Thu'), 'Fri': Text('Fri')},
                selected: _selectedDays,
                multiSelect: true,
                allowEmpty: true,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedDays = newSelection;
                  });
                },
              ),
            ),

            _buildSection(
              title: 'With Icons',
              child: SegmentedButton<String>(
                segments: {
                  'First': _buildIconLabel(PrimeIcons.chevronLeft, 'First'),
                  'Center': _buildIconLabel(PrimeIcons.minus, 'Center'),
                  'Last': _buildIconLabel(PrimeIcons.chevronRight, 'Last'),
                },
                selected: _selectedSize,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedSize = newSelection;
                  });
                },
              ),
            ),

            _buildSection(
              title: 'Custom Font (Roboto Mono)',
              child: SegmentedButton<String>(
                segments: {'Code': _buildMonoLabel('Code'), 'Build': _buildMonoLabel('Build'), 'Test': _buildMonoLabel('Test')},
                selected: _selectedFontOption,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedFontOption = newSelection;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: PrimeTheme.of(context).textTheme.title),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)]);
  }

  Widget _buildMonoLabel(String label) {
    return Builder(
      builder: (context) {
        // Use textTheme.label properties but allow inheriting weight/color from parent
        final style = PrimeTheme.of(context).textTheme.label;
        return Text(
          label,
          style: TextStyle(
            fontFamily: style.fontFamily,
            package: 'prime_flutter',
            fontSize: style.fontSize,
            height: style.height,
            letterSpacing: style.letterSpacing,
          ),
        );
      },
    );
  }
}
