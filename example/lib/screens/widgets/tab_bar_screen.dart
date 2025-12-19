import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class TabBarScreen extends StatefulWidget {
  const TabBarScreen({super.key});

  @override
  State<TabBarScreen> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  int _selectedIndex = 0;
  int _scrollableTabBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(
        title: const Text('machine-123'),
        actions: [
          IconButton(
            icon: Icon(PrimeIcons.dotsHorizontal, color: PrimeTheme.of(context).colorScheme.iconDisabled),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          items: const ['TAB 1', 'TAB 2', 'SCROLL EXAMPLE'],
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedIndex == 0) const Text('Tab 1'),
            if (_selectedIndex == 1) const Text('Tab 2'),
            if (_selectedIndex == 2)
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Text('This is a scrollable tab bar example'),
                  TabBar(
                    items: const ['CONTROL', 'LOGS', 'SETTINGS', 'ALERTS', 'HISTORY', 'DIAGNOSTICS'],
                    selectedIndex: _scrollableTabBarIndex,
                    onDestinationSelected: (index) => setState(() => _scrollableTabBarIndex = index),
                  ),
                ],
              ),
          ],
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
