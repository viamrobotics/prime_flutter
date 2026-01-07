import 'package:flutter/material.dart' hide TabBar;
import 'package:prime_flutter/prime_flutter.dart';

enum AppBarPageStyle { basic, withActions, withBottom }

class AppBarPage extends StatelessWidget {
  final AppBarPageStyle style;

  const AppBarPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Container(
            // Adding a border to visually show the app bar container in the white playground
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                switch (style) {
                  AppBarPageStyle.basic => const PrimeAppBar(title: Text('Basic AppBar'), leading: Icon(PrimeIcons.viamFlutter)),
                  AppBarPageStyle.withActions => const PrimeAppBar(
                    title: Text('With Actions'),
                    leading: Icon(PrimeIcons.viamFlutter),
                    actions: [Icon(PrimeIcons.viamFlutter), Icon(PrimeIcons.viamFlutter)],
                  ),
                  AppBarPageStyle.withBottom => PrimeAppBar(
                    title: const Text('With Bottom'),
                    leading: const Icon(PrimeIcons.menu),
                    bottom: TabBar(
                      selectedIndex: 0,
                      onDestinationSelected: (_) {},
                      items: const [Text('Tab 1'), Text('Tab 2'), Text('Tab 3')],
                    ),
                  ),
                },
                Container(
                  height: 100,
                  color: PrimeTheme.of(context).colorScheme.surfaceBase,
                  alignment: Alignment.center,
                  child: Text('Page Content', style: PrimeTheme.of(context).textTheme.bodyDefault),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
