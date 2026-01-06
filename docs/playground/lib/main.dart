import 'package:flutter/material.dart'; // Change to material for MaterialPageRoute? Or use PageRouteBuilder. PrimeApp might expect widgets app concepts.
import 'package:prime_flutter/prime_flutter.dart';
import 'screens/app_bar_page.dart';
import 'screens/avatar_page.dart';
import 'screens/badge_page.dart';
import 'screens/button_page.dart';
import 'screens/divider_page.dart';
import 'screens/expansion_list_item_page.dart';
import 'screens/filter_pill_page.dart';
import 'screens/icon_page.dart';
import 'screens/input_page.dart';
import 'screens/list_item_page.dart';
import 'screens/navigation_bar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DocsApp());
}

class DocsApp extends StatelessWidget {
  const DocsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeApp(
      title: 'Prime Flutter Docs',
      theme: PrimeThemeData(colorScheme: PrimeColorScheme.light(), textTheme: PrimeTextTheme.base(), cornerRadius: 8.0),
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        if (uri.path == '/app-bar') {
          final styleStr = uri.queryParameters['style'];
          final style = AppBarPageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => AppBarPageStyle.basic);
          return PrimePageRoute(builder: (_) => AppBarPage(style: style));
        }

        if (uri.path == '/expansion-list-item') {
          final styleStr = uri.queryParameters['style'];
          final style = ExpansionListItemPageStyle.values.firstWhere(
            (e) => e.name == styleStr,
            orElse: () => ExpansionListItemPageStyle.standard,
          );
          return PrimePageRoute(builder: (_) => ExpansionListItemPage(style: style));
        }

        if (uri.path == '/filter-pill') {
          final styleStr = uri.queryParameters['style'];
          final style = FilterPillPageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => FilterPillPageStyle.basic);
          return PrimePageRoute(builder: (_) => FilterPillPage(style: style));
        }

        if (uri.path == '/input') {
          final styleStr = uri.queryParameters['style'];
          final style = InputPageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => InputPageStyle.basic);
          return PrimePageRoute(builder: (_) => InputPage(style: style));
        }

        if (uri.path == '/list-item') {
          final styleStr = uri.queryParameters['style'];
          final style = ListItemPageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => ListItemPageStyle.standard);
          return PrimePageRoute(builder: (_) => ListItemPage(style: style));
        }

        if (uri.path == '/navigation-bar') {
          final styleStr = uri.queryParameters['style'];
          final style = NavigationBarPageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => NavigationBarPageStyle.basic);
          return PrimePageRoute(builder: (_) => NavigationBarPage(style: style));
        }

        if (uri.path == '/avatar') {
          final styleStr = uri.queryParameters['style'];
          final style = AvatarPageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => AvatarPageStyle.initials);
          return PrimePageRoute(builder: (_) => AvatarPage(style: style));
        }

        if (uri.path == '/badge') {
          final styleStr = uri.queryParameters['style'];
          final style = BadgePageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => BadgePageStyle.defaultStyle);
          return PrimePageRoute(builder: (_) => BadgePage(style: style));
        }

        if (uri.path == '/button') {
          final styleStr = uri.queryParameters['style'];
          final style = PlaygroundButtonStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => PlaygroundButtonStyle.primary);
          return PrimePageRoute(builder: (_) => ButtonPage(style: style));
        }

        if (uri.path == '/divider') {
          final styleStr = uri.queryParameters['style'];
          final style = DividerPageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => DividerPageStyle.defaultStyle);
          return PrimePageRoute(builder: (_) => DividerPage(style: style));
        }

        if (uri.path == '/icon') {
          final styleStr = uri.queryParameters['style'];
          final style = IconPageStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => IconPageStyle.example);
          return PrimePageRoute(builder: (_) => IconPage(style: style));
        }

        return PrimePageRoute(builder: (_) => const Center(child: Text('Select a component')));
      },
    );
  }
}
