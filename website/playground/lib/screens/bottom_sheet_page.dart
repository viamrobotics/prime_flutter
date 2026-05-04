import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

enum BottomSheetPageStyle { basic, withTitle, scrollable, alternateColor }

class BottomSheetPage extends StatelessWidget {
  final BottomSheetPageStyle style;

  const BottomSheetPage({super.key, this.style = BottomSheetPageStyle.basic});

  @override
  Widget build(BuildContext context) {
    return PrimeScaffold(
      body: Center(
        child: Button(
          label: const Text('Show bottom sheet'),
          variant: ButtonVariant.primary,
          onPressed: () => _show(context),
        ),
      ),
    );
  }

  void _show(BuildContext context) {
    switch (style) {
      case BottomSheetPageStyle.basic:
        BottomSheet.show(
          context: context,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
            child: Text('This is a simple bottom sheet.'),
          ),
        );
      case BottomSheetPageStyle.withTitle:
        BottomSheet.show(
          context: context,
          title: const Text('Sheet Title'),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
            child: Text('This sheet has a title.'),
          ),
        );
      case BottomSheetPageStyle.scrollable:
        BottomSheet.show(
          context: context,
          title: const Text('Options'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 1; i <= 12; i++) ...[
                ListItem(
                  title: Text('Option $i'),
                  leading: const Icon(PrimeIcons.robotOutline),
                  onPressed: () {},
                ),
                const Divider(),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      case BottomSheetPageStyle.alternateColor:
        BottomSheet.show(
          context: context,
          title: const Text('Sheet Title'),
          backgroundColor: PrimeTheme.of(context).colorScheme.surfaceBase,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
            child: Text('This sheet uses an alternate background color.'),
          ),
        );
    }
  }
}
