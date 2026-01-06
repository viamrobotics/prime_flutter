import 'package:flutter/material.dart' hide TabBar;
import 'package:prime_flutter/prime_flutter.dart';

enum TabBarPageStyle { basic }

class TabBarPage extends StatefulWidget {
  final TabBarPageStyle style;

  const TabBarPage({super.key, required this.style});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                color: PrimeTheme.of(context).colorScheme.surfaceBase,
                alignment: Alignment.center,
                child: Text('Content for tab $_selectedIndex', style: PrimeTheme.of(context).textTheme.bodyDefault),
              ),
              TabBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                items: const [Text('Tab 1'), Text('Tab 2'), Text('Tab 3')],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
