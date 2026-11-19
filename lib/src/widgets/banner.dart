import 'package:flutter/widgets.dart';

import '../theme/prime_color_scheme.dart';
import '../theme/prime_colors.dart';
import '../theme/prime_theme.dart';
import 'icon_button.dart';
import 'prime_icons.dart';
import 'progress.dart';

enum BannerVariant { info, warning, danger, success, pending }

enum BannerSize { small, base }

/// The look of a [PrimeBanner].
enum BannerAppearance {
  /// A tinted surface with an accent bar on its leading edge, as in
  /// `prime-core`. The accent bar shows [PrimeBanner.progress].
  filled,

  /// A plain surface with the icon in a tinted chip, as in `prime-ui`.
  outlined,
}

/// Resolved colors for a [BannerVariant], shared with [NotificationContainer].
({Color background, Color border, Color accent, Color accentTrack, IconData? icon}) bannerVariantStyle(
  BannerVariant variant,
  PrimeColorScheme c,
) {
  switch (variant) {
    case BannerVariant.info:
      return (
        background: c.statusInfoLight,
        border: PrimeColors.infoMedium,
        accent: c.statusInfoDark,
        accentTrack: const Color(0xFF80B3E5),
        icon: PrimeIcons.information,
      );
    case BannerVariant.warning:
      return (
        background: c.statusWarningLight,
        border: PrimeColors.warningMedium,
        accent: PrimeColors.warningBright,
        accentTrack: const Color(0xFFEED59F),
        icon: PrimeIcons.alert,
      );
    case BannerVariant.danger:
      return (
        background: c.statusDangerLight,
        border: PrimeColors.dangerMedium,
        accent: c.statusDangerDark,
        accentTrack: const Color(0xFFDF9A9B),
        icon: PrimeIcons.alertCircle,
      );
    case BannerVariant.success:
      return (
        background: c.statusSuccessLight,
        border: PrimeColors.successMedium,
        accent: c.statusSuccessDark,
        accentTrack: const Color(0xFF9EBE9F),
        icon: PrimeIcons.checkCircle,
      );
    case BannerVariant.pending:
      return (
        background: PrimeColors.pendingLight,
        border: PrimeColors.pendingMedium,
        accent: PrimeColors.pendingDark,
        accentTrack: PrimeColors.pendingLight,
        icon: null,
      );
  }
}

/// An inline alert that communicates status to the user.
///
/// Named `PrimeBanner` because `Banner` is taken by `flutter/widgets`.
///
/// ```dart
/// PrimeBanner(
///   variant: BannerVariant.warning,
///   title: const Text('Credentials expire soon'),
///   subtitle: const Text('Rotate the API key before Friday.'),
///   onClose: () {},
/// )
/// ```
class PrimeBanner extends StatefulWidget {
  /// The severity being communicated.
  final BannerVariant variant;

  final Widget? title;
  final Widget? subtitle;

  /// A secondary action shown under the subtitle, typically a link.
  final Widget? action;

  /// A prominent action shown under the subtitle, typically a [Button].
  final Widget? actionEmphasize;

  /// Extra content tucked behind a "Details" disclosure.
  final Widget? expandableDetails;

  /// Fill of the accent bar on the leading edge, from 0 to 1. Used by
  /// notifications to show time remaining.
  final double progress;

  /// When provided, a close button is shown and calls this.
  final VoidCallback? onClose;

  final BannerSize size;

  /// Swaps the status icon for a spinner.
  final bool loading;

  final BannerAppearance appearance;

  const PrimeBanner({
    super.key,
    this.variant = BannerVariant.info,
    this.title,
    this.subtitle,
    this.action,
    this.actionEmphasize,
    this.expandableDetails,
    this.progress = 1,
    this.onClose,
    this.size = BannerSize.base,
    this.loading = false,
    this.appearance = BannerAppearance.filled,
  });

  @override
  State<PrimeBanner> createState() => _PrimeBannerState();
}

