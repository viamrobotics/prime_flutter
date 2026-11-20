import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum ProgressPageStyle { basic, sized, colored }

class ProgressPage extends StatelessWidget {
  final ProgressPageStyle style;

  const ProgressPage({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: switch (style) {
          ProgressPageStyle.basic => const Progress(),
          ProgressPageStyle.sized => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Progress(size: 16), SizedBox(width: 24), Progress(size: 32), SizedBox(width: 24), Progress(size: 48)],
          ),
          ProgressPageStyle.colored => const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Progress(color: PrimeColors.focusBlue),
              SizedBox(width: 24),
              Progress(color: PrimeColors.dangerDark),
              SizedBox(width: 24),
              Progress(color: PrimeColors.successDark),
            ],
          ),
        },
      ),
    );
  }
}
