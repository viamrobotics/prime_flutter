import 'package:flutter/widgets.dart';

import '../../prime_flutter.dart';

class Divider extends StatelessWidget {
  const Divider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: PrimeTheme.of(context).colorScheme.borderLight)),
      ),
    );
  }
}