class _PrimeBannerState extends State<PrimeBanner> {
  bool _detailsOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final style = bannerVariantStyle(widget.variant, theme.colorScheme);
    final isSmall = widget.size == BannerSize.small;
    final fontSize = isSmall ? 12.0 : 14.0;
    // Status surfaces stay light in both themes, so text is pinned dark.
    final titleStyle = theme.textTheme.bodySmall.copyWith(fontSize: fontSize, fontWeight: FontWeight.w600, color: PrimeColors.gray9);
    final bodyStyle = theme.textTheme.bodySmall.copyWith(fontSize: fontSize, color: PrimeColors.gray8);
    final radius = BorderRadius.circular(theme.cornerRadius);

    if (widget.appearance == BannerAppearance.outlined) {
      final c = theme.colorScheme;
      final loading = widget.loading || widget.variant == BannerVariant.pending;
      return Semantics(
        container: true,
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.surfaceBase,
            borderRadius: radius,
            border: Border.all(color: c.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: widget.title == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: style.background, borderRadius: BorderRadius.circular(4)),
                child: loading ? Progress(size: 16, color: style.accent) : Icon(style.icon ?? PrimeIcons.informationOutline, size: 18, color: style.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null) DefaultTextStyle(style: titleStyle.copyWith(color: c.textPrimary), child: widget.title!),
                    if (widget.subtitle != null) DefaultTextStyle(style: bodyStyle.copyWith(color: c.textSecondary), child: widget.subtitle!),
                    if (widget.action != null) ...[
                      const SizedBox(height: 8),
                      DefaultTextStyle(style: bodyStyle.copyWith(fontWeight: FontWeight.w500, color: c.textSecondary), child: widget.action!),
                    ],
                    if (widget.actionEmphasize != null) ...[const SizedBox(height: 12), widget.actionEmphasize!],
                  ],
                ),
              ),
              if (widget.onClose != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(PrimeIcons.close),
                  label: 'Dismiss notification',
                  showTooltip: false,
                  variant: IconButtonVariant.ghost,
                  onPressed: widget.onClose,
                ),
              ],
            ],
          ),
        ),
      );
    }

    Widget? leading;
    if (!isSmall) {
      if (widget.loading) {
        leading = Progress(size: 18, color: style.accent);
      } else if (style.icon != null) {
        leading = Icon(style.icon, size: 18, color: style.accent);
      }
    }

    final body = Padding(
      padding: EdgeInsets.fromLTRB(isSmall ? 16 : 12, 12, widget.onClose != null ? 44 : (isSmall ? 16 : 12), 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[Padding(padding: const EdgeInsets.only(top: 1), child: leading), const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null) DefaultTextStyle(style: titleStyle, child: widget.title!),
                if (widget.subtitle != null) DefaultTextStyle(style: bodyStyle, child: widget.subtitle!),
                if (widget.action != null) ...[
                  const SizedBox(height: 8),
                  DefaultTextStyle(style: bodyStyle.copyWith(fontWeight: FontWeight.w500), child: widget.action!),
                ],
                if (widget.actionEmphasize != null) ...[const SizedBox(height: 12), widget.actionEmphasize!],
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      liveRegion: true,
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: radius,
            border: Border.all(color: style.border),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    body,
                    if (widget.expandableDetails != null)
                      Container(
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: style.border))),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _detailsOpen = !_detailsOpen),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedRotation(
                                    turns: _detailsOpen ? 0.25 : 0,
                                    duration: const Duration(milliseconds: 150),
                                    child: const Icon(PrimeIcons.chevronRight, size: 16, color: PrimeColors.gray6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('Details', style: bodyStyle.copyWith(fontSize: 12)),
                                ],
                              ),
                            ),
                            if (_detailsOpen) ...[
                              const SizedBox(height: 12),
                              DefaultTextStyle(style: bodyStyle.copyWith(fontSize: 12), child: widget.expandableDetails!),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Accent bar; drains from the top as [progress] drops.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: ColoredBox(
                  color: style.accentTrack,
                  child: FractionallySizedBox(
                    alignment: Alignment.bottomCenter,
                    heightFactor: widget.progress.clamp(0.0, 1.0),
                    child: ColoredBox(color: style.accent),
                  ),
                ),
              ),
              if (widget.onClose != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(PrimeIcons.close, color: PrimeColors.gray7),
                    label: 'Dismiss notification',
                    showTooltip: false,
                    variant: IconButtonVariant.ghost,
                    onPressed: widget.onClose,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
