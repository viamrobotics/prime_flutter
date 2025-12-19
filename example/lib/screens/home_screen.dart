import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: PrimeAppBar(
        title: Text('Prime Flutter'),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(PrimePageRoute(builder: (_) => GlobalThemeEditor())),
            child: Container(padding: EdgeInsets.all(8), child: Icon(PrimeIcons.pencilOutline, size: 24)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Example Screens', style: TextStyle(fontSize: 16, color: Color(0xFF757575))),
            _buildListItem(
              context: context,
              title: 'Locations',
              description: 'See example Locations screen',
              icon: PrimeIcons.viamLocalModule,
              screen: LocationsScreen(),
            ),

            _buildListItem(
              context: context,
              title: 'Theme Editor',
              description: 'Create and export custom themes',
              icon: PrimeIcons.pencilOutline, // Using pencil as a placeholder for edit
              screen: GlobalThemeEditor(),
            ),

            SizedBox(height: 16),
            Text('Component Showcase', style: TextStyle(fontSize: 16, color: Color(0xFF757575))),
            _buildListItem(
              context: context,
              title: 'Icons',
              description: 'Browse all available PrimeIcons',
              icon: PrimeIcons.alert,
              screen: IconsScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Badge',
              description: 'Status badges with different variants',
              icon: PrimeIcons.tagOutline,
              screen: BadgeScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Buttons',
              description: 'Buttons with different variants and states',
              icon: PrimeIcons.openInNew,
              screen: ButtonScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Progress',
              description: 'Progress indicators and spinners',
              icon: PrimeIcons.syncIcon,
              screen: ProgressScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'List Items',
              description: 'List items with standard and card variants',
              icon: PrimeIcons.menu,
              screen: ListItemScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Navigation Bar',
              description: 'Bottom navigation bar',
              icon: PrimeIcons.cursorMove,
              screen: NavBarScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Top Tab Bar',
              description: 'Top navigation tabs',
              icon: PrimeIcons.navigationVariant, // Placeholder for tabs
              screen: TabBarScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Avatar',
              description: 'User avatars',
              icon: PrimeIcons.robotOutline,
              screen: AvatarScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Expansion List Item',
              description: 'Collapsible list items',
              icon: PrimeIcons.chevronDown,
              screen: const ExpansionListItemScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Bottom Sheet',
              description: 'Modal bottom sheets',
              icon: PrimeIcons.arrowUp,
              screen: const BottomSheetScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Filter Pills',
              description: 'Selectable filter chips',
              icon: PrimeIcons.link,
              screen: const FilterPillScreen(),
            ),
            _buildListItem(
              context: context,
              title: 'Input',
              description: 'Text input fields',
              icon: PrimeIcons.cardTextOutline,
              screen: const InputScreen(),
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
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: Icon(PrimeIcons.chevronRight),
      onPressed: () {
        Navigator.of(context).push(PrimePageRoute(builder: (_) => screen));
      },
    );
  }
}
