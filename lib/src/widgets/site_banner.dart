import 'package:flutter/widgets.dart';

import '../theme/prime_color_scheme.dart';
import '../theme/prime_theme.dart';
import 'icon_button.dart';
import 'internal/pressable.dart';
import 'prime_icons.dart';

enum SiteBannerVariant { warning, info, announcement }

enum SiteBannerSegmentStyle { normal, strong, subtle }

/// A run of banner copy for [SiteBannerVariant.announcement].
class SiteBannerSegment {
  final String text;
  final SiteBannerSegmentStyle style;

  /// When set, the run renders as a link and calls this on tap.
  final VoidCallback? onTap;

  const SiteBannerSegment(this.text, {this.style = SiteBannerSegmentStyle.normal, this.onTap});
}

/// A full-width banner for app-wide messages, placed above the app bar or at
/// the top of a screen.
///
/// ```dart
/// SiteBanner(
///   variant: SiteBannerVariant.info,
///   value: 'Scheduled maintenance tonight at 10pm ET',
///   onDismiss: () {},
/// )
/// ```
class SiteBanner extends StatelessWidget {
  /// The banner text. Used by the warning and info variants.
  final String? value;

  final SiteBannerVariant variant;

  /// Bold line above [value]. Warning and info variants only.
  final String? heading;

  /// When set, [value] renders as a link and calls this on tap.
  final VoidCallback? onTap;

  /// Trailing link label, shown with an "open in new" icon.
  final String? linkText;
  final VoidCallback? onLinkTap;

  /// Leading badge for the announcement variant.
  final String? badge;

  /// Styled copy runs for the announcement variant.
  final List<SiteBannerSegment> segments;

  /// When provided, a dismiss button is shown.
  final VoidCallback? onDismiss;

  const SiteBanner({
    super.key,
    this.value,
    this.variant = SiteBannerVariant.warning,
    this.heading,
    this.onTap,
    this.linkText,
    this.onLinkTap,
    this.badge,
    this.segments = const [],
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    if (variant == SiteBannerVariant.announcement) return _buildAnnouncement(context);

    final isWarning = variant == SiteBannerVariant.warning;
    final background = isWarning ? theme.colorScheme.statusWarningLight : theme.colorScheme.statusInfoLight;
    final iconColor = isWarning ? theme.colorScheme.statusWarningBright : theme.colorScheme.statusInfoDark;
    final hasHeading = heading != null;
    final linkColor = theme.textTheme.link.color;
    final valueStyle = theme.textTheme.bodySmall.copyWith(
      fontSize: hasHeading ? 12 : 14,
      fontWeight: hasHeading ? FontWeight.w400 : FontWeight.w600,
      color: onTap != null ? linkColor : theme.colorScheme.statusTextPrimary,
    );

    return Semantics(
      container: true,
      label: 'site banner',
      child: Container(
        color: background,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(isWarning ? PrimeIcons.alert : PrimeIcons.information, size: 18, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasHeading)
                    Text(
                      heading!,
                      style: theme.textTheme.bodySmall.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.statusTextPrimary),
                    ),
                  if (value != null)
                    GestureDetector(
                      onTap: onTap,
                      child: MouseRegion(
                        cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
                        child: Text(value!, style: valueStyle),
                      ),
                    ),
                ],
              ),
            ),
            if (linkText != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onLinkTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(linkText!, style: theme.textTheme.bodySmall.copyWith(fontSize: 12, color: linkColor)),
                      const SizedBox(width: 4),
                      Icon(PrimeIcons.openInNew, size: 14, color: linkColor),
                    ],
                  ),
                ),
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(PrimeIcons.close, color: theme.colorScheme.statusIcon),
                label: 'Dismiss banner',
                showTooltip: false,
                variant: IconButtonVariant.ghost,
                onPressed: onDismiss,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncement(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final mono = theme.textTheme.label.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0, color: c.textInverseSecondary);

    return Semantics(
      container: true,
      label: 'site banner',
      child: ClipRect(
        child: CustomPaint(
          painter: _GridPainter(background: c.surfaceInverse, line: c.textInversePrimary),
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  // Room on both sides keeps the copy centered and clear of the dismiss button.
                  padding: EdgeInsets.symmetric(horizontal: onDismiss != null ? 44 : 16, vertical: 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      if (badge != null)
                        Container(
                          color: c.textInversePrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            badge!.toUpperCase(),
                            style: mono.copyWith(fontSize: 10, fontWeight: FontWeight.w700, color: c.surfaceInverse),
                          ),
                        ),
                      for (final segment in segments) _buildSegment(segment, mono, c),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Pressable(
                        onTap: onDismiss,
                        semanticLabel: 'Dismiss announcement',
                        builder: (context, hovered, pressed) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(PrimeIcons.close, size: 18, color: hovered || pressed ? c.textInversePrimary : c.iconInverse),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(SiteBannerSegment segment, TextStyle base, PrimeColorScheme c) {
    if (segment.onTap != null) {
      return GestureDetector(
        onTap: segment.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            segment.text,
            style: base.copyWith(
              fontWeight: FontWeight.w700,
              color: c.textInversePrimary,
              decoration: TextDecoration.underline,
              decorationColor: c.textInverseTertiary,
            ),
          ),
        ),
      );
    }
    switch (segment.style) {
      case SiteBannerSegmentStyle.strong:
        return Text(
          segment.text,
          style: base.copyWith(fontWeight: FontWeight.w700, color: c.textInversePrimary),
        );
      case SiteBannerSegmentStyle.subtle:
        return Text(segment.text, style: base.copyWith(color: c.textInverseTertiary));
      case SiteBannerSegmentStyle.normal:
        return Text(segment.text, style: base);
    }
  }
}

/// The inverse backdrop with a faint 16px grid that fades in toward the right.
class _GridPainter extends CustomPainter {
  final Color background;
  final Color line;

  const _GridPainter({required this.background, required this.line});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = background);

    final paint = Paint()
      ..strokeWidth = 1
      ..shader = LinearGradient(colors: [line.withValues(alpha: 0), line.withValues(alpha: 0.12)]).createShader(rect);
    for (double x = 0; x <= size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 8; y <= size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => background != oldDelegate.background || line != oldDelegate.line;
}
