import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'showcase.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Notifications need a container above the widgets that send them.
    return NotificationContainer(child: Builder(builder: _buildPage));
  }

  Widget _buildPage(BuildContext context) {
    final notify = Notify.of(context);
    return ShowcasePage(
      title: 'Feedback',
      description: 'Banners, notifications, pills and tooltips that report status.',
      sections: [
        ShowcaseSection(
          title: 'Banner',
          description: 'Inline alerts in five variants, with optional actions and details.',
          child: Column(
            spacing: 12,
            children: [
              const PrimeBanner(title: Text('Update available'), subtitle: Text('Version 0.3 adds new components.')),
              PrimeBanner(
                variant: BannerVariant.warning,
                title: const Text('Credentials expire soon'),
                subtitle: const Text('Rotate the API key before Friday.'),
                action: Text('Open settings', style: PrimeTheme.of(context).textTheme.link.copyWith(fontSize: 14)),
                onClose: () {},
              ),
              const PrimeBanner(
                variant: BannerVariant.danger,
                title: Text('Machine offline'),
                subtitle: Text('arm-1 has not checked in for 10 minutes.'),
                expandableDetails: Text('Last error: connection reset by peer'),
              ),
              PrimeBanner(
                variant: BannerVariant.success,
                title: const Text('Module deployed'),
                actionEmphasize: Button(label: const Text('View logs'), onPressed: () {}),
              ),
              const PrimeBanner(variant: BannerVariant.pending, loading: true, title: Text('Configuring machine')),
              const PrimeBanner(size: BannerSize.small, title: Text('Small banner'), subtitle: Text('No icon, tighter type.')),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Site banner',
          description: 'Full-width, app-level messages.',
          child: Column(
            spacing: 12,
            children: [
              SiteBanner(
                heading: 'We are investigating an issue with our platform',
                value: 'Data sync may be delayed',
                linkText: 'Status',
                onLinkTap: () {},
              ),
              SiteBanner(variant: SiteBannerVariant.info, value: 'Scheduled maintenance tonight at 10pm ET', onDismiss: () {}),
              SiteBanner(
                variant: SiteBannerVariant.announcement,
                badge: 'New',
                segments: [
                  const SiteBannerSegment('Teleop is here.', style: SiteBannerSegmentStyle.strong),
                  const SiteBannerSegment('Drive any arm from your phone.'),
                  SiteBannerSegment('Read more', onTap: () {}),
                ],
                onDismiss: () {},
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Notifications',
          description: 'Stacked in the top corner. Each counts down on its accent bar; hold one to pause it.',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Button(label: const Text('Info'), onPressed: () => notify.info('Heads up', message: 'Something you should know.')),
              Button(label: const Text('Success'), onPressed: () => notify.success('Saved', message: 'Your changes are live.')),
              Button(label: const Text('Warning'), onPressed: () => notify.warn('Careful', message: 'This may take a while.')),
              Button(label: const Text('Danger'), onPressed: () => notify.danger('Failed', message: 'Could not reach the machine.')),
              Button(label: const Text('Pending'), onPressed: () => notify.pending('Uploading', persist: true)),
            ],
          ),
        ),
        const ShowcaseSection(
          title: 'Status pill',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(label: 'Live', variant: StatusPillVariant.success, tooltip: 'Connected 2 minutes ago'),
              StatusPill(label: 'Degraded', variant: StatusPillVariant.warning),
              StatusPill(label: 'Offline', variant: StatusPillVariant.danger),
              StatusPill(label: 'Inactive', variant: StatusPillVariant.inactive),
              StatusPill(label: 'Configuring', variant: StatusPillVariant.inactive, loading: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Pill',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(value: 'Chocolate chip', onRemove: (_) {}),
              const Pill(value: 'Read only', readOnly: true),
              Pill(value: 'camera', icon: PrimeIcons.cameraOutline, iconTooltip: 'Component', onRemove: (_) {}),
              Pill(value: 'dark', variant: PillVariant.dark, icon: PrimeIcons.tagOutline, onRemove: (_) {}),
              Pill(value: 'info', variant: PillVariant.info, onRemove: (_) {}),
              Pill(value: 'warning', variant: PillVariant.warning, onRemove: (_) {}),
            ],
          ),
        ),
        const ShowcaseSection(
          title: 'Tooltip',
          description: 'Hover, focus, or long-press the target.',
          child: Row(
            spacing: 24,
            children: [
              Tooltip(message: 'Shown on hover or long press', child: Icon(PrimeIcons.informationOutline)),
              Tooltip(message: 'Always visible', visibility: TooltipVisibility.visible, placement: FloatingPlacement.right, child: Text('Pinned')),
            ],
          ),
        ),
      ],
    );
  }
}
