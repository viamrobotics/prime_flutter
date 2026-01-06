import 'package:flutter/material.dart' hide NavigationBar;
import 'package:prime_flutter/prime_flutter.dart';

enum NavigationBarPageStyle { basic }

class NavigationBarPage extends StatefulWidget {
  final NavigationBarPageStyle style;

  const NavigationBarPage({super.key, required this.style});

  @override
  State<NavigationBarPage> createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
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
                height: 200,
                color: PrimeTheme.of(context).colorScheme.surfaceBase,
                alignment: Alignment.center,
                child: Text('Content for tab $_selectedIndex', style: PrimeTheme.of(context).textTheme.bodyDefault),
              ),
              NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                items: const [
                  NavigationBarItemData(icon: PrimeIcons.viamFlutter, label: Text('Home')),
                  NavigationBarItemData(icon: PrimeIcons.viamFlutter, label: Text('Devices')), // Replacing search with placeholder
                  NavigationBarItemData(icon: PrimeIcons.viamFlutter, label: Text('Settings')), // Replacing settings with placeholder
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
