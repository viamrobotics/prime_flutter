import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'showcase.dart';

class ToolPanelScreen extends StatefulWidget {
  const ToolPanelScreen({super.key});

  @override
  State<ToolPanelScreen> createState() => _ToolPanelScreenState();
}

class _ToolPanelScreenState extends State<ToolPanelScreen> {
  num? _fov = 60;
  PointValue _position = const PointValue(x: 0, y: 1.5, z: -2);
  PointValue _size = const PointValue(x: 1920, y: 1080);
  num _intensity = 0.8;
  num _exposure = 2;
  String? _projection = 'Perspective';
  Set<String> _mode = {'orbit'};

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      title: 'Tool panel',
      description: 'Dense controls for inspectors and tool panels. Drag a number field label sideways to scrub its value.',
      sections: [
        ShowcaseSection(
          title: 'Panel',
          child: Panel(
            title: 'Camera',
            children: [
              NumberField(label: 'FOV', labelWidth: 72, min: 10, max: 120, value: _fov, onChanged: (v) => setState(() => _fov = v)),
              PointField(label: 'Position', step: 0.1, value: _position, onChanged: (v) => setState(() => _position = v)),
              PointField(label: 'Resolution', labels: const {'x': 'W', 'y': 'H'}, min: 1, value: _size, onChanged: (v) => setState(() => _size = v)),
              ControlRow(
                label: 'Projection',
                child: Dropdown<String>(
                  value: _projection,
                  items: const ['Perspective', 'Orthographic'],
                  onChanged: (v) => setState(() => _projection = v),
                ),
              ),
              ControlRow(
                label: 'Mode',
                child: SegmentedButton<String>(
                  segments: const {'orbit': Text('Orbit'), 'fly': Text('Fly')},
                  selected: _mode,
                  onSelectionChanged: (v) => setState(() => _mode = v),
                ),
              ),
              Folder(
                title: 'Lighting',
                children: [
                  SliderField(label: 'Intensity', min: 0, max: 1, step: 0.01, value: _intensity, onChanged: (v) => setState(() => _intensity = v)),
                  SliderField(label: 'Exposure', min: -5, max: 5, value: _exposure, onChanged: (v) => setState(() => _exposure = v)),
                ],
              ),
              const Folder(
                title: 'Advanced',
                initiallyOpen: false,
                children: [NumberField(label: 'Near', value: 0.1, step: 0.1)],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
