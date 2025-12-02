import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Prime Flutter')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Component Showcase', style: TextStyle(fontSize: 16, color: Color(0xFF757575))),
            _buildListItem(
              context: context,
              title: 'Icons',
              description: 'Browse all available PrimeIcons',
              icon: PrimeIcons.alert,
              screen: const IconsScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Badge',
              description: 'Status badges with different variants',
              icon: PrimeIcons.tagOutline,
              screen: const BadgeScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Buttons',
              description: 'Buttons with different variants and states',
              icon: PrimeIcons.openInNew,
              screen: const ButtonScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Progress',
              description: 'Progress indicators and spinners',
              icon: PrimeIcons.syncIcon,
              screen: const ProgressScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'List Items',
              description: 'List items with standard and card variants',
              icon: PrimeIcons.menu,
              screen: const ListItemScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Navigation Bar',
              description: 'Bottom navigation bar',
              icon: PrimeIcons.cursorMove,
              screen: const NavBarScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Top Tab Bar',
              description: 'Top navigation tabs',
              icon: PrimeIcons.minus, // Placeholder for tabs
              screen: const TabBarScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Avatar',
              description: 'User avatars',
              icon: PrimeIcons.robotOutline,
              screen: const AvatarScreen(),
            ),
            // Add more showcase cards here as you develop widgets
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Widget screen,
  }) {
    return ListItem.card(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 24, color: const Color(0xFF1976D2)),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(PrimeIcons.chevronRight),
      onPressed: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => screen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      },
    );
  }
}
