import 'package:flutter/cupertino.dart'; // For icons in the example
import 'package:flutter/material.dart' as m;
import 'package:prime_flutter/prime_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrimeApp(title: 'Prime Flutter Example', home: ExampleScreen());
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);

    return PrimeScaffold(
      appBar: AppBar(
        title: const Text('viam-dev'),
        actions: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: theme.colorScheme.gray3, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('NH', style: theme.textTheme.label.copyWith(color: theme.colorScheme.textDefault)),
          ),
          const SizedBox(width: 16),
        ],
        bottom: Container(color: theme.colorScheme.borderLight, height: 1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar (Mock)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.white,
              border: Border.all(color: theme.colorScheme.borderLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.search, color: theme.colorScheme.textSubtle2),
                const SizedBox(width: 8),
                Text('Search', style: theme.textTheme.bodyDefault.copyWith(color: theme.colorScheme.textSubtle2)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('In this organization', style: theme.textTheme.label),
          const SizedBox(height: 12),

          Card(
            title: 'rover-3',
            subtitle: 'Concourse > Zone 3',
            status: Badge(text: 'LIVE', variant: BadgeVariant.success, icon: CupertinoIcons.radiowaves_left),
            onMenuTap: () {
              m.showAboutDialog(context: context);
            },
            onTap: () {},
          ),
          const SizedBox(height: 12),
          Card(
            title: 'rover-5',
            subtitle: 'Mezzanine',
            status: const Badge(text: 'MIXED', variant: BadgeVariant.warning, icon: CupertinoIcons.exclamationmark_triangle),
            onMenuTap: () {},
            onTap: () {},
          ),

          const SizedBox(height: 24),
          Container(height: 1, color: theme.colorScheme.borderLight),
          const SizedBox(height: 24),

          Text('Acme Inc', style: theme.textTheme.label),
          const SizedBox(height: 12),

          Card(
            title: 'my-bot',
            subtitle: 'location A > location B',
            status: Badge(text: 'LIVE', variant: BadgeVariant.success, icon: CupertinoIcons.radiowaves_right),
            onMenuTap: () {},
            onTap: () {},
          ),
          const SizedBox(height: 12),
          Card(
            title: 'office-rover',
            subtitle: 'location A > location C',
            status: const Badge(text: 'OFFLINE', variant: BadgeVariant.danger, icon: CupertinoIcons.wifi_slash),
            onMenuTap: () {},
            onTap: () {},
          ),
          const SizedBox(height: 12),
          Card(
            title: 'soil-monitor',
            subtitle: 'location A > location D',
            status: const Badge(text: 'OFFLINE', variant: BadgeVariant.danger, icon: CupertinoIcons.wifi_slash),
            onMenuTap: () {},
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.white,
          border: Border(top: BorderSide(color: theme.colorScheme.borderLight)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.building_2_fill, color: theme.colorScheme.textHeading),
                const SizedBox(height: 4),
                Text('Locations', style: theme.textTheme.label.copyWith(color: theme.colorScheme.textHeading)),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.star, color: theme.colorScheme.textSubtle2),
                const SizedBox(height: 4),
                Text('Favorites', style: theme.textTheme.label.copyWith(color: theme.colorScheme.textSubtle2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
