import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              Text('Acme Inc'), // needs to be bold
              const SizedBox(width: 2),
              Icon(PrimeIcons.unfoldMoreHorizontal, size: 16),
            ],
          ),
        ),
        actions: [
          Icon(PrimeIcons.magnify),
          const SizedBox(width: 8),
          const Avatar(child: Text('NH')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            Input(placeholder: 'Search locations', leading: Icon(PrimeIcons.magnify)),
            _LocationCard(locationName: 'My Location 1', locationCount: '42', onPressed: () {}),
            _LocationCard(locationName: 'My Location 2', locationCount: '5', onPressed: () {}),
            _LocationCard(locationName: 'My Location 3', locationCount: '8', onPressed: () {}),
            _LocationCard(locationName: 'My Location 4', locationCount: '15', onPressed: () {}),
            _LocationCard(locationName: 'My Location 5', locationCount: '5', onPressed: () {}),
            _LocationCard(locationName: 'My Location 6', locationCount: '5', onPressed: () {}),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (_) {},
        items: [
          NavigationBarItemData(icon: PrimeIcons.linkedin, label: 'Favorites'),
          NavigationBarItemData(icon: PrimeIcons.domain, label: 'Locations'),
          NavigationBarItemData(icon: PrimeIcons.monitorDashboard, label: 'Teleop'),
          NavigationBarItemData(icon: PrimeIcons.robotOutline, label: 'Try Viam'),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.locationName, required this.locationCount, required this.onPressed});

  final String locationName;
  final String locationCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);

    return ListItem.card(
      leading: Icon(PrimeIcons.domain, size: 16),
      title: Text(locationName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(locationCount, style: theme.textTheme.bodySmall.copyWith(color: theme.colorScheme.textTertiary)),
          const SizedBox(width: 8),
          Icon(PrimeIcons.chevronRight, size: 16, color: theme.colorScheme.textTertiary),
        ],
      ),
      onPressed: onPressed,
    );
  }
}
