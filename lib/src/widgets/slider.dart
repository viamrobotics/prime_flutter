import 'package:flutter/material.dart';

import '../../prime_flutter.dart';

class Slider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  // Color overrides
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;
  final Color? activeTickColor;
  final Color? inactiveTickColor;

  const Slider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.activeTickColor,
    this.inactiveTickColor,
  }) : assert(min < max),
       assert(value >= min && value <= max),
       assert(divisions == null || divisions > 0);

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final trackHeight = 6.0;
    final thumbSize = 20.0;
    final thumbRadius = thumbSize / 2.0;

    final effectiveActiveTrackColor = activeTrackColor ?? theme.colorScheme.actionPrimaryBg;
    final effectiveInactiveTrackColor = inactiveTrackColor ?? theme.colorScheme.surfaceHighlight;
    final effectiveThumbColor = thumbColor ?? theme.colorScheme.actionPrimaryBg;

    // Default tick colors
    final effectiveActiveTickColor = activeTickColor ?? theme.colorScheme.actionPrimaryFg;
    final effectiveInactiveTickColor = inactiveTickColor ?? theme.colorScheme.iconDisabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - thumbSize;
        // Normalize value to 0.0 - 1.0 range
        final normalizedValue = (value - min) / (max - min);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              // Calculate new value based on drag position vs available width
              final dragValue = (details.localPosition.dx - thumbRadius) / availableWidth;
              var clampedDragValue = dragValue.clamp(0.0, 1.0);

              if (divisions != null) {
                clampedDragValue = (clampedDragValue * divisions!).round() / divisions!;
              }

              // De-normalize back to min-max range
              final newValue = clampedDragValue * (max - min) + min;
              onChanged(newValue);
            },
            onTapDown: (details) {
              final tapValue = (details.localPosition.dx - thumbRadius) / availableWidth;
              var clampedTapValue = tapValue.clamp(0.0, 1.0);

              if (divisions != null) {
                clampedTapValue = (clampedTapValue * divisions!).round() / divisions!;
              }

              final newValue = clampedTapValue * (max - min) + min;
              onChanged(newValue);
            },
            child: Container(
              height: 40,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Tracks
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: thumbRadius),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Background Track
                        Container(
                          height: trackHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: effectiveInactiveTrackColor,
                            borderRadius: BorderRadius.circular(trackHeight / 2),
                          ),
                        ),
                        // Active Track
                        FractionallySizedBox(
                          widthFactor: normalizedValue,
                          child: Container(
                            height: trackHeight,
                            decoration: BoxDecoration(
                              color: effectiveActiveTrackColor,
                              borderRadius: BorderRadius.circular(trackHeight / 2),
                            ),
                          ),
                        ),
                        // Division Dots
                        if (divisions != null && divisions! > 0)
                          ...List.generate(divisions! + 1, (index) {
                            final double dotPosition = index / divisions!;
                            // Determine if dot is active (covered by thumb or to the left)
                            // Use a small epsilon for float comparison logic or just strict inequalities
                            final bool isActive = dotPosition <= normalizedValue + 0.001;

                            return Positioned(
                              left: dotPosition * availableWidth - 2, // Center the 4px dot
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isActive ? effectiveActiveTickColor : effectiveInactiveTickColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  // Thumb
                  Positioned(
                    left: normalizedValue * availableWidth,
                    child: Container(
                      height: thumbSize,
                      width: thumbSize,
                      decoration: BoxDecoration(
                        color: effectiveThumbColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.surfaceBase, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
