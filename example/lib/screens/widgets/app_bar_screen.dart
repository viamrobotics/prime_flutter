import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class AppBarScreen extends StatefulWidget {
  const AppBarScreen({super.key});

  @override
  State<AppBarScreen> createState() => _AppBarScreenState();
}

class _AppBarScreenState extends State<AppBarScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('App Bar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              label: 'Basic',
              child: const PrimeAppBar(title: Text('Basic AppBar'), leading: Icon(PrimeIcons.viamFlutter)),
            ),
            _Section(
              label: 'With actions',
              child: const PrimeAppBar(
                title: Text('With Actions'),
                leading: Icon(PrimeIcons.viamFlutter),
                actions: [Icon(PrimeIcons.viamFlutter), Icon(PrimeIcons.viamFlutter)],
              ),
            ),
            _Section(
              label: 'With bottom (TabBar)',
              child: PrimeAppBar(
                title: const Text('With Bottom'),
                leading: const Icon(PrimeIcons.menu),
                bottom: TabBar(
                  selectedIndex: _tabIndex,
                  onDestinationSelected: (i) => setState(() => _tabIndex = i),
                  items: const [Text('TAB 1'), Text('TAB 2'), Text('TAB 3')],
                ),
              ),
            ),
            _Section(
              label: 'Left-aligned title (centerTitle: false)',
              description:
                  'Title takes remaining space and ellipses cleanly against actions. '
                  'The leading slot is no longer constrained to icon width.',
              child: const PrimeAppBar(
                centerTitle: false,
                leading: Icon(PrimeIcons.menu),
                title: Text('A very long title that would otherwise overlap actions', overflow: TextOverflow.ellipsis),
                actions: [Icon(PrimeIcons.viamFlutter), Icon(PrimeIcons.viamFlutter)],
              ),
            ),
            _Section(
              label: 'Left-aligned with wide leading',
              description: 'The leading slot can host more than an icon — e.g. an org switcher.',
              child: PrimeAppBar(
                centerTitle: false,
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Avatar(size: 24, child: Text('AC')),
                    const SizedBox(width: 8),
                    Text('Acme Corp', style: theme.textTheme.bodyDefault.copyWith(fontWeight: FontWeight.w600)),
                    const Icon(PrimeIcons.unfoldMoreHorizontal, size: 16),
                  ],
                ),
                actions: const [Icon(PrimeIcons.magnify), Avatar(size: 24, child: Text('CP'))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final String? description;
  final Widget child;

  const _Section({required this.label, this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textSecondary)),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textTertiary),
            ),
          ],
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.borderSubtle)),
            child: child,
          ),
        ],
      ),
    );
  }
}
