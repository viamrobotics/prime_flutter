import 'package:flutter/material.dart'; // Change to material for MaterialPageRoute? Or use PageRouteBuilder. PrimeApp might expect widgets app concepts.
import 'package:prime_flutter/prime_flutter.dart';
import 'screens/button_page.dart';
import 'screens/icon_page.dart';

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

        if (uri.path == '/button') {
          final styleStr = uri.queryParameters['style'];
          final style = PlaygroundButtonStyle.values.firstWhere((e) => e.name == styleStr, orElse: () => PlaygroundButtonStyle.primary);
          return PrimePageRoute(builder: (_) => ButtonPage(style: style));
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
