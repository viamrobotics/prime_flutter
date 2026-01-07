import 'package:flutter/material.dart' hide Divider;
import 'package:prime_flutter/prime_flutter.dart';

enum DividerPageStyle { defaultStyle }

class DividerPage extends StatelessWidget {
  final DividerPageStyle style;

  const DividerPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item 1', style: PrimeTheme.of(context).textTheme.bodyDefault),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text('Item 2', style: PrimeTheme.of(context).textTheme.bodyDefault),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text('Item 3', style: PrimeTheme.of(context).textTheme.bodyDefault),
            ],
          ),
        ),
      ),
    );
  }
}
