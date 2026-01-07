import 'package:flutter/material.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum AvatarPageStyle { initials, icon, sizes }

class AvatarPage extends StatelessWidget {
  final AvatarPageStyle style;

  const AvatarPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: switch (style) {
          AvatarPageStyle.initials => const Avatar(child: Text('CP')),
          AvatarPageStyle.icon => const Avatar(child: Icon(PrimeIcons.viamFlutter, size: 20)),
          AvatarPageStyle.sizes => const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Avatar(size: 24, child: Text('XS')),
              SizedBox(width: 16),
              Avatar(size: 32, child: Text('SM')),
              SizedBox(width: 16),
              Avatar(size: 48, child: Text('MD')),
              SizedBox(width: 16),
              Avatar(size: 64, child: Text('LG')),
            ],
          ),
        },
      ),
    );
  }
}
