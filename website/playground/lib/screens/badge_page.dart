import 'package:flutter/material.dart' hide Badge;
import 'package:prime_flutter/prime_flutter.dart';

enum BadgePageStyle { defaultStyle, variants, withIcon, noBackground }

class BadgePage extends StatelessWidget {
  final BadgePageStyle style;

  const BadgePage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: switch (style) {
          BadgePageStyle.defaultStyle => const Badge(child: Text('Neutral')),
          BadgePageStyle.variants => const Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Badge(variant: BadgeVariant.neutral, child: Text('Neutral')),
              Badge(variant: BadgeVariant.success, child: Text('Success')),
              Badge(variant: BadgeVariant.warning, child: Text('Warning')),
              Badge(variant: BadgeVariant.danger, child: Text('Danger')),
              Badge(variant: BadgeVariant.info, child: Text('Info')),
            ],
          ),
          BadgePageStyle.withIcon => const Badge(icon: Icon(PrimeIcons.viamFlutter), child: Text('Badge with Icon')),
          BadgePageStyle.noBackground => const Badge(showBackground: false, child: Text('No Background')),
        },
      ),
    );
  }
}
