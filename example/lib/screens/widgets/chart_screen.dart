import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'showcase.dart';

final DateTime _start = DateTime(2026, 11, 19, 18);

List<ChartPoint> _wave({required double base, required double swing, double phase = 0, int count = 60, Set<int> gaps = const {}}) => [
  for (var i = 0; i < count; i++)
    ChartPoint(_start.add(Duration(minutes: i)), gaps.contains(i) ? null : base + swing * math.sin(i / 6 + phase) + (i % 5) * swing / 20),
];

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final temperatures = [
      ChartSeries(name: 'cell-01', unit: '°C', points: _wave(base: 24, swing: 4)),
      ChartSeries(name: 'cell-02', unit: '°C', points: _wave(base: 21, swing: 3, phase: 2)),
      ChartSeries(
        name: 'cell-03',
        unit: '°C',
        points: _wave(base: 27, swing: 2, phase: 4, gaps: {20, 21, 22, 23, 40}),
        loading: _loading,
      ),
    ];

    return ShowcasePage(
      title: 'Chart',
      description: 'A time-series line chart with a legend, a tooltip and a table.',
      sections: [
        ShowcaseSection(
          title: 'Lines and a legend',
          description: 'Hover or touch the plot for the nearest point. Tap a legend item to hide its series. A gap breaks the line.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chart(
                semanticLabel: 'Cell temperature',
                series: temperatures,
                loading: _loading,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChartLegend(),
                    SizedBox(height: 8),
                    SizedBox(height: 256, child: ChartPlot()),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(value: _loading, onChanged: (value) => setState(() => _loading = value)),
                  const SizedBox(width: 8),
                  const Text('Loading'),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Bounds and formats',
          description: 'Given bounds are used exactly, and one format serves the axis, the tooltip and the table.',
          child: Chart(
            semanticLabel: 'Requests per hour',
            yMin: 0,
            yMax: 20000,
            yFormat: (value) => '${(value / 1000).toStringAsFixed(0)}k',
            series: [ChartSeries(name: 'api', unit: 'req/h', points: _wave(base: 11000, swing: 6000, count: 24))],
            child: const SizedBox(height: 200, child: ChartPlot()),
          ),
        ),
        ShowcaseSection(
          title: 'With a table',
          child: Chart(
            semanticLabel: 'Battery voltage',
            series: [
              ChartSeries(name: 'battery', unit: 'V', points: _wave(base: 12.4, swing: 0.3, count: 6)),
              ChartSeries(
                name: 'solar',
                unit: 'V',
                points: _wave(base: 13.1, swing: 0.6, count: 6, phase: 1, gaps: {2}),
              ),
            ],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChartLegend(),
                SizedBox(height: 8),
                SizedBox(height: 180, child: ChartPlot()),
                SizedBox(height: 12),
                ChartTable(),
              ],
            ),
          ),
        ),
        const ShowcaseSection(
          title: 'Empty',
          child: Chart(
            semanticLabel: 'No readings',
            series: [],
            child: SizedBox(height: 140, child: ChartPlot()),
          ),
        ),
      ],
    );
  }
}
