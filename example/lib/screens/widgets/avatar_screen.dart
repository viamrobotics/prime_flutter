import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      appBar: const PrimeAppBar(title: Text('Avatar')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Default (32px)'),
            const SizedBox(height: 8),
            const Avatar(child: Text('NH')),
            const SizedBox(height: 32),
            const Text('Large (64px)'),
            const SizedBox(height: 8),
            const Avatar(size: 64, child: Text('AB')),
            const SizedBox(height: 32),
            const Text('Custom Colors'),
            const SizedBox(height: 8),
            Avatar(
              backgroundColor: PrimeTheme.of(context).colorScheme.actionPrimaryBg,
              foregroundColor: PrimeTheme.of(context).colorScheme.surfaceBase,
              child: const Text('P'),
            ),
          ],
        ),
      ),
    );
  }
}
