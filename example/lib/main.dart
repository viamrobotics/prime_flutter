import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrimeApp(title: 'Prime Flutter Example', home: HomeScreen());
  }
}
