import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class TabBarScreen extends StatefulWidget {
  const TabBarScreen({super.key});

  @override
  State<TabBarScreen> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(
        title: const Text('machine-123'),
        actions: [
          IconButton(
            icon: Icon(PrimeIcons.dotsHorizontal, color: PrimeTheme.of(context).colorScheme.textDisabled),
            onPressed: () {},
          ),
        ],
        bottom: PrimeTabBar(
          items: const ['CONTROL', 'LOGS', 'SETTINGS', 'ALERTS', 'HISTORY', 'DIAGNOSTICS'],
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        ),
      ),
      body: Center(
        child: Text(
          _selectedIndex == 0 ? 'Control Panel' : 'System Logs',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class IconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const IconButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Padding(padding: const EdgeInsets.all(8.0), child: icon),
      ),
    );
  }
}
