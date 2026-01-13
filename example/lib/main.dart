import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/widgets/slider_screen.dart';

import 'screens/theme_editor/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeManager(),
      builder: (context, child) {
        return PrimeApp(
          title: 'Prime Flutter Example',
          theme: PrimeThemeData(colorScheme: ThemeManager().currentScheme, textTheme: PrimeTextTheme.base(), cornerRadius: 8.0),
          home: const HomeScreen(),
        );
      },
    );
  }
}
