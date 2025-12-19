import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';

/// A progress widget. Used to display a progress indicator.
class Progress extends StatefulWidget {
  final double size;

  /// The color of the progress indicator.
  /// If null, it will fallback to [IconTheme] color, and then [PrimeTheme] iconPrimary.
  final Color? color;

  /// The number of ticks to display in the progress indicator.
  final int tickCount;

  const Progress({super.key, this.size = 16.0, this.color, this.tickCount = 8});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Adjust speed here
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimeTheme.consumer(
      builder: (context, theme) {
        final color = widget.color ?? IconTheme.of(context).color ?? theme.colorScheme.iconPrimary;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _SpinnerPainter(color: color, tickCount: widget.tickCount, progress: _controller.value),
              );
            },
          ),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final int tickCount;
  final double progress;

  _SpinnerPainter({required this.color, required this.tickCount, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Config: How long and thick the ticks are relative to size
    final tickLength = radius * 0.35;
    final tickWidth = radius * 0.12;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round; // Makes them "pills" not rectangles

    canvas.save();
    canvas.translate(center.dx, center.dy);

    for (int i = 0; i < tickCount; i++) {
      // Calculate opacity based on rotation
      // We offset the "active" index by the current animation progress
      final double indexRatio = i / tickCount;
      final double distance = (indexRatio - progress);

      // Math magic to create the "trail" effect
      // We normalize the distance to be between 0.0 and 1.0
      double opacity = (distance % 1.0);
      if (opacity < 0) opacity += 1.0;

      // Invert it so the "head" is dark and "tail" is light
      opacity = 1.0 - opacity;

      // Optional: Curve the opacity to make it fade faster or slower
      opacity = math.pow(opacity, 2).toDouble();

      // Set color with calculated opacity
      paint.color = color.withValues(alpha: opacity.clamp(0.2, 1.0)); // Keep min opacity 0.2

      // Draw the tick at the top (12 o'clock position)
      // We draw it at -radius (top) plus padding
      final RRect tick = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -radius + (tickLength / 2)), width: tickWidth, height: tickLength),
        Radius.circular(tickWidth / 2),
      );

      canvas.drawRRect(tick, paint);

      // Rotate canvas for the next tick
      canvas.rotate((2 * math.pi) / tickCount);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
