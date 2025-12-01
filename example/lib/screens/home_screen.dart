import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prime Flutter', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Component Showcase', style: TextStyle(fontSize: 16, color: Color(0xFF757575))),
            const SizedBox(height: 32),
            _buildShowcaseCard(
              context: context,
              title: 'Icons',
              description: 'Browse all available PrimeIcons',
              icon: PrimeIcons.applicationOutline,
              screen: const IconsScreen(),
            ),
            const SizedBox(height: 16),
            _buildShowcaseCard(
              context: context,
              title: 'Badge',
              description: 'Status badges with different variants',
              icon: PrimeIcons.tagOutline,
              screen: const BadgeScreen(),
            ),
            const SizedBox(height: 16),
            _buildShowcaseCard(
              context: context,
              title: 'Buttons',
              description: 'Buttons with different variants and states',
              icon: PrimeIcons.cursorMove,
              screen: const ButtonScreen(),
            ),
            const SizedBox(height: 16),
            _buildShowcaseCard(
              context: context,
              title: 'Progress',
              description: 'Progress indicators and spinners',
              icon: PrimeIcons.syncIcon,
              screen: const ProgressScreen(),
            ),
            // Add more showcase cards here as you develop widgets
          ],
        ),
      ),
    );
  }

  Widget _buildShowcaseCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 24, color: const Color(0xFF1976D2)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14, color: Color(0xFF757575))),
                ],
              ),
            ),
            const Icon(PrimeIcons.chevronRight, size: 20, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}
