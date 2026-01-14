import 'package:flutter/material.dart' hide SegmentedButton;
import 'package:prime_flutter/prime_flutter.dart';

class SegmentedButtonPage extends StatefulWidget {
  final String? variant;

  const SegmentedButtonPage({super.key, this.variant});

  @override
  State<SegmentedButtonPage> createState() => _SegmentedButtonPageState();
}

class _SegmentedButtonPageState extends State<SegmentedButtonPage> {
  // Single select state
  Set<String> _singleSelected = {'Daily'};

  // Multi select state
  Set<String> _multiSelected = {'Mon', 'Tue', 'Wed'};

  // Icon select state
  Set<String> _iconSelected = {'M'};

  // Font select state
  Set<String> _fontSelected = {'Code'};

  @override
  Widget build(BuildContext context) {
    if (widget.variant == 'multi') {
      return _buildMultiSelect();
    } else if (widget.variant == 'icons') {
      return _buildIcons();
    } else if (widget.variant == 'font') {
      return _buildMultiFont();
    }
    return _buildSingleSelect();
  }

  Widget _buildSingleSelect() {
    return Center(
      child: SegmentedButton<String>(
        segments: const {'Daily': Text('Daily'), 'Weekly': Text('Weekly'), 'Monthly': Text('Monthly')},
        selected: _singleSelected,
        onSelectionChanged: (newSelection) {
          setState(() {
            _singleSelected = newSelection;
          });
        },
      ),
    );
  }

  Widget _buildMultiSelect() {
    return Center(
      child: SegmentedButton<String>(
        segments: const {
          'Mon': Text('M'),
          'Tue': Text('T'),
          'Wed': Text('W'),
          'Thu': Text('T'),
          'Fri': Text('F'),
          'Sat': Text('S'),
          'Sun': Text('S'),
        },
        selected: _multiSelected,
        multiSelect: true,
        allowEmpty: true,
        onSelectionChanged: (newSelection) {
          setState(() {
            _multiSelected = newSelection;
          });
        },
      ),
    );
  }

  Widget _buildIcons() {
    return Center(
      child: SegmentedButton<String>(
        segments: {
          'First': _buildIconLabel(PrimeIcons.chevronLeft, 'First'),
          'Center': _buildIconLabel(PrimeIcons.minus, 'Center'),
          'Last': _buildIconLabel(PrimeIcons.chevronRight, 'Last'),
        },
        selected: _iconSelected,
        onSelectionChanged: (newSelection) {
          setState(() {
            _iconSelected = newSelection;
          });
        },
      ),
    );
  }

  Widget _buildMultiFont() {
    return Center(
      child: SegmentedButton<String>(
        segments: {'Code': _buildMonoLabel('Code'), 'Build': _buildMonoLabel('Build'), 'Test': _buildMonoLabel('Test')},
        selected: _fontSelected,
        onSelectionChanged: (newSelection) {
          setState(() {
            _fontSelected = newSelection;
          });
        },
      ),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)]);
  }

  Widget _buildMonoLabel(String label) {
    return Builder(
      builder: (context) {
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
