import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Navigation Bar')),
      body: Center(child: Text('Selected Index: $_selectedIndex', style: PrimeTheme.of(context).textTheme.heading)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        items: const [
          NavigationBarItemData(icon: PrimeIcons.alert, label: Text('Favorites')),
          NavigationBarItemData(icon: PrimeIcons.domain, label: Text('Locations')),
          NavigationBarItemData(icon: PrimeIcons.gridOrthographic, label: Text('Teleop')),
          NavigationBarItemData(selectedIcon: PrimeIcons.alert, icon: PrimeIcons.alertOutline, label: Text('Selected Icons')),
        ],
      ),
    );
  }
}
